/// Security and operational audit log model
class AuditLogModel {
  final String logId;
  final String actorId;
  final String actorName;
  final String actorRole;
  final String action;
  final String entityType;
  final String entityId;
  final String details;
  final String severity; // 'Info', 'Warning', 'Critical'
  final DateTime timestamp;

  AuditLogModel({
    required this.logId,
    required this.actorId,
    required this.actorName,
    required this.actorRole,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.details,
    this.severity = 'Info',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AuditLogModel.fromMap(Map<String, dynamic> map, String id) {
    return AuditLogModel(
      logId: id,
      actorId: map['actorId'] ?? '',
      actorName: map['actorName'] ?? '',
      actorRole: map['actorRole'] ?? '',
      action: map['action'] ?? '',
      entityType: map['entityType'] ?? '',
      entityId: map['entityId'] ?? '',
      details: map['details'] ?? '',
      severity: map['severity'] ?? 'Info',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'actorId': actorId,
      'actorName': actorName,
      'actorRole': actorRole,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'details': details,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
