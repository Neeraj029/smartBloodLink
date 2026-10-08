import 'package:flutter/material.dart';
import '../models/inventory_item_model.dart';
import '../models/iot_sensor_model.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/iot_repository.dart';
import '../services/rfid_service.dart';
import '../utils/constants.dart';

/// Hospital Staff ViewModel managing stock, RFID bag tracking, and IoT cold-chain safety
class HospitalProvider with ChangeNotifier {
  final InventoryRepository _inventoryRepository;
  final IotRepository _iotRepository;
  final RfidService _rfidService;

  List<BloodBagModel> _bags = [];
  Map<String, int> _stockCounts = {};
  List<String> _lowStockGroups = [];
  double _currentTemp = 4.0;
  bool _isTempSafe = true;
  String? _tempAlertMessage;
  BloodBagModel? _lastScannedBag;
  bool _isScanning = false;
  String? _scanError;

  HospitalProvider({
    InventoryRepository? inventoryRepository,
    IotRepository? iotRepository,
    RfidService? rfidService,
  })  : _inventoryRepository = inventoryRepository ?? InventoryRepository(),
        _iotRepository = iotRepository ?? IotRepository(),
        _rfidService = rfidService ?? RfidService() {
    _loadHospitalData();
    _subscribeToIot();
  }

  List<BloodBagModel> get bags => _bags;
  Map<String, int> get stockCounts => _stockCounts;
  List<String> get lowStockGroups => _lowStockGroups;
  int get totalUnits =>
      _inventoryRepository.getTotalAvailableUnits('user_hospital_1');
  double get currentTemperature => _currentTemp;
  bool get isTempSafe => _isTempSafe;
  String? get tempAlertMessage => _tempAlertMessage;
  BloodBagModel? get lastScannedBag => _lastScannedBag;
  bool get isScanning => _isScanning;
  String? get scanError => _scanError;
  List<SensorReading> get recentReadings => _iotRepository.recentReadings;

  void _loadHospitalData() {
    _bags = _inventoryRepository.getBagsForHospital('user_hospital_1');
    _stockCounts =
        _inventoryRepository.getStockCountByBloodGroup('user_hospital_1');
    _lowStockGroups =
        _inventoryRepository.getLowStockGroups('user_hospital_1');
    notifyListeners();
  }

  void _subscribeToIot() {
    _iotRepository.telemetryStream.listen((reading) {
      _currentTemp = reading.temperature;
      _isTempSafe = reading.isSafe;
      notifyListeners();
    });

    _iotRepository.alertStream.listen((alert) {
      _tempAlertMessage = alert;
      notifyListeners();
    });
  }

  /// Scan an RFID Blood Bag Tag
  Future<bool> scanRfidTag(String rfidTag) async {
    _isScanning = true;
    _scanError = null;
    notifyListeners();

    final bag = await _rfidService.scanTag(rfidTag);
    _isScanning = false;

    if (bag != null) {
      _lastScannedBag = bag;
      notifyListeners();
      return true;
    } else {
      _scanError = 'No blood bag found for RFID: $rfidTag';
      notifyListeners();
      return false;
    }
  }

  /// Update bag status (e.g. Stored -> Issued, etc.)
  Future<void> updateBagStatus(String bagId, BagStatus newStatus) async {
    final updated = await _rfidService.updateBagStatus(
      bagId: bagId,
      newStatus: newStatus,
    );
    _lastScannedBag = updated;
    _loadHospitalData();
  }

  /// Register a new blood unit with RFID tag
  Future<void> addNewBloodUnit({
    required String bloodGroup,
    required int units,
    required String rfidTag,
    required DateTime collectionDate,
    required DateTime expiryDate,
    String? storageUnitName,
  }) async {
    await _rfidService.registerNewBag(
      hospitalId: 'user_hospital_1',
      hospitalName: 'City Apex Blood Center',
      bloodGroup: bloodGroup,
      units: units,
      rfidTag: rfidTag,
      collectionDate: collectionDate,
      expiryDate: expiryDate,
      storageUnitName: storageUnitName,
    );
    _loadHospitalData();
  }

  /// IoT Breach simulation for demonstration / grading
  void simulateHighTemperatureBreach() {
    _iotRepository.triggerSimulatedBreach(8.4);
  }

  /// Reset IoT temperature to safe state
  void resetTemperatureNormal() {
    _iotRepository.resetSafeNormal();
  }
}
