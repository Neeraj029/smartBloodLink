import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/donor_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/emergency_sos_banner.dart';
import '../../widgets/role_app_bar.dart';
import 'incoming_request_screen.dart';
import 'donor_rewards_screen.dart';

/// Donor Dashboard with real-time availability toggle, points, and incoming request radar
class DonorDashboardScreen extends StatelessWidget {
  const DonorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donorProvider = context.watch<DonorProvider>();
    final profile = donorProvider.donorProfile;
    final incomingRequest = donorProvider.incomingEmergencyRequest;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const RoleAppBar(title: 'Donor Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Incoming Request Flashing Banner if available
            if (incomingRequest != null) ...[
              EmergencySosBanner(
                title: 'CRITICAL EMERGENCY MATCH! 🚨',
                subtitle:
                    'Patient needs ${incomingRequest.bloodGroup} at ${incomingRequest.address.split(',')[0]}',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncomingRequestScreen(),
                    ),
                  );
                },
              ),
            ],

            // Availability Toggle Card
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              color: profile.availability
                  ? (isDark ? const Color(0xFF1E2F23) : const Color(0xFFE8F5E9))
                  : null,
              border: Border.all(
                color: profile.availability
                    ? AppColors.success
                    : Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (profile.availability
                              ? AppColors.success
                              : Colors.grey)
                          .withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      profile.availability
                          ? Icons.check_circle_rounded
                          : Icons.do_not_disturb_on_rounded,
                      color: profile.availability
                          ? AppColors.success
                          : Colors.grey,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.availability
                              ? 'Active & Ready to Donate'
                              : 'Currently Unavailable',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: profile.availability
                                ? AppColors.success
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.availability
                              ? 'Available for parallel emergency matching'
                              : 'Switch on when available to respond',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: profile.availability,
                    activeColor: AppColors.success,
                    onChanged: (val) =>
                        donorProvider.toggleAvailability(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Gamification & Points Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF880E4F), Color(0xFFD81B60)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DONOR REWARDS BALANCE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${profile.points}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'pts',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Silver Hero Tier',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn('Donations', '${profile.totalDonations}'),
                      _StatColumn('Lives Saved', '${profile.livesSaved}'),
                      _StatColumn('Active Badges', '${profile.badges.length}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Badges preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Achievement Badges',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DonorRewardsScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: profile.badges.map((badgeName) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      badgeName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Donation Guidelines Card
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.info, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Donation Health Guidelines',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Maintain hydration by drinking 500ml water prior to donation.\n• Minimum 90 days required between whole blood donations.\n• Bonus +150 points awarded for emergency accident response.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _StatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
