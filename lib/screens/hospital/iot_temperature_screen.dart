import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/hospital_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/temperature_chart_widget.dart';

/// IoT Cold-Chain Storage Monitoring Screen with live graph and breach simulation controls
class IotTemperatureScreen extends StatelessWidget {
  const IotTemperatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hospitalProvider = context.watch<HospitalProvider>();
    final readings = hospitalProvider.recentReadings;
    final currentTemp = hospitalProvider.currentTemperature;
    final isSafe = hospitalProvider.isTempSafe;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Cold Storage Monitor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Chart Card
            AnimatedCard(
              padding: const EdgeInsets.all(18),
              child: TemperatureChartWidget(
                readings: readings,
                currentTemp: currentTemp,
                isSafe: isSafe,
              ),
            ),
            const SizedBox(height: 16),

            // Alert Banner if Breach Detected
            if (!isSafe) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_rounded,
                        color: AppColors.error, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'WARNING: Storage temperature has breached safety zone (> 6.0°C) for over 30s! Blood spoilage risk imminent.',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // IoT Gateway Status Card
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hardware Gateway Telemetry Specs',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _SpecRow('Microcontroller', 'ESP32 Wi-Fi / BLE Gateway'),
                  _SpecRow('Sensor Probe', 'DS18B20 High-Precision Waterproof'),
                  _SpecRow('Assigned Unit', 'Main RBC Bank (Fridge 01)'),
                  _SpecRow('Telemetry Frequency', 'Every 4 seconds (Real-time)'),
                  _SpecRow('Safe Operational Range', '2.0°C – 6.0°C'),
                  _SpecRow('Gateway Status', 'CONNECTED (RSSI: -54 dBm)'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Interactive Simulation Controls for Grading & Demonstration
            const Text(
              'Interactive Hardware Simulator',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Trigger safety breach test or restore optimal calibration:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Simulate Breach (8.4°C)',
                    icon: Icons.local_fire_department_rounded,
                    variant: ButtonVariant.emergency,
                    onPressed: () {
                      hospitalProvider.simulateHighTemperatureBreach();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Reset Safe (4.0°C)',
                    icon: Icons.ac_unit_rounded,
                    variant: ButtonVariant.outline,
                    onPressed: () {
                      hospitalProvider.resetTemperatureNormal();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Telemetry Logs Table
            const Text(
              'Recent Telemetry Readings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AnimatedCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: readings.reversed.take(6).map((reading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: reading.isSafe
                                    ? AppColors.success
                                    : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('HH:mm:ss').format(reading.timestamp),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                        Text(
                          '${reading.temperature}°C',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: reading.isSafe
                                ? AppColors.success
                                : AppColors.error,
                          ),
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

  Widget _SpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
