import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_user_verification_screen.dart';
import 'admin_global_stock_screen.dart';
import 'admin_audit_logs_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_system_settings_screen.dart';

/// Bottom Navigation Shell for Administrator Module
class AdminMainNavigation extends StatefulWidget {
  final int initialIndex;
  const AdminMainNavigation({super.key, this.initialIndex = 0});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminUserVerificationScreen(),
    AdminGlobalStockScreen(),
    AdminAuditLogsScreen(),
    AdminReportsScreen(),
    AdminSystemSettingsScreen(),
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
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_rounded),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_outlined),
            activeIcon: Icon(Icons.security_rounded),
            label: 'Audit Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_rounded),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
