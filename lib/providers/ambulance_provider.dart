import 'package:flutter/material.dart';
import '../models/ambulance_trip_model.dart';
import '../repositories/ambulance_repository.dart';

/// Ambulance Operator ViewModel managing navigation, live GPS updates, and OTP handoff
class AmbulanceProvider with ChangeNotifier {
  final AmbulanceRepository _ambulanceRepository;

  late AmbulanceTripModel _currentTrip;
  bool _isVerifyingOtp = false;
  String? _otpError;

  AmbulanceProvider({AmbulanceRepository? ambulanceRepository})
      : _ambulanceRepository =
            ambulanceRepository ?? AmbulanceRepository() {
    _currentTrip = _ambulanceRepository.currentTrip;
    _ambulanceRepository.tripStream.listen((trip) {
      _currentTrip = trip;
      notifyListeners();
    });
  }

  AmbulanceTripModel get currentTrip => _currentTrip;
  bool get isVerifyingOtp => _isVerifyingOtp;
  String? get otpError => _otpError;

  Future<void> updateTripStatus(String status) async {
    await _ambulanceRepository.updateTripStatus(status);
  }

  Future<bool> verifyDeliveryOtp(String otp) async {
    _isVerifyingOtp = true;
    _otpError = null;
    notifyListeners();

    final success =
        await _ambulanceRepository.verifyAndCompleteDelivery(otp);
    _isVerifyingOtp = false;

    if (!success) {
      _otpError = 'Invalid recipient OTP. Please verify with the hospital/patient.';
    }
    notifyListeners();
    return success;
  }
}
