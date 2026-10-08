import 'dart:async';
import '../models/blood_request_model.dart';
import '../models/inventory_item_model.dart';
import '../utils/constants.dart';
import '../utils/compatibility_matrix.dart';
import '../utils/distance_calculator.dart';
import 'mock_data_service.dart';

class MatchCandidate {
  final String type; // 'hospital' or 'donor'
  final String id;
  final String name;
  final String bloodGroup;
  final double distanceKm;
  final int estimatedEtaMinutes;
  final String? bagId;
  final String? rfidTag;

  MatchCandidate({
    required this.type,
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.distanceKm,
    required this.estimatedEtaMinutes,
    this.bagId,
    this.rfidTag,
  });
}

/// Intelligent Parallel Matching Engine
class MatchingEngineService {
  static final MatchingEngineService _instance =
      MatchingEngineService._internal();
  factory MatchingEngineService() => _instance;
  MatchingEngineService._internal();

  /// Executes concurrent parallel search for donors & hospital blood stock
  Future<Map<String, List<MatchCandidate>>> searchParallelCandidates({
    required String bloodGroup,
    required int units,
    required double lat,
    required double lng,
  }) async {
    // Simulate real-time distributed query latency (< 1.5s per SRS)
    await Future.delayed(const Duration(milliseconds: 900));

    final compatibleGroups = CompatibilityMatrix.getCompatibleDonorsFor(bloodGroup);

    // 1. Search Hospital Inventory
    final hospitalCandidates = <MatchCandidate>[];
    for (final bag in MockDataService.initialInventory) {
      if (bag.status == BagStatus.stored &&
          !bag.isExpired &&
          compatibleGroups.contains(bag.bloodGroup)) {
        // Distance simulation based on hospital location
        const hospitalLat = 18.5304;
        const hospitalLng = 73.8467;
        final dist = DistanceCalculator.calculateDistance(
          lat1: lat,
          lon1: lng,
          lat2: hospitalLat,
          lon2: hospitalLng,
        );
        final eta = DistanceCalculator.estimateEtaMinutes(distanceKm: dist);

        hospitalCandidates.add(MatchCandidate(
          type: 'hospital',
          id: bag.hospitalId,
          name: bag.hospitalName,
          bloodGroup: bag.bloodGroup,
          distanceKm: double.parse(dist.toStringAsFixed(1)),
          estimatedEtaMinutes: eta,
          bagId: bag.bagId,
          rfidTag: bag.rfidTag,
        ));
      }
    }

    // 2. Search Verified Available Donors
    final donorCandidates = <MatchCandidate>[];
    if (MockDataService.initialDonorProfile.availability &&
        MockDataService.initialDonorProfile.isEligible &&
        compatibleGroups.contains(MockDataService.initialUsers[1].bloodGroup)) {
      final dist = DistanceCalculator.calculateDistance(
        lat1: lat,
        lon1: lng,
        lat2: MockDataService.initialDonorProfile.latitude,
        lon2: MockDataService.initialDonorProfile.longitude,
      );
      final eta = DistanceCalculator.estimateEtaMinutes(distanceKm: dist);

      donorCandidates.add(MatchCandidate(
        type: 'donor',
        id: MockDataService.initialUsers[1].uid,
        name: MockDataService.initialUsers[1].name,
        bloodGroup: MockDataService.initialUsers[1].bloodGroup,
        distanceKm: double.parse(dist.toStringAsFixed(1)),
        estimatedEtaMinutes: eta,
      ));
    }

    // Sort by proximity
    hospitalCandidates.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    donorCandidates.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return {
      'hospital': hospitalCandidates,
      'donor': donorCandidates,
    };
  }

  /// Lock first confirmed source with atomic concurrency reservation
  Future<BloodRequestModel> lockConfirmedSource({
    required BloodRequestModel request,
    required MatchCandidate candidate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // If hospital stock, mark bag as Reserved
    if (candidate.type == 'hospital' && candidate.bagId != null) {
      final bagIndex = MockDataService.initialInventory.indexWhere(
        (b) => b.bagId == candidate.bagId,
      );
      if (bagIndex != -1) {
        MockDataService.initialInventory[bagIndex] =
            MockDataService.initialInventory[bagIndex].copyWith(
          status: BagStatus.reserved,
          reservedForRequestId: request.requestId,
        );
      }
    }

    // Update request state to SourceLocked
    final updatedRequest = request.copyWith(
      status: RequestStatus.sourceLocked,
      assignedSourceType: candidate.type,
      assignedSourceId: candidate.id,
      assignedSourceName: candidate.name,
      assignedBagId: candidate.bagId,
      lockedAt: DateTime.now(),
    );

    final reqIndex = MockDataService.initialRequests.indexWhere(
      (r) => r.requestId == request.requestId,
    );
    if (reqIndex != -1) {
      MockDataService.initialRequests[reqIndex] = updatedRequest;
    } else {
      MockDataService.initialRequests.insert(0, updatedRequest);
    }

    return updatedRequest;
  }

  /// Activate Fallback Source if Primary candidate times out or rejects
  Future<BloodRequestModel?> activateFallbackSource({
    required BloodRequestModel request,
  }) async {
    // If donor rejected, fall back immediately to hospital inventory
    final results = await searchParallelCandidates(
      bloodGroup: request.bloodGroup,
      units: request.units,
      lat: request.latitude,
      lng: request.longitude,
    );

    final fallbackHospitals = results['hospital'];
    if (fallbackHospitals != null && fallbackHospitals.isNotEmpty) {
      return await lockConfirmedSource(
        request: request,
        candidate: fallbackHospitals.first,
      );
    }
    return null;
  }
}
