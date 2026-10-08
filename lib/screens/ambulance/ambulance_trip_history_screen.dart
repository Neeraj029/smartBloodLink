import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';

/// Screen displaying past emergency runs completed by this ambulance crew
class AmbulanceTripHistoryScreen extends StatelessWidget {
  const AmbulanceTripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final runs = [
      {
        'id': 'TRIP-701',
        'date': 'Today, 14:20',
        'from': 'City Apex Blood Center',
        'to': 'Ruby Hall Clinic ICU',
        'units': '2 Units B+ RBC',
        'duration': '14 mins',
        'distance': '6.4 km',
        'status': 'Delivered',
      },
      {
        'id': 'TRIP-649',
        'date': 'Yesterday, 19:45',
        'from': 'Sassoon Red Cross Bank',
        'to': 'Jehangir Hospital Trauma',
        'units': '1 Unit O- Universal',
        'duration': '11 mins',
        'distance': '4.8 km',
        'status': 'Delivered',
      },
      {
        'id': 'TRIP-582',
        'date': '24 Sep 2026, 08:30',
        'from': 'City Apex Blood Center',
        'to': 'Deenanath Mangeshkar Hospital',
        'units': '3 Units A+ Platelets',
        'duration': '19 mins',
        'distance': '8.2 km',
        'status': 'Delivered',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Run Logs'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: runs.length,
        itemBuilder: (context, index) {
          final run = runs[index];
          return AnimatedCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      run['id'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        run['status'] as String,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'From: ${run['from']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'To: ${run['to']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${run['units']} • ${run['duration']} (${run['distance']})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      run['date'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
