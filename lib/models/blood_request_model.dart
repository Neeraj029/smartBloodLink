import '../utils/constants.dart';

/// Blood Request data model
class BloodRequestModel {
  final String requestId;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String bloodGroup;
  final int units;
  final UrgencyLevel urgency;
  final double latitude;
  final double longitude;
  final String address;
  final RequestStatus status;
  final String? assignedSourceType; // 'donor' or 'hospital'
  final String? assignedSourceId;
  final String? assignedSourceName;
  final String? assignedBagId;
  final String? ambulanceTripId;
  final String? notes;
  final DateTime createdAt;
  final DateTime? lockedAt;
  final DateTime? deliveredAt;

  BloodRequestModel({
    required this.requestId,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.bloodGroup,
    required this.units,
    required this.urgency,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.status = RequestStatus.searching,
    this.assignedSourceType,
    this.assignedSourceId,
    this.assignedSourceName,
    this.assignedBagId,
    this.ambulanceTripId,
    this.notes,
    DateTime? createdAt,
    this.lockedAt,
    this.deliveredAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BloodRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return BloodRequestModel(
      requestId: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      patientPhone: map['patientPhone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? 'O+',
      units: map['units'] ?? 1,
      urgency: UrgencyLevel.values.firstWhere(
        (u) => u.name == (map['urgency'] ?? 'routine'),
        orElse: () => UrgencyLevel.routine,
      ),
      latitude: (map['location']?['lat'] as num?)?.toDouble() ?? 18.5204,
      longitude: (map['location']?['lng'] as num?)?.toDouble() ?? 73.8567,
      address: map['location']?['address'] ?? 'City Center',
      status: RequestStatus.values.firstWhere(
        (s) => s.name == (map['status'] ?? 'searching'),
        orElse: () => RequestStatus.searching,
      ),
      assignedSourceType: map['assignedSourceType'],
      assignedSourceId: map['assignedSourceId'],
      assignedSourceName: map['assignedSourceName'],
      assignedBagId: map['assignedBagId'],
      ambulanceTripId: map['ambulanceTripId'],
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      lockedAt: map['lockedAt'] != null
          ? DateTime.tryParse(map['lockedAt'])
          : null,
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.tryParse(map['deliveredAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'bloodGroup': bloodGroup,
      'units': units,
      'urgency': urgency.name,
      'location': {
        'lat': latitude,
        'lng': longitude,
        'address': address,
      },
      'status': status.name,
      'assignedSourceType': assignedSourceType,
      'assignedSourceId': assignedSourceId,
      'assignedSourceName': assignedSourceName,
      'assignedBagId': assignedBagId,
      'ambulanceTripId': ambulanceTripId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'lockedAt': lockedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  BloodRequestModel copyWith({
    RequestStatus? status,
    String? assignedSourceType,
    String? assignedSourceId,
    String? assignedSourceName,
    String? assignedBagId,
    String? ambulanceTripId,
    DateTime? lockedAt,
    DateTime? deliveredAt,
  }) {
    return BloodRequestModel(
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
      status: status ?? this.status,
      assignedSourceType: assignedSourceType ?? this.assignedSourceType,
      assignedSourceId: assignedSourceId ?? this.assignedSourceId,
      assignedSourceName: assignedSourceName ?? this.assignedSourceName,
      assignedBagId: assignedBagId ?? this.assignedBagId,
      ambulanceTripId: ambulanceTripId ?? this.ambulanceTripId,
      notes: notes,
      createdAt: createdAt,
      lockedAt: lockedAt ?? this.lockedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
