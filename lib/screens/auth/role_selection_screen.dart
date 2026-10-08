import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_card.dart';
import '../patient/patient_main_navigation.dart';
import '../donor/donor_main_navigation.dart';
import '../hospital/hospital_main_navigation.dart';
import '../ambulance/ambulance_main_navigation.dart';
import '../admin/admin_main_navigation.dart';

/// Screen allowing instant role switcher to test and evaluate all 5 roles
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _navigateToRole(BuildContext context, UserRole role) {
    Widget target;
    switch (role) {
      case UserRole.patient:
        target = const PatientMainNavigation();
        break;
      case UserRole.donor:
        target = const DonorMainNavigation();
        break;
      case UserRole.hospital:
        target = const HospitalMainNavigation();
        break;
      case UserRole.ambulance:
        target = const AmbulanceMainNavigation();
        break;
      case UserRole.admin:
        target = const AdminMainNavigation();
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => target),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final roles = [
      {
        'role': UserRole.patient,
        'title': 'Patient / Requester',
        'subtitle': 'Request emergency blood units, track live ambulance delivery',
        'icon': Icons.personal_injury_rounded,
        'color': AppColors.primary,
      },
      {
        'role': UserRole.donor,
        'title': 'Verified Donor',
        'subtitle': 'Receive emergency requests, toggle availability, earn rewards',
        'icon': Icons.volunteer_activism_rounded,
        'color': const Color(0xFFE91E63),
      },
      {
        'role': UserRole.hospital,
        'title': 'Hospital Staff',
        'subtitle': 'Manage blood bank stock, scan RFID tags, monitor IoT cold chain',
        'icon': Icons.local_hospital_rounded,
        'color': const Color(0xFF1976D2),
      },
      {
        'role': UserRole.ambulance,
        'title': 'Ambulance Operator',
        'subtitle': 'Accept emergency dispatch, broadcast live GPS, verify handoff OTP',
        'icon': Icons.emergency_rounded,
        'color': const Color(0xFFF57C00),
      },
      {
        'role': UserRole.admin,
        'title': 'System Administrator',
        'subtitle': 'Verify accounts, audit security logs, monitor platform analytics',
        'icon': Icons.admin_panel_settings_rounded,
        'color': const Color(0xFF2E7D32),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User Role'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch Active Role View',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Explore how Smart BloodLink works for each stakeholder',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ...roles.map((item) {
              final role = item['role'] as UserRole;
              final isCurrent = authProvider.currentRole == role;
              final color = item['color'] as Color;

              return AnimatedCard(
                margin: const EdgeInsets.only(bottom: 14),
                border: isCurrent
                    ? Border.all(color: color, width: 2)
                    : null,
                onTap: () async {
                  await authProvider.loginAsDemoRole(role);
                  if (context.mounted) {
                    _navigateToRole(context, role);
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Colors.grey),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
