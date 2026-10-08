import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';

/// Active Donation Tracker guiding the donor to the hospital center
class ActiveDonationTrackerScreen extends StatelessWidget {
  const ActiveDonationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Donation Mission'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withOpacity(0.4)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mission Confirmed! Source successfully locked in database.',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Destination Hospital Card
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hospital Destination',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Jehangir Hospital Blood Bank',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Emergency Trauma Care Center, 1st Floor, Pune',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.near_me_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      const Text(
                        'Distance: 2.4 km • Est. Drive: 8 mins',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.directions_rounded, size: 16),
                        label: const Text('Navigate'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening Navigation Route to Jehangir Hospital...'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Donor Check-in QR Code Card
            AnimatedCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Fast-Track Hospital Check-in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Show this QR code at the blood bank reception for immediate priority entry',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 130,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TOKEN: BL-DONOR-9912',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pre-donation checklist
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Pre-Donation Checklist',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('✓ Drink at least 500ml water or fruit juice'),
                  SizedBox(height: 4),
                  Text('✓ Bring government-issued photo ID'),
                  SizedBox(height: 4),
                  Text('✓ Avoid strenuous exercise before arrival'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Complete Donation Check-in',
              icon: Icons.check_circle_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Donation verified! +150 Points awarded and "Emergency Hero ⚡" badge unlocked!',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
