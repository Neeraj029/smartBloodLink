import 'package:flutter/material.dart';
import 'hospital_dashboard_screen.dart';
import 'hospital_inventory_screen.dart';
import 'rfid_scanner_screen.dart';
import 'iot_temperature_screen.dart';
import 'hospital_requests_screen.dart';

/// Bottom Navigation Shell for Hospital Staff Module
class HospitalMainNavigation extends StatefulWidget {
  final int initialIndex;
  const HospitalMainNavigation({super.key, this.initialIndex = 0});

  @override
  State<HospitalMainNavigation> createState() => _HospitalMainNavigationState();
}

class _HospitalMainNavigationState extends State<HospitalMainNavigation> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HospitalDashboardScreen(),
    HospitalInventoryScreen(),
    RfidScannerScreen(),
    IotTemperatureScreen(),
    HospitalRequestsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'RFID Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.thermostat_outlined),
            activeIcon: Icon(Icons.thermostat_rounded),
            label: 'IoT Temp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency_outlined),
            activeIcon: Icon(Icons.emergency_rounded),
            label: 'Dispatch',
          ),
        ],
      ),
    );
  }
}
