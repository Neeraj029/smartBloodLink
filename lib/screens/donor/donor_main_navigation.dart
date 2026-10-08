import 'package:flutter/material.dart';
import 'donor_dashboard_screen.dart';
import 'incoming_request_screen.dart';
import 'donor_rewards_screen.dart';
import 'donor_leaderboard_screen.dart';
import 'donor_eligibility_screen.dart';

/// Bottom Navigation Shell for Donor Module
class DonorMainNavigation extends StatefulWidget {
  final int initialIndex;
  const DonorMainNavigation({super.key, this.initialIndex = 0});

  @override
  State<DonorMainNavigation> createState() => _DonorMainNavigationState();
}

class _DonorMainNavigationState extends State<DonorMainNavigation> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DonorDashboardScreen(),
    IncomingRequestScreen(),
    DonorRewardsScreen(),
    DonorLeaderboardScreen(),
    DonorEligibilityScreen(),
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
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency_outlined),
            activeIcon: Icon(Icons.emergency_rounded),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.military_tech_outlined),
            activeIcon: Icon(Icons.military_tech_rounded),
            label: 'Rewards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard_rounded),
            label: 'Rankings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_outlined),
            activeIcon: Icon(Icons.health_and_safety_rounded),
            label: 'Eligibility',
          ),
        ],
      ),
    );
  }
}
