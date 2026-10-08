import 'package:flutter/material.dart';
import 'ambulance_dashboard_screen.dart';
import 'ambulance_navigation_screen.dart';
import 'ambulance_delivery_confirmation_screen.dart';
import 'ambulance_trip_history_screen.dart';

/// Bottom Navigation Shell for Ambulance Operator Module
class AmbulanceMainNavigation extends StatefulWidget {
  final int initialIndex;
  const AmbulanceMainNavigation({super.key, this.initialIndex = 0});

  @override
  State<AmbulanceMainNavigation> createState() =>
      _AmbulanceMainNavigationState();
}

class _AmbulanceMainNavigationState extends State<AmbulanceMainNavigation> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    AmbulanceDashboardScreen(),
    AmbulanceNavigationScreen(),
    AmbulanceDeliveryConfirmationScreen(),
    AmbulanceTripHistoryScreen(),
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
            label: 'Trip Mission',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation_outlined),
            activeIcon: Icon(Icons.navigation_rounded),
            label: 'GPS Route',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_outlined),
            activeIcon: Icon(Icons.verified_rounded),
            label: 'Hand-off OTP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Run History',
          ),
        ],
      ),
    );
  }
}
