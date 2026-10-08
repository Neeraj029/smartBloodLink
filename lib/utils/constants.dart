import 'package:flutter/material.dart';

/// Supported User Roles in Smart BloodLink
enum UserRole {
  patient,
  donor,
  hospital,
  ambulance,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.donor:
        return 'Verified Donor';
      case UserRole.hospital:
        return 'Hospital Staff';
      case UserRole.ambulance:
        return 'Ambulance Operator';
      case UserRole.admin:
        return 'System Administrator';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.patient:
        return Icons.personal_injury_rounded;
      case UserRole.donor:
        return Icons.volunteer_activism_rounded;
      case UserRole.hospital:
        return Icons.local_hospital_rounded;
      case UserRole.ambulance:
        return Icons.emergency_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }
}

/// Request Urgency Level
enum UrgencyLevel {
  routine,
  urgent,
  critical;

  String get displayName {
    switch (this) {
      case UrgencyLevel.routine:
        return 'Routine';
      case UrgencyLevel.urgent:
        return 'Urgent (Within 4 hrs)';
      case UrgencyLevel.critical:
        return 'Critical Emergency (Immediate)';
    }
  }

  Color get color {
    switch (this) {
      case UrgencyLevel.routine:
        return const Color(0xFF1976D2);
      case UrgencyLevel.urgent:
        return const Color(0xFFF57C00);
      case UrgencyLevel.critical:
        return const Color(0xFFD32F2F);
    }
  }
}

/// Status of an Emergency Blood Request
enum RequestStatus {
  searching,
  donorFound,
  hospitalConfirmed,
  sourceLocked,
  ambulanceAssigned,
  inTransit,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case RequestStatus.searching:
        return 'Searching Sources';
      case RequestStatus.donorFound:
        return 'Donor Found';
      case RequestStatus.hospitalConfirmed:
        return 'Hospital Confirmed';
      case RequestStatus.sourceLocked:
        return 'Source Locked';
      case RequestStatus.ambulanceAssigned:
        return 'Ambulance Assigned';
      case RequestStatus.inTransit:
        return 'In Transit';
      case RequestStatus.delivered:
        return 'Delivered';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case RequestStatus.searching:
        return 0;
      case RequestStatus.donorFound:
      case RequestStatus.hospitalConfirmed:
        return 1;
      case RequestStatus.sourceLocked:
        return 2;
      case RequestStatus.ambulanceAssigned:
        return 3;
      case RequestStatus.inTransit:
        return 4;
      case RequestStatus.delivered:
        return 5;
      case RequestStatus.cancelled:
        return -1;
    }
  }
}

/// Status of a Blood Bag with RFID
enum BagStatus {
  stored,
  reserved,
  issued,
  transferred,
  discarded;

  String get displayName {
    switch (this) {
      case BagStatus.stored:
        return 'Stored (Available)';
      case BagStatus.reserved:
        return 'Reserved';
      case BagStatus.issued:
        return 'Issued';
      case BagStatus.transferred:
        return 'Transferred';
      case BagStatus.discarded:
        return 'Discarded';
    }
  }

  Color get color {
    switch (this) {
      case BagStatus.stored:
        return const Color(0xFF2E7D32);
      case BagStatus.reserved:
        return const Color(0xFFF57C00);
      case BagStatus.issued:
        return const Color(0xFF1976D2);
      case BagStatus.transferred:
        return const Color(0xFF7E57C2);
      case BagStatus.discarded:
        return const Color(0xFFD32F2F);
    }
  }
}

/// Universal Blood Groups
class BloodConstants {
  BloodConstants._();

  static const List<String> groups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  static const double safeStorageTempMin = 2.0; // °C
  static const double safeStorageTempMax = 6.0; // °C
  static const int gpsUpdateIntervalSeconds = 5;
  static const int minDaysBetweenDonations = 90;
}
