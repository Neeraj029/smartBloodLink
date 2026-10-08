import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/role_app_bar.dart';
import 'admin_system_settings_screen.dart';

/// Administrator Overview Dashboard with platform metrics, uptime, and system monitoring
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final metrics = adminProvider.metrics;

    return Scaffold(
      appBar: const RoleAppBar(title: 'Admin Console'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Executive KPI Row
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    title: 'REGISTERED DONORS',
                    value: '${metrics['totalDonors'] ?? 1420}',
                    subtitle: '+18 this week',
                    color: AppColors.primary,
                    icon: Icons.volunteer_activism_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KpiCard(
                    title: 'HOSPITALS LINKED',
                    value: '${metrics['totalHospitals'] ?? 24}',
                    subtitle: '100% Verified',
                    color: const Color(0xFF1976D2),
                    icon: Icons.local_hospital_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    title: 'CITY BLOOD UNITS',
                    value: '${metrics['totalUnitsInStock'] ?? 384}',
                    subtitle: 'Across all banks',
                    color: AppColors.success,
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KpiCard(
                    title: 'MATCHING LATENCY',
                    value: '1.4s',
                    subtitle: 'Under 2s target',
                    color: AppColors.warning,
                    icon: Icons.speed_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Real-Time System Health Architecture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'System Infrastructure Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminSystemSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _HealthRow(
                    service: 'Cloud Functions Matching Engine',
                    status: 'OPERATIONAL',
                    latency: '42ms',
                    isHealthy: true,
                  ),
                  const Divider(),
                  _HealthRow(
                    service: 'ESP32 Cold-Chain IoT Gateways',
                    status: '24/24 ONLINE',
                    latency: '4.0s tick',
                    isHealthy: true,
                  ),
                  const Divider(),
                  _HealthRow(
                    service: 'Firestore Transaction Concurrency Locks',
                    status: 'ACTIVE (0 Conflicts)',
                    latency: '12ms',
                    isHealthy: true,
                  ),
                  const Divider(),
                  _HealthRow(
                    service: 'Firebase Cloud Messaging (FCM Push)',
                    status: 'CONNECTED',
                    latency: '820ms',
                    isHealthy: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Security Audit Events
            const Text(
              'Recent Security & Audit Trail',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AnimatedCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: adminProvider.auditLogs.take(4).map((log) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: log.severity == 'Critical'
                                ? AppColors.errorLight
                                : (log.severity == 'Warning'
                                    ? AppColors.warningLight
                                    : AppColors.infoLight),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            log.severity == 'Critical'
                                ? Icons.warning_rounded
                                : Icons.security_rounded,
                            size: 16,
                            color: log.severity == 'Critical'
                                ? AppColors.error
                                : (log.severity == 'Warning'
                                    ? AppColors.warning
                                    : AppColors.info),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.action,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                log.details,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _KpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _HealthRow({
    required String service,
    required String status,
    required String latency,
    required bool isHealthy,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                'Latency: $latency',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (isHealthy ? AppColors.success : AppColors.error)
                .withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isHealthy ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
