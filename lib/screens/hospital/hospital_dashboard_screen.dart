import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hospital_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/emergency_sos_banner.dart';
import '../../widgets/role_app_bar.dart';
import 'add_blood_unit_screen.dart';
import 'iot_temperature_screen.dart';
import 'rfid_scanner_screen.dart';

/// Hospital Staff Dashboard summarizing inventory levels, IoT temperature, and critical low stock
class HospitalDashboardScreen extends StatelessWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hospitalProvider = context.watch<HospitalProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const RoleAppBar(title: 'Blood Bank Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Temperature Alert Banner if breach active
            if (hospitalProvider.tempAlertMessage != null) ...[
              EmergencySosBanner(
                title: 'CRITICAL COLD-CHAIN ALERT!',
                subtitle: hospitalProvider.tempAlertMessage!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IotTemperatureScreen(),
                    ),
                  );
                },
              ),
            ],

            // Top KPI Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL BLOOD UNITS',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${hospitalProvider.totalUnits}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ready for transfusion',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const IotTemperatureScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: hospitalProvider.isTempSafe
                            ? (isDark
                                ? const Color(0xFF1E2F23)
                                : const Color(0xFFE8F5E9))
                            : AppColors.errorLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hospitalProvider.isTempSafe
                              ? AppColors.success
                              : AppColors.error,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ESP32 FRIDGE A',
                                style: TextStyle(
                                  color: hospitalProvider.isTempSafe
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Icon(
                                Icons.thermostat_rounded,
                                size: 18,
                                color: hospitalProvider.isTempSafe
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${hospitalProvider.currentTemperature}°C',
                            style: TextStyle(
                              color: hospitalProvider.isTempSafe
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hospitalProvider.isTempSafe
                                ? 'Optimal (2-6°C)'
                                : 'BREACH ALERT!',
                            style: TextStyle(
                              color: hospitalProvider.isTempSafe
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Low Stock Warnings Banner
            if (hospitalProvider.lowStockGroups.isNotEmpty) ...[
              AnimatedCard(
                padding: const EdgeInsets.all(14),
                color: AppColors.warningLight,
                border: Border.all(color: AppColors.warning),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Low Stock Threshold Alert!',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Critical shortage (< 3 units) in: ${hospitalProvider.lowStockGroups.join(", ")}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Blood Group Stock Breakdown Matrix
            const Text(
              'Stock Count by Blood Group',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hospitalProvider.stockCounts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final group =
                    hospitalProvider.stockCounts.keys.elementAt(index);
                final count = hospitalProvider.stockCounts[group] ?? 0;
                final isLow = count < 2;

                return AnimatedCard(
                  padding: const EdgeInsets.all(8),
                  border: isLow
                      ? Border.all(color: AppColors.error.withOpacity(0.5))
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        group,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isLow ? AppColors.error : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count Units',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isLow ? AppColors.error : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Scan RFID Bag',
                    icon: Icons.qr_code_scanner_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RfidScannerScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Register Unit',
                    icon: Icons.add_rounded,
                    variant: ButtonVariant.outline,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddBloodUnitScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
