import 'package:flutter_test/flutter_test.dart';
import 'package:smart_blood_link/models/blood_request_model.dart';
import 'package:smart_blood_link/services/matching_engine_service.dart';
import 'package:smart_blood_link/utils/constants.dart';

void main() {
  group('Intelligent Parallel Matching Engine Tests', () {
    late MatchingEngineService matchingEngine;

    setUp(() {
      matchingEngine = MatchingEngineService();
    });

    test('Concurrent search returns candidate lists for hospital and donors', () async {
      final results = await matchingEngine.searchParallelCandidates(
        bloodGroup: 'O+',
        units: 1,
        lat: 18.5204,
        lng: 73.8567,
      );

      expect(results.containsKey('hospital'), isTrue);
      expect(results.containsKey('donor'), isTrue);

      final hospitalCandidates = results['hospital']!;
      expect(hospitalCandidates, isNotEmpty);

      // Verify that every matched hospital unit is compatible with O+ (i.e. O+ or O-)
      for (final candidate in hospitalCandidates) {
        expect(['O+', 'O-'].contains(candidate.bloodGroup), isTrue);
      }
    });

    test('Source locking locks hospital inventory and updates request', () async {
      final sampleRequest = BloodRequestModel(
        requestId: 'REQ-TEST-01',
        patientId: 'patient_1',
        patientName: 'Test Patient',
        patientPhone: '+91 99999 88888',
        bloodGroup: 'A+',
        units: 1,
        urgency: UrgencyLevel.urgent,
        latitude: 18.5204,
        longitude: 73.8567,
        address: 'Pune Test Location',
      );

      final results = await matchingEngine.searchParallelCandidates(
        bloodGroup: 'A+',
        units: 1,
        lat: 18.5204,
        lng: 73.8567,
      );

      final candidate = results['hospital']!.first;
      final locked = await matchingEngine.lockConfirmedSource(
        request: sampleRequest,
        candidate: candidate,
      );

      expect(locked.status, equals(RequestStatus.sourceLocked));
      expect(locked.assignedSourceType, equals('hospital'));
      expect(locked.assignedSourceId, equals(candidate.id));
      expect(locked.lockedAt, isNotNull);
    });
  });
}
