import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'patient_dashboard_screen.dart';
import 'create_blood_request_screen.dart';
import 'live_tracking_screen.dart';
import 'patient_request_history_screen.dart';
import 'hospital_blood_search_screen.dart';

/// Bottom Navigation Shell for Patient Module
class PatientMainNavigation extends StatefulWidget {
  final int initialIndex;
  const PatientMainNavigation({super.key, this.initialIndex = 0});

  @override
  State<PatientMainNavigation> createState() => _PatientMainNavigationState();
}

class _PatientMainNavigationState extends State<PatientMainNavigation> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    PatientDashboardScreen(),
    CreateBloodRequestScreen(),
    LiveTrackingScreen(),
    PatientRequestHistoryScreen(),
    HospitalBloodSearchScreen(),
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
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            activeIcon: Icon(Icons.add_circle_rounded),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me_outlined),
            activeIcon: Icon(Icons.near_me_rounded),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital_outlined),
            activeIcon: Icon(Icons.local_hospital_rounded),
            label: 'Blood Banks',
          ),
        ],
      ),
    );
  }
}
