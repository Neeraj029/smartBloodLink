import 'package:flutter/material.dart';
import '../models/audit_log_model.dart';
import '../models/user_model.dart';
import '../repositories/admin_repository.dart';

/// Administrator ViewModel managing platform oversight, user verification, and audit logs
class AdminProvider with ChangeNotifier {
  final AdminRepository _adminRepository;

  List<UserModel> _users = [];
  List<AuditLogModel> _auditLogs = [];
  Map<String, int> _metrics = {};
  bool _isLoading = false;

  AdminProvider({AdminRepository? adminRepository})
      : _adminRepository = adminRepository ?? AdminRepository() {
    loadAdminData();
  }

  List<UserModel> get users => _users;
  List<AuditLogModel> get auditLogs => _auditLogs;
  Map<String, int> get metrics => _metrics;
  bool get isLoading => _isLoading;

  void loadAdminData() {
    _users = _adminRepository.allUsers;
    _auditLogs = _adminRepository.auditLogs;
    _metrics = _adminRepository.getGlobalSystemMetrics();
    notifyListeners();
  }

  Future<void> updateUserStatus(String uid, String status, {String? reason}) async {
    _isLoading = true;
    notifyListeners();

    await _adminRepository.setUserStatus(uid: uid, status: status, reason: reason);
    loadAdminData();

    _isLoading = false;
    notifyListeners();
  }
}
