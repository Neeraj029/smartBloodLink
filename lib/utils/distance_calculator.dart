import 'dart:math';

/// Utility to calculate geo distances and estimated arrival times
class DistanceCalculator {
  DistanceCalculator._();

  static const double earthRadiusKm = 6371.0;

  /// Haversine distance in kilometers
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculates estimated time of arrival (ETA) in minutes
  /// Assuming average emergency vehicle speed of 45 km/h in city traffic
  static int estimateEtaMinutes({
    required double distanceKm,
    double averageSpeedKmh = 45.0,
  }) {
    if (distanceKm <= 0) return 0;
    final hours = distanceKm / averageSpeedKmh;
    final minutes = (hours * 60).round();
    return minutes < 1 ? 1 : minutes;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
