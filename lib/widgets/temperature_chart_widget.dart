import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/iot_sensor_model.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Real-time IoT temperature telemetry chart with safety threshold boundaries
class TemperatureChartWidget extends StatelessWidget {
  final List<SensorReading> readings;
  final double currentTemp;
  final bool isSafe;

  const TemperatureChartWidget({
    super.key,
    required this.readings,
    required this.currentTemp,
    required this.isSafe,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final spots = <FlSpot>[];
    for (int i = 0; i < readings.length; i++) {
      spots.add(FlSpot(i.toDouble(), readings[i].temperature));
    }

    if (spots.isEmpty) {
      spots.add(const FlSpot(0, 4.0));
      spots.add(const FlSpot(1, 4.0));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COLD STORAGE TELEMETRY (ESP32)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$currentTemp°C',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isSafe ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isSafe ? AppColors.success : AppColors.error)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isSafe ? 'OPTIMAL SAFE' : 'CRITICAL BREACH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSafe ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isSafe ? AppColors.success : AppColors.error)
                    .withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.thermostat_rounded,
                size: 26,
                color: isSafe ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (val) {
                  return FlLine(
                    color: isDark ? Colors.white12 : Colors.black12,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 3,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '-${(readings.length - value.toInt()) * 4}s',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}°C',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (readings.length - 1).toDouble() > 0
                  ? (readings.length - 1).toDouble()
                  : 1,
              minY: 0,
              maxY: 10,
              // Draw Safe Threshold Range (2°C - 6°C)
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: BloodConstants.safeStorageTempMax,
                    color: AppColors.warning.withOpacity(0.7),
                    strokeWidth: 1.5,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 5, bottom: 2),
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                      labelResolver: (line) => 'Max (6°C)',
                    ),
                  ),
                  HorizontalLine(
                    y: BloodConstants.safeStorageTempMin,
                    color: AppColors.info.withOpacity(0.7),
                    strokeWidth: 1.5,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.only(right: 5, top: 2),
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                      labelResolver: (line) => 'Min (2°C)',
                    ),
                  ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: isSafe ? AppColors.success : AppColors.error,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: (isSafe ? AppColors.success : AppColors.error)
                        .withOpacity(0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
