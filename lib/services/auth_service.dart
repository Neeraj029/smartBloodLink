import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'mock_data_service.dart';

/// Authentication Service managing authentication state, role verification, and demo modes
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser = MockDataService.initialUsers[0]; // Default to Patient
  final StreamController<UserModel?> _userStreamController =
      StreamController<UserModel?>.broadcast();

  Stream<UserModel?> get authStateChanges => _userStreamController.stream;
  UserModel? get currentUser => _currentUser;

  /// Quick login for testing any of the 5 roles instantly
  Future<UserModel> loginAsDemoRole(UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final demoUser = MockDataService.initialUsers.firstWhere(
      (u) => u.role == role,
      orElse: () => MockDataService.initialUsers[0],
    );
    _currentUser = demoUser;
    _userStreamController.add(_currentUser);
    return demoUser;
  }

  /// Standard Email & Password Login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final user = MockDataService.initialUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => throw Exception('User account not found with this email.'),
    );

    if (user.status == 'suspended') {
      throw Exception('This account has been suspended by system administrators.');
    }

    _currentUser = user;
    _userStreamController.add(_currentUser);
    return user;
  }

  /// Register new user with 6-digit OTP requirement
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String bloodGroup,
    required UserRole role,
    String? organizationOrVehicle,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final newUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      name: name.trim(),
      phone: phone.trim(),
      bloodGroup: bloodGroup,
      role: role,
      verified: role == UserRole.patient, // Donors & hospitals require admin approval
      status: (role == UserRole.hospital || role == UserRole.donor)
          ? 'pending'
          : 'approved',
      organizationOrVehicle: organizationOrVehicle,
      createdAt: DateTime.now(),
    );

    MockDataService.initialUsers.add(newUser);
    _currentUser = newUser;
    _userStreamController.add(_currentUser);
    return newUser;
  }

  /// Verify 6-digit OTP code
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Standard mock accepted OTPs: '123456' or any valid 6-digit number
    if (otp.length == 6) {
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(verified: true);
        _userStreamController.add(_currentUser);
      }
      return true;
    }
    return false;
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  /// Update current user profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? bloodGroup,
    String? organizationOrVehicle,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      bloodGroup: bloodGroup,
      organizationOrVehicle: organizationOrVehicle,
    );
    _userStreamController.add(_currentUser);
  }

  /// Sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _userStreamController.add(null);
  }
}
