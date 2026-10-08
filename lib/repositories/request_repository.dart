import '../models/blood_request_model.dart';
import '../services/mock_data_service.dart';
import '../utils/constants.dart';

/// Repository for emergency blood requests and status tracking
class RequestRepository {
  List<BloodRequestModel> get allRequests =>
      List.unmodifiable(MockDataService.initialRequests);

  List<BloodRequestModel> getRequestsForPatient(String patientId) {
    return MockDataService.initialRequests
        .where((r) => r.patientId == patientId)
        .toList();
  }

  BloodRequestModel? getActiveRequest(String patientId) {
    try {
      return MockDataService.initialRequests.firstWhere(
        (r) =>
            r.patientId == patientId &&
            r.status != RequestStatus.delivered &&
            r.status != RequestStatus.cancelled,
      );
    } catch (_) {
      return null;
    }
  }

  Future<BloodRequestModel> createRequest({
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
    final requestId =
        'REQ-EMERG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final newRequest = BloodRequestModel(
      requestId: requestId,
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      bloodGroup: bloodGroup,
      units: units,
      urgency: urgency,
      latitude: latitude,
      longitude: longitude,
      address: address,
      status: RequestStatus.searching,
      notes: notes,
      createdAt: DateTime.now(),
    );

    MockDataService.initialRequests.insert(0, newRequest);
    return newRequest;
  }

  Future<void> updateRequestStatus(
    String requestId,
    RequestStatus newStatus,
  ) async {
    final index = MockDataService.initialRequests
        .indexWhere((r) => r.requestId == requestId);
    if (index != -1) {
      MockDataService.initialRequests[index] =
          MockDataService.initialRequests[index].copyWith(status: newStatus);
    }
  }
}
