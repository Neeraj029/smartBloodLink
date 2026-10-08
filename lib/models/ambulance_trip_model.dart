/// Model representing an ambulance dispatch mission
class AmbulanceTripModel {
  final String tripId;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String requestId;
  final String pickupHospitalName;
  final double pickupLat;
  final double pickupLng;
  final String destinationAddress;
  final double destLat;
  final double destLng;
  final double currentLat;
  final double currentLng;
  final String status; // 'dispatched', 'at_hospital', 'in_transit', 'delivered'
  final int etaMinutes;
  final double distanceRemainingKm;
  final String recipientOtp;
  final DateTime startedAt;
  final DateTime? deliveredAt;

  AmbulanceTripModel({
    required this.tripId,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleNumber,
    required this.requestId,
    required this.pickupHospitalName,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationAddress,
    required this.destLat,
    required this.destLng,
    required this.currentLat,
    required this.currentLng,
    this.status = 'dispatched',
    this.etaMinutes = 12,
    this.distanceRemainingKm = 6.4,
    required this.recipientOtp,
    DateTime? startedAt,
    this.deliveredAt,
  }) : startedAt = startedAt ?? DateTime.now();

  factory AmbulanceTripModel.fromMap(Map<String, dynamic> map, String id) {
    return AmbulanceTripModel(
      tripId: id,
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? 'Emergency Driver',
      driverPhone: map['driverPhone'] ?? '+91 98765 43210',
      vehicleNumber: map['vehicleNumber'] ?? 'MH 12 AB 1008',
      requestId: map['requestId'] ?? '',
      pickupHospitalName: map['pickupHospitalName'] ?? 'City Central Blood Bank',
      pickupLat: (map['pickupLocation']?['lat'] as num?)?.toDouble() ?? 18.5304,
      pickupLng: (map['pickupLocation']?['lng'] as num?)?.toDouble() ?? 73.8467,
      destinationAddress:
          map['destinationLocation']?['address'] ?? 'General Hospital ICU',
      destLat:
          (map['destinationLocation']?['lat'] as num?)?.toDouble() ?? 18.5104,
      destLng:
          (map['destinationLocation']?['lng'] as num?)?.toDouble() ?? 73.8667,
      currentLat: (map['location']?['lat'] as num?)?.toDouble() ?? 18.5254,
      currentLng: (map['location']?['lng'] as num?)?.toDouble() ?? 73.8517,
      status: map['status'] ?? 'dispatched',
      etaMinutes: map['etaMinutes'] ?? 12,
      distanceRemainingKm:
          (map['distanceRemainingKm'] as num?)?.toDouble() ?? 6.4,
      recipientOtp: map['recipientOtp'] ?? '482910',
      startedAt: map['startedAt'] != null
          ? DateTime.tryParse(map['startedAt']) ?? DateTime.now()
          : DateTime.now(),
      deliveredAt: map['deliveredAt'] != null
          ? DateTime.tryParse(map['deliveredAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleNumber': vehicleNumber,
      'requestId': requestId,
      'pickupHospitalName': pickupHospitalName,
      'pickupLocation': {
        'lat': pickupLat,
        'lng': pickupLng,
      },
      'destinationLocation': {
        'address': destinationAddress,
        'lat': destLat,
        'lng': destLng,
      },
      'location': {
        'lat': currentLat,
        'lng': currentLng,
      },
      'status': status,
      'etaMinutes': etaMinutes,
      'distanceRemainingKm': distanceRemainingKm,
      'recipientOtp': recipientOtp,
      'startedAt': startedAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  AmbulanceTripModel copyWith({
    double? currentLat,
    double? currentLng,
    String? status,
    int? etaMinutes,
    double? distanceRemainingKm,
    DateTime? deliveredAt,
  }) {
    return AmbulanceTripModel(
      tripId: tripId,
      driverId: driverId,
      driverName: driverName,
      driverPhone: driverPhone,
      vehicleNumber: vehicleNumber,
      requestId: requestId,
      pickupHospitalName: pickupHospitalName,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      destinationAddress: destinationAddress,
      destLat: destLat,
      destLng: destLng,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      status: status ?? this.status,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceRemainingKm: distanceRemainingKm ?? this.distanceRemainingKm,
      recipientOtp: recipientOtp,
      startedAt: startedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
