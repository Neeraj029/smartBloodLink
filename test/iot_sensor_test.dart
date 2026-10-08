import 'package:flutter_test/flutter_test.dart';
import 'package:smart_blood_link/models/iot_sensor_model.dart';
import 'package:smart_blood_link/utils/constants.dart';

void main() {
  group('IoT Cold-Chain Storage Monitoring Tests', () {
    test('Temperature within 2.0°C - 6.0°C is marked safe', () {
      final safeReading1 = SensorReading(
        readingId: 'READ-01',
        deviceId: 'ESP32-FRIDGE-01',
        storageUnitName: 'Main Blood Bank Fridge',
        hospitalId: 'HOSP-01',
        temperature: 4.0,
        timestamp: DateTime.now(),
      );

      final safeReading2 = SensorReading(
        readingId: 'READ-02',
        deviceId: 'ESP32-FRIDGE-01',
        storageUnitName: 'Main Blood Bank Fridge',
        hospitalId: 'HOSP-01',
        temperature: 2.0, // boundary
        timestamp: DateTime.now(),
      );

      final safeReading3 = SensorReading(
        readingId: 'READ-03',
        deviceId: 'ESP32-FRIDGE-01',
        storageUnitName: 'Main Blood Bank Fridge',
        hospitalId: 'HOSP-01',
        temperature: 6.0, // boundary
        timestamp: DateTime.now(),
      );

      expect(safeReading1.isSafe, isTrue);
      expect(safeReading2.isSafe, isTrue);
      expect(safeReading3.isSafe, isTrue);
    });

    test('Temperature above 6.0°C is flagged unsafe (potential cold-chain breach)', () {
      final highTempReading = SensorReading(
        readingId: 'READ-WARN-01',
        deviceId: 'ESP32-FRIDGE-01',
        storageUnitName: 'Main Blood Bank Fridge',
        hospitalId: 'HOSP-01',
        temperature: 8.5,
        timestamp: DateTime.now(),
      );

      expect(highTempReading.isSafe, isFalse);
    });

    test('Temperature below 2.0°C is flagged unsafe (freezing risk for RBCs)', () {
      final freezingReading = SensorReading(
        readingId: 'READ-FREEZE-01',
        deviceId: 'ESP32-FRIDGE-01',
        storageUnitName: 'Main Blood Bank Fridge',
        hospitalId: 'HOSP-01',
        temperature: 0.8,
        timestamp: DateTime.now(),
      );

      expect(freezingReading.isSafe, isFalse);
    });

    test('Serialization toMap and fromMap preserves temperature and isSafe flags', () {
      final original = SensorReading(
        readingId: 'READ-MAP-01',
        deviceId: 'ESP32-02',
        storageUnitName: 'Emergency Storage Unit',
        hospitalId: 'HOSP-02',
        temperature: 9.2,
        timestamp: DateTime(2026, 10, 8, 12, 0),
        isSensorFault: true,
      );

      final map = original.toMap();
      final reconstructed = SensorReading.fromMap(map, 'READ-MAP-01');

      expect(reconstructed.readingId, equals('READ-MAP-01'));
      expect(reconstructed.temperature, equals(9.2));
      expect(reconstructed.isSafe, isFalse);
      expect(reconstructed.isSensorFault, isTrue);
    });
  });
}
