import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/donor_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';

/// Donor Gamification & Rewards Hub showcasing points, unlockable badges, and redeemable vouchers
class DonorRewardsScreen extends StatelessWidget {
  const DonorRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donorProvider = context.watch<DonorProvider>();
    final profile = donorProvider.donorProfile;
    final badges = donorProvider.badges;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final vouchers = [
      {
        'title': 'Free Comprehensive CBC Blood Test',
        'partner': 'Metropolis Pathology Labs',
        'points': 200,
        'icon': Icons.medical_services_rounded,
      },
      {
        'title': '20% Off Prescription Medicines',
        'partner': 'Apollo Pharmacy',
        'points': 150,
        'icon': Icons.local_pharmacy_rounded,
      },
      {
        'title': 'Annual Preventive Health Screening',
        'partner': 'City Apex Hospital',
        'points': 400,
        'icon': Icons.health_and_safety_rounded,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Badges'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF880E4F), Color(0xFFC2185B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  const Text(
                    'CURRENT DONOR BALANCE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${profile.points} Points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (profile.points % 500) / 500.0,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${500 - (profile.points % 500)} points to reach Gold Savior Tier',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Badges Section
            const Text(
              'Achievement Badges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: badges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.25,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final badge = badges[index];
                return AnimatedCard(
                  padding: const EdgeInsets.all(12),
                  color: badge.isUnlocked
                      ? null
                      : (isDark
                          ? Colors.grey.shade900
                          : Colors.grey.shade100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        badge.iconEmoji,
                        style: TextStyle(
                          fontSize: 32,
                          color: badge.isUnlocked
                              ? null
                              : Colors.grey.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        badge.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: badge.isUnlocked ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.isUnlocked
                            ? 'UNLOCKED'
                            : '${badge.requiredDonations} donations needed',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badge.isUnlocked
                              ? AppColors.success
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Partner Rewards & Vouchers
            const Text(
              'Redeem Rewards',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...vouchers.map((v) {
              final canAfford = profile.points >= (v['points'] as int);
              return AnimatedCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(v['icon'] as IconData,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            v['partner'] as String,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canAfford ? AppColors.primary : Colors.grey,
                        minimumSize: const Size(80, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: canAfford
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Redeemed: ${v['title']}! Code sent to SMS.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        '${v['points']} pts',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
