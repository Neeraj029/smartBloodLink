import '../models/ambulance_trip_model.dart';
import '../services/ambulance_tracking_service.dart';

/// Repository for ambulance dispatch, GPS tracking, and delivery OTP
class AmbulanceRepository {
  final AmbulanceTrackingService _service;
  AmbulanceRepository({AmbulanceTrackingService? service})
      : _service = service ?? AmbulanceTrackingService();

  Stream<AmbulanceTripModel> get tripStream => _service.tripStream;
  AmbulanceTripModel get currentTrip => _service.currentTrip;

  Future<void> updateTripStatus(String status) =>
      _service.updateTripStatus(status);

  Future<bool> verifyAndCompleteDelivery(String otp) =>
      _service.verifyAndCompleteDelivery(otp);
}
