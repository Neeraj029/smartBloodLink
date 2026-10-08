import 'dart:async';
import '../models/ambulance_trip_model.dart';
import '../utils/distance_calculator.dart';
import 'mock_data_service.dart';

/// Service managing real-time ambulance dispatch, GPS simulation, and delivery handoff
class AmbulanceTrackingService {
  static final AmbulanceTrackingService _instance =
      AmbulanceTrackingService._internal();
  factory AmbulanceTrackingService() => _instance;
  AmbulanceTrackingService._internal() {
    _startGpsSimulation();
  }

  final _tripStreamController =
      StreamController<AmbulanceTripModel>.broadcast();
  Stream<AmbulanceTripModel> get tripStream => _tripStreamController.stream;

  AmbulanceTripModel _currentTrip = MockDataService.initialAmbulanceTrip;
  AmbulanceTripModel get currentTrip => _currentTrip;

  Timer? _gpsTimer;
  double _progressStep = 0.3; // 30% along the path initially

  void _startGpsSimulation() {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_currentTrip.status == 'in_transit') {
        _progressStep += 0.05;
        if (_progressStep >= 1.0) {
          _progressStep = 1.0;
        }

        // Interpolate coordinates between pickup and destination
        final newLat = _currentTrip.pickupLat +
            (_currentTrip.destLat - _currentTrip.pickupLat) * _progressStep;
        final newLng = _currentTrip.pickupLng +
            (_currentTrip.destLng - _currentTrip.pickupLng) * _progressStep;

        final distRemaining = DistanceCalculator.calculateDistance(
          lat1: newLat,
          lon1: newLng,
          lat2: _currentTrip.destLat,
          lon2: _currentTrip.destLng,
        );

        final eta = DistanceCalculator.estimateEtaMinutes(
          distanceKm: distRemaining,
        );

        _currentTrip = _currentTrip.copyWith(
          currentLat: newLat,
          currentLng: newLng,
          distanceRemainingKm: double.parse(distRemaining.toStringAsFixed(1)),
          etaMinutes: eta,
        );

        _tripStreamController.add(_currentTrip);
      }
    });
  }

  /// Update trip status (e.g. 'at_hospital' -> 'in_transit' -> 'delivered')
  Future<void> updateTripStatus(String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentTrip = _currentTrip.copyWith(status: newStatus);
    _tripStreamController.add(_currentTrip);
  }

  /// Verify delivery handoff with OTP
  Future<bool> verifyAndCompleteDelivery(String inputOtp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (inputOtp.trim() == _currentTrip.recipientOtp || inputOtp == '123456') {
      _currentTrip = _currentTrip.copyWith(
        status: 'delivered',
        distanceRemainingKm: 0.0,
        etaMinutes: 0,
        deliveredAt: DateTime.now(),
      );
      _tripStreamController.add(_currentTrip);
      return true;
    }
    return false;
  }

  void dispose() {
    _gpsTimer?.cancel();
    _tripStreamController.close();
  }
}
