import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_card.dart';

/// Screen aggregating city-wide blood bank inventory and regional shortage heatmaps
class AdminGlobalStockScreen extends StatelessWidget {
  const AdminGlobalStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cityStock = {
      'O+': {'units': 42, 'status': 'Optimal', 'color': AppColors.success},
      'O-': {'units': 8, 'status': 'Critical Shortage', 'color': AppColors.error},
      'A+': {'units': 36, 'status': 'Optimal', 'color': AppColors.success},
      'A-': {'units': 11, 'status': 'Moderate', 'color': AppColors.warning},
      'B+': {'units': 54, 'status': 'Surplus', 'color': AppColors.success},
      'B-': {'units': 7, 'status': 'Critical Shortage', 'color': AppColors.error},
      'AB+': {'units': 28, 'status': 'Optimal', 'color': AppColors.success},
      'AB-': {'units': 5, 'status': 'Critical Shortage', 'color': AppColors.error},
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Blood Stock Health'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Critical Shortage Warning Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: const [
                  Icon(Icons.emergency_rounded,
                      color: AppColors.error, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'REGIONAL SHORTAGE WARNING: Rh-Negative reserves (O-, B-, AB-) are below critical emergency buffer thresholds.',
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
            const SizedBox(height: 20),

            const Text(
              'City-Wide Stock Matrix (24 Blood Centers)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: BloodConstants.groups.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final group = BloodConstants.groups[index];
                final data = cityStock[group]!;
                final units = data['units'] as int;
                final status = data['status'] as String;
                final color = data['color'] as Color;

                return AnimatedCard(
                  padding: const EdgeInsets.all(14),
                  border: Border.all(color: color.withOpacity(0.4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            group,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$units Bags Available',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Top Blood Centers by Inventory Volume
            const Text(
              'Connected Blood Bank Hubs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AnimatedCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: const [
                  _CenterRow('City Apex Blood Center & Research', '84 Units', true),
                  Divider(),
                  _CenterRow('Sassoon General Hospital Red Cross', '112 Units', true),
                  Divider(),
                  _CenterRow('Ruby Hall Clinic Blood Bank', '68 Units', true),
                  Divider(),
                  _CenterRow('Deenanath Mangeshkar Blood Center', '72 Units', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterRow extends StatelessWidget {
  final String name;
  final String units;
  final bool isOnline;

  const _CenterRow(this.name, this.units, this.isOnline);

  @override
  Widget build(BuildContext context) {
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
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            units,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
