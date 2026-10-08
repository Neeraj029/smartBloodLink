import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';

/// Screen displaying donor's full history of verified blood donations
class DonorHistoryScreen extends StatelessWidget {
  const DonorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      {
        'id': 'DON-4819',
        'date': '12 Jun 2026',
        'hospital': 'City Apex Blood Center',
        'bloodGroup': 'O+',
        'units': '1 Unit Whole Blood',
        'pointsEarned': 150,
        'type': 'Critical Emergency Standby',
        'certificateId': 'CERT-SBL-2026-081',
      },
      {
        'id': 'DON-3921',
        'date': '10 Mar 2026',
        'hospital': 'Ruby Hall Clinic Transfusion Unit',
        'bloodGroup': 'O+',
        'units': '1 Unit Whole Blood',
        'pointsEarned': 100,
        'type': 'Voluntary Community Drive',
        'certificateId': 'CERT-SBL-2026-042',
      },
      {
        'id': 'DON-2184',
        'date': '15 Nov 2025',
        'hospital': 'Sassoon General Hospital',
        'bloodGroup': 'O+',
        'units': '1 Unit Whole Blood',
        'pointsEarned': 150,
        'type': 'Emergency SOS Call',
        'certificateId': 'CERT-SBL-2025-911',
      },
      {
        'id': 'DON-1029',
        'date': '20 Jul 2025',
        'hospital': 'Red Cross Blood Center Pune',
        'bloodGroup': 'O+',
        'units': '1 Unit Whole Blood',
        'pointsEarned': 100,
        'type': 'First Time Donor Camp',
        'certificateId': 'CERT-SBL-2025-104',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return AnimatedCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['id'] as String,
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
                      child: const Text(
                        'Verified Transfusion',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['bloodGroup'] as String,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['hospital'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${item['units']} • ${item['date']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['type'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '+${item['pointsEarned']} Points',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.workspace_premium_rounded, size: 16),
                    label: const Text('View Certificate'),
                    onPressed: () {
                      _showCertificateModal(context, item);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCertificateModal(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.military_tech_rounded,
                  color: AppColors.accentGold, size: 28),
              SizedBox(width: 8),
              Text('Life Saver Certificate'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This certifies that',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              const Text(
                'Dr. Ananya Verma',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'has donated ${item['units']} at ${item['hospital']} on ${item['date']}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 14),
              Text(
                'Verification Ref: ${item['certificateId']}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
