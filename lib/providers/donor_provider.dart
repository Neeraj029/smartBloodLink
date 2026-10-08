import 'package:flutter/material.dart';
import '../models/donor_profile_model.dart';
import '../models/badge_model.dart';
import '../models/blood_request_model.dart';
import '../repositories/donor_repository.dart';
import '../services/matching_engine_service.dart';
import '../utils/constants.dart';

/// Donor ViewModel managing availability, incoming emergency requests, gamification, and eligibility
class DonorProvider with ChangeNotifier {
  final DonorRepository _donorRepository;
  final MatchingEngineService _matchingEngine;

  late DonorProfileModel _donorProfile;
  List<DonorBadgeModel> _badges = [];
  List<Map<String, dynamic>> _leaderboard = [];
  BloodRequestModel? _incomingEmergencyRequest;
  bool _isLoading = false;

  DonorProvider({
    DonorRepository? donorRepository,
    MatchingEngineService? matchingEngine,
  })  : _donorRepository = donorRepository ?? DonorRepository(),
        _matchingEngine = matchingEngine ?? MatchingEngineService() {
    _loadDonorData();
  }

  DonorProfileModel get donorProfile => _donorProfile;
  List<DonorBadgeModel> get badges => _badges;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  BloodRequestModel? get incomingEmergencyRequest => _incomingEmergencyRequest;
  bool get isLoading => _isLoading;

  void _loadDonorData() {
    _donorProfile = _donorRepository.donorProfile;
    _badges = _donorRepository.allBadges;
    _leaderboard = _donorRepository.leaderboard;

    // Simulate an incoming emergency request for demonstration
    _incomingEmergencyRequest = BloodRequestModel(
      requestId: 'REQ-SOS-9912',
      patientId: 'user_patient_9',
      patientName: 'Kavita Joshi',
      patientPhone: '+91 98989 12345',
      bloodGroup: 'O+',
      units: 1,
      urgency: UrgencyLevel.critical,
      latitude: 18.5244,
      longitude: 73.8617,
      address: 'Jehangir Hospital, Emergency Trauma Care, Pune',
      status: RequestStatus.searching,
      notes: 'Emergency accident victim, immediate O+ blood required.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    );
    notifyListeners();
  }

  Future<void> toggleAvailability(bool isAvailable) async {
    _donorProfile = _donorProfile.copyWith(availability: isAvailable);
    await _donorRepository.toggleAvailability(isAvailable);
    notifyListeners();
  }

  /// Accept incoming emergency request
  Future<void> acceptEmergencyRequest() async {
    if (_incomingEmergencyRequest == null) return;
    _isLoading = true;
    notifyListeners();

    // Lock source
    await _matchingEngine.lockConfirmedSource(
      request: _incomingEmergencyRequest!,
      candidate: MatchCandidate(
        type: 'donor',
        id: _donorProfile.donorId,
        name: 'Dr. Ananya Verma',
        bloodGroup: 'O+',
        distanceKm: 2.4,
        estimatedEtaMinutes: 8,
      ),
    );

    // Award bonus points for emergency response
    await _donorRepository.addPoints(150);
    _donorProfile = _donorRepository.donorProfile;

    _incomingEmergencyRequest = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Reject incoming request -> Triggers immediate fallback to hospital inventory
  Future<void> rejectEmergencyRequest() async {
    if (_incomingEmergencyRequest == null) return;
    _isLoading = true;
    notifyListeners();

    // Trigger fallback source search
    await _matchingEngine.activateFallbackSource(
      request: _incomingEmergencyRequest!,
    );

    _incomingEmergencyRequest = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Submit eligibility assessment questionnaire
  void submitEligibilityCheck({
    required bool weightAbove50,
    required bool noRecentTattoo,
    required bool hemoglobinNormal,
    required bool noActiveMedication,
  }) {
    final eligible = weightAbove50 &&
        noRecentTattoo &&
        hemoglobinNormal &&
        noActiveMedication;

    _donorProfile = _donorProfile.copyWith(
      isEligible: eligible,
      healthChecklist: {
        'weightAbove50kg': weightAbove50,
        'noRecentTattoo': noRecentTattoo,
        'hemoglobinNormal': hemoglobinNormal,
        'noActiveMedication': noActiveMedication,
      },
    );
    notifyListeners();
  }
}
