import '../models/audit_log_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_service.dart';
import '../utils/constants.dart';

/// Repository for administrative oversight, audit logs, and account moderation
class AdminRepository {
  List<AuditLogModel> get auditLogs =>
      List.unmodifiable(MockDataService.initialAuditLogs);

  List<UserModel> get allUsers =>
      List.unmodifiable(MockDataService.initialUsers);

  Future<void> setUserStatus({
    required String uid,
    required String status,
    String? reason,
  }) async {
    final index = MockDataService.initialUsers.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      final user = MockDataService.initialUsers[index];
      MockDataService.initialUsers[index] = user.copyWith(status: status);

      // Record audit log
      MockDataService.initialAuditLogs.insert(
        0,
        AuditLogModel(
          logId: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
          actorId: 'admin_1',
          actorName: 'System Administrator',
          actorRole: 'admin',
          action: 'USER_STATUS_${status.toUpperCase()}',
          entityType: 'User',
          entityId: uid,
          details: 'Account of ${user.name} (${user.role.displayName}) updated to $status. Reason: ${reason ?? "Standard audit check"}',
          severity: status == 'suspended' ? 'Warning' : 'Info',
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Map<String, int> getGlobalSystemMetrics() {
    final totalUsers = MockDataService.initialUsers.length;
    final totalDonors = MockDataService.initialUsers
        .where((u) => u.role == UserRole.donor)
        .length;
    final totalHospitals = MockDataService.initialUsers
        .where((u) => u.role == UserRole.hospital)
        .length;
    final totalUnitsInStock = MockDataService.initialInventory
        .where((b) => b.status == BagStatus.stored && !b.isExpired)
        .fold(0, (sum, b) => sum + b.units);
    final totalRequests = MockDataService.initialRequests.length;

    return {
      'totalUsers': totalUsers,
      'totalDonors': totalDonors,
      'totalHospitals': totalHospitals,
      'totalUnitsInStock': totalUnitsInStock,
      'totalRequests': totalRequests,
      'averageResponseSec': 48,
    };
  }
}
