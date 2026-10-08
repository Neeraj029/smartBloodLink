import 'package:flutter_test/flutter_test.dart';
import 'package:smart_blood_link/models/inventory_item_model.dart';
import 'package:smart_blood_link/services/mock_data_service.dart';
import 'package:smart_blood_link/services/rfid_service.dart';
import 'package:smart_blood_link/utils/constants.dart';

void main() {
  group('RFID Service & Blood Bag Provenance Tests', () {
    late RfidService rfidService;

    setUp(() {
      rfidService = RfidService();
    });

    test('Scanning existing RFID tag finds the correct blood bag', () async {
      final existingBag = MockDataService.initialInventory.first;
      final scanned = await rfidService.scanTag(existingBag.rfidTag);

      expect(scanned, isNotNull);
      expect(scanned!.bagId, equals(existingBag.bagId));
      expect(scanned.bloodGroup, equals(existingBag.bloodGroup));
    });

    test('Scanning non-existent RFID tag returns null', () async {
      final scanned = await rfidService.scanTag('RFID-UNKNOWN-9999');
      expect(scanned, isNull);
    });

    test('Updating bag status to reserved updates the record', () async {
      final bag = MockDataService.initialInventory.first;
      final updated = await rfidService.updateBagStatus(
        bagId: bag.bagId,
        newStatus: BagStatus.reserved,
        notes: 'Reserved for emergency request',
      );

      expect(updated.status, equals(BagStatus.reserved));
      expect(updated.notes, equals('Reserved for emergency request'));
    });

    test('Registering a new blood bag adds it to inventory with RFID', () async {
      final initialCount = MockDataService.initialInventory.length;
      final newBag = await rfidService.registerNewBag(
        hospitalId: 'user_hospital_1',
        hospitalName: 'City Apex Blood Center',
        bloodGroup: 'B-',
        units: 1,
        rfidTag: 'RFID-NEW-5555',
        collectionDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 35)),
      );

      expect(newBag.bagId, isNotEmpty);
      expect(newBag.rfidTag, equals('RFID-NEW-5555'));
      expect(newBag.bloodGroup, equals('B-'));
      expect(newBag.status, equals(BagStatus.stored));
      expect(MockDataService.initialInventory.length, equals(initialCount + 1));
    });

    test('Attempting to reactivate discarded blood unit throws an exception', () async {
      // Find or create a discarded bag
      final bag = MockDataService.initialInventory.first;
      await rfidService.updateBagStatus(
        bagId: bag.bagId,
        newStatus: BagStatus.discarded,
      );

      // Attempting to move from discarded to stored must fail
      expect(
        () => rfidService.updateBagStatus(
          bagId: bag.bagId,
          newStatus: BagStatus.stored,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
