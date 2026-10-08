import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/donor_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';

/// Community Leaderboard ranking top life-saving donors
class DonorLeaderboardScreen extends StatelessWidget {
  const DonorLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donorProvider = context.watch<DonorProvider>();
    final leaderboard = donorProvider.leaderboard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Leaderboard'),
      ),
      body: Column(
        children: [
          // Top Podium Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF880E4F), Color(0xFFC2185B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: AppColors.softShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Rank 2 (Silver)
                _PodiumItem(
                  rank: 2,
                  name: leaderboard.length > 1 ? leaderboard[1]['name'] : 'Donor',
                  points: leaderboard.length > 1 ? leaderboard[1]['points'] : 480,
                  height: 90,
                  badgeColor: const Color(0xFFC0C0C0),
                ),
                // Rank 1 (Gold)
                _PodiumItem(
                  rank: 1,
                  name: leaderboard.isNotEmpty ? leaderboard[0]['name'] : 'Champion',
                  points: leaderboard.isNotEmpty ? leaderboard[0]['points'] : 820,
                  height: 120,
                  badgeColor: const Color(0xFFFFD700),
                ),
                // Rank 3 (Bronze)
                _PodiumItem(
                  rank: 3,
                  name: leaderboard.length > 2 ? leaderboard[2]['name'] : 'Hero',
                  points: leaderboard.length > 2 ? leaderboard[2]['points'] : 410,
                  height: 75,
                  badgeColor: const Color(0xFFCD7F32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Rankings List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final item = leaderboard[index];
                final rank = item['rank'] as int;

                return AnimatedCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: rank <= 3
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              color: rank <= 3 ? Colors.white : null,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item['badge']} • ${item['donations']} Donations (${item['bloodGroup']})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item['points']} pts',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final String name;
  final int points;
  final double height;
  final Color badgeColor;

  const _PodiumItem({
    required this.rank,
    required this.name,
    required this.points,
    required this.height,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 30 : 24,
              backgroundColor: Colors.white24,
              child: Text(
                name.isNotEmpty ? name[0] : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          '$points pts',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
