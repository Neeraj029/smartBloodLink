import 'dart:async';
import '../models/inventory_item_model.dart';
import '../utils/constants.dart';
import 'mock_data_service.dart';

/// RFID Blood Bag Tracking & Provenance Service
class RfidService {
  static final RfidService _instance = RfidService._internal();
  factory RfidService() => _instance;
  RfidService._internal();

  /// Simulates scanning an RFID tag attached to a physical blood bag
  Future<BloodBagModel?> scanTag(String rfidTag) async {
    // Hardware scan simulation latency (0.6s)
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final bag = MockDataService.initialInventory.firstWhere(
        (b) =>
            b.rfidTag.toLowerCase() == rfidTag.trim().toLowerCase() ||
            b.bagId.toLowerCase() == rfidTag.trim().toLowerCase(),
      );
      return bag;
    } catch (_) {
      return null;
    }
  }

  /// Updates status of a scanned blood bag with validation rules
  Future<BloodBagModel> updateBagStatus({
    required String bagId,
    required BagStatus newStatus,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = MockDataService.initialInventory.indexWhere(
      (b) => b.bagId == bagId,
    );
    if (index == -1) {
      throw Exception('Blood bag record not found for ID: $bagId');
    }

    final currentBag = MockDataService.initialInventory[index];

    // Status transition validation
    if (currentBag.status == BagStatus.discarded && newStatus != BagStatus.discarded) {
      throw Exception('Discarded blood units cannot be reactivated into inventory.');
    }

    final updatedBag = currentBag.copyWith(
      status: newStatus,
      notes: notes ?? currentBag.notes,
    );

    MockDataService.initialInventory[index] = updatedBag;
    return updatedBag;
  }

  /// Registers a newly donated blood bag into hospital inventory with an RFID tag
  Future<BloodBagModel> registerNewBag({
    required String hospitalId,
    required String hospitalName,
    required String bloodGroup,
    required int units,
    required String rfidTag,
    required DateTime collectionDate,
    required DateTime expiryDate,
    String? storageUnitName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final bagId = 'BAG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final newBag = BloodBagModel(
      bagId: bagId,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      bloodGroup: bloodGroup,
      units: units,
      rfidTag: rfidTag.isEmpty ? 'RFID-$bagId' : rfidTag,
      collectionDate: collectionDate,
      expiryDate: expiryDate,
      status: BagStatus.stored,
      storageUnitName: storageUnitName ?? 'Cold Unit A (ESP32-FRIDGE-01)',
      currentTempCelsius: 3.9,
    );

    MockDataService.initialInventory.insert(0, newBag);
    return newBag;
  }
}
