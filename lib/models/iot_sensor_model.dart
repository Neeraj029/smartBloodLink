import '../utils/constants.dart';

/// IoT Cold-Chain Sensor Telemetry Reading
class SensorReading {
  final String readingId;
  final String deviceId;
  final String storageUnitName;
  final String hospitalId;
  final double temperature;
  final DateTime timestamp;
  final bool isSafe;
  final bool isSensorFault;

  SensorReading({
    required this.readingId,
    required this.deviceId,
    required this.storageUnitName,
    required this.hospitalId,
    required this.temperature,
    required this.timestamp,
    bool? isSafe,
    this.isSensorFault = false,
  }) : isSafe = isSafe ??
            (temperature >= BloodConstants.safeStorageTempMin &&
                temperature <= BloodConstants.safeStorageTempMax);

  factory SensorReading.fromMap(Map<String, dynamic> map, String id) {
    final temp = (map['temperature'] as num?)?.toDouble() ?? 4.0;
    return SensorReading(
      readingId: id,
      deviceId: map['deviceId'] ?? 'ESP32-FRIDGE-01',
      storageUnitName: map['storageUnitName'] ?? 'Blood Bank Main Fridge',
      hospitalId: map['hospitalId'] ?? '',
      temperature: temp,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isSafe: map['isSafe'] ??
          (temp >= BloodConstants.safeStorageTempMin &&
              temp <= BloodConstants.safeStorageTempMax),
      isSensorFault: map['isSensorFault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'readingId': readingId,
      'deviceId': deviceId,
      'storageUnitName': storageUnitName,
      'hospitalId': hospitalId,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
      'isSafe': isSafe,
      'isSensorFault': isSensorFault,
    };
  }
}
