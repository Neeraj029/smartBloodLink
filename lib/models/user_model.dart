import '../utils/constants.dart';

/// User profile model for all five roles
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String bloodGroup;
  final UserRole role;
  final bool verified;
  final String status; // 'approved', 'pending', 'suspended', 'rejected'
  final String? organizationOrVehicle; // Hospital name or vehicle reg
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.bloodGroup,
    required this.role,
    this.verified = true,
    this.status = 'approved',
    this.organizationOrVehicle,
    this.fcmToken,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? 'O+',
      role: UserRole.values.firstWhere(
        (r) => r.name == (map['role'] ?? 'patient'),
        orElse: () => UserRole.patient,
      ),
      verified: map['verified'] ?? true,
      status: map['status'] ?? 'approved',
      organizationOrVehicle: map['organizationOrVehicle'],
      fcmToken: map['fcmToken'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'role': role.name,
      'verified': verified,
      'status': status,
      'organizationOrVehicle': organizationOrVehicle,
      'fcmToken': fcmToken,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? bloodGroup,
    bool? verified,
    String? status,
    String? organizationOrVehicle,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      role: role,
      verified: verified ?? this.verified,
      status: status ?? this.status,
      organizationOrVehicle:
          organizationOrVehicle ?? this.organizationOrVehicle,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
