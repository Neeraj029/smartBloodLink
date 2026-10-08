import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

/// Repository abstracting user authentication and account credentials
class AuthRepository {
  final AuthService _authService;
  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Stream<UserModel?> get authState => _authService.authStateChanges;
  UserModel? get currentUser => _authService.currentUser;

  Future<UserModel> login({required String email, required String password}) =>
      _authService.login(email: email, password: password);

  Future<UserModel> loginAsDemoRole(UserRole role) =>
      _authService.loginAsDemoRole(role);

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String bloodGroup,
    required UserRole role,
    String? organizationOrVehicle,
  }) =>
      _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        bloodGroup: bloodGroup,
        role: role,
        organizationOrVehicle: organizationOrVehicle,
      );

  Future<bool> verifyOtp({required String phone, required String otp}) =>
      _authService.verifyOtp(phone: phone, otp: otp);

  Future<bool> resetPassword(String email) => _authService.resetPassword(email);

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? bloodGroup,
    String? organizationOrVehicle,
  }) =>
      _authService.updateProfile(
        name: name,
        phone: phone,
        bloodGroup: bloodGroup,
        organizationOrVehicle: organizationOrVehicle,
      );

  Future<void> signOut() => _authService.signOut();
}
