import 'package:flutter_test/flutter_test.dart';
import 'package:smart_blood_link/utils/distance_calculator.dart';

void main() {
  group('Distance Calculator Tests', () {
    test('Distance between identical coordinates is 0', () {
      final distance = DistanceCalculator.calculateDistance(
        lat1: 18.5204,
        lon1: 73.8567,
        lat2: 18.5204,
        lon2: 73.8567,
      );
      expect(distance, closeTo(0.0, 0.001));
    });

    test('Distance between Pune Center and KEM Hospital is approximately 2.5 km', () {
      // Pune Shaniwar Wada: 18.5196, 73.8553
      // KEM Hospital Pune: 18.5236, 73.8742
      final distance = DistanceCalculator.calculateDistance(
        lat1: 18.5196,
        lon1: 73.8553,
        lat2: 18.5236,
        lon2: 73.8742,
      );
      expect(distance, greaterThan(1.5));
      expect(distance, lessThan(3.5));
    });

    test('ETA calculation returns reasonable minutes at 45 km/h', () {
      // 15 km at 45 km/h = 20 minutes
      final eta = DistanceCalculator.estimateEtaMinutes(
        distanceKm: 15.0,
        averageSpeedKmh: 45.0,
      );
      expect(eta, equals(20));
    });

    test('ETA for 0 distance returns 0', () {
      final eta = DistanceCalculator.estimateEtaMinutes(distanceKm: 0.0);
      expect(eta, equals(0));
    });

    test('ETA for very small non-zero distance returns at least 1 minute', () {
      final eta = DistanceCalculator.estimateEtaMinutes(distanceKm: 0.1);
      expect(eta, equals(1));
    });
  });
}
