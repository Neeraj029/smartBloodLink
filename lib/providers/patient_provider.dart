import 'package:flutter/material.dart';
import '../models/blood_request_model.dart';
import '../repositories/request_repository.dart';
import '../services/matching_engine_service.dart';
import '../utils/constants.dart';

/// Patient ViewModel managing blood requests, live tracking, and emergency matching
class PatientProvider with ChangeNotifier {
  final RequestRepository _requestRepository;
  final MatchingEngineService _matchingEngine;

  bool _isLoading = false;
  bool _isSearching = false;
  BloodRequestModel? _activeRequest;
  List<BloodRequestModel> _history = [];
  Map<String, List<MatchCandidate>> _matchingCandidates = {};

  PatientProvider({
    RequestRepository? requestRepository,
    MatchingEngineService? matchingEngine,
  })  : _requestRepository = requestRepository ?? RequestRepository(),
        _matchingEngine = matchingEngine ?? MatchingEngineService() {
    loadPatientData('user_patient_1');
  }

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  BloodRequestModel? get activeRequest => _activeRequest;
  List<BloodRequestModel> get history => _history;
  Map<String, List<MatchCandidate>> get matchingCandidates =>
      _matchingCandidates;

  void loadPatientData(String patientId) {
    _activeRequest = _requestRepository.getActiveRequest(patientId);
    _history = _requestRepository.getRequestsForPatient(patientId);
    notifyListeners();
  }

  /// Create Emergency Blood Request and immediately trigger parallel matching
  Future<BloodRequestModel> createEmergencyRequest({
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String bloodGroup,
    required int units,
    required UrgencyLevel urgency,
    required double latitude,
    required double longitude,
    required String address,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final request = await _requestRepository.createRequest(
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      bloodGroup: bloodGroup,
      units: units,
      urgency: urgency,
      latitude: latitude,
      longitude: longitude,
      address: address,
      notes: notes,
    );

    _activeRequest = request;
    _history.insert(0, request);
    _isLoading = false;
    _isSearching = true;
    notifyListeners();

    // Trigger Parallel Matching Engine
    _runMatchingProcess(request);

    return request;
  }

  Future<void> _runMatchingProcess(BloodRequestModel request) async {
    _matchingCandidates = await _matchingEngine.searchParallelCandidates(
      bloodGroup: request.bloodGroup,
      units: request.units,
      lat: request.latitude,
      lng: request.longitude,
    );

    notifyListeners();

    // Check if hospital candidates exist first for immediate stock locking
    final hospitals = _matchingCandidates['hospital'];
    final donors = _matchingCandidates['donor'];

    MatchCandidate? chosen;
    if (hospitals != null && hospitals.isNotEmpty) {
      chosen = hospitals.first;
    } else if (donors != null && donors.isNotEmpty) {
      chosen = donors.first;
    }

    if (chosen != null) {
      final locked = await _matchingEngine.lockConfirmedSource(
        request: request,
        candidate: chosen,
      );

      // Progress status to Ambulance Assigned after lock
      await Future.delayed(const Duration(seconds: 2));
      final assigned = locked.copyWith(
        status: RequestStatus.ambulanceAssigned,
        ambulanceTripId: 'TRIP-701',
      );

      _activeRequest = assigned;
      _requestRepository.updateRequestStatus(
        assigned.requestId,
        RequestStatus.ambulanceAssigned,
      );
    }

    _isSearching = false;
    notifyListeners();
  }

  /// Manually advance step for simulation / testing
  void advanceTrackingStep() {
    if (_activeRequest == null) return;
    final currentStatus = _activeRequest!.status;
    RequestStatus next;
    switch (currentStatus) {
      case RequestStatus.searching:
        next = RequestStatus.sourceLocked;
        break;
      case RequestStatus.sourceLocked:
        next = RequestStatus.ambulanceAssigned;
        break;
      case RequestStatus.ambulanceAssigned:
        next = RequestStatus.inTransit;
        break;
      case RequestStatus.inTransit:
        next = RequestStatus.delivered;
        break;
      default:
        return;
    }
    _activeRequest = _activeRequest!.copyWith(status: next);
    _requestRepository.updateRequestStatus(_activeRequest!.requestId, next);
    notifyListeners();
  }

  void cancelActiveRequest() {
    if (_activeRequest == null) return;
    _activeRequest =
        _activeRequest!.copyWith(status: RequestStatus.cancelled);
    _requestRepository.updateRequestStatus(
      _activeRequest!.requestId,
      RequestStatus.cancelled,
    );
    notifyListeners();
  }
}
