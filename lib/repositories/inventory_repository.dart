import '../models/inventory_item_model.dart';
import '../services/mock_data_service.dart';
import '../utils/constants.dart';

/// Repository for hospital blood bank inventory and RFID records
class InventoryRepository {
  List<BloodBagModel> get allBags =>
      List.unmodifiable(MockDataService.initialInventory);

  List<BloodBagModel> getBagsForHospital(String hospitalId) {
    return MockDataService.initialInventory
        .where((b) => b.hospitalId == hospitalId)
        .toList();
  }

  Map<String, int> getStockCountByBloodGroup(String hospitalId) {
    final counts = <String, int>{};
    for (final group in BloodConstants.groups) {
      counts[group] = 0;
    }

    for (final bag in MockDataService.initialInventory) {
      if (bag.hospitalId == hospitalId &&
          bag.status == BagStatus.stored &&
          !bag.isExpired) {
        counts[bag.bloodGroup] = (counts[bag.bloodGroup] ?? 0) + bag.units;
      }
    }
    return counts;
  }

  int getTotalAvailableUnits(String hospitalId) {
    return MockDataService.initialInventory
        .where((b) =>
            b.hospitalId == hospitalId &&
            b.status == BagStatus.stored &&
            !b.isExpired)
        .fold(0, (sum, b) => sum + b.units);
  }

  List<String> getLowStockGroups(String hospitalId, {int threshold = 3}) {
    final stock = getStockCountByBloodGroup(hospitalId);
    final lowStock = <String>[];
    stock.forEach((group, count) {
      if (count < threshold) {
        lowStock.add(group);
      }
    });
    return lowStock;
  }
}
