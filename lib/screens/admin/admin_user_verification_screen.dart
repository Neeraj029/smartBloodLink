import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_card.dart';

/// Screen allowing administrators to review, approve, or suspend user accounts
class AdminUserVerificationScreen extends StatefulWidget {
  const AdminUserVerificationScreen({super.key});

  @override
  State<AdminUserVerificationScreen> createState() =>
      _AdminUserVerificationScreenState();
}

class _AdminUserVerificationScreenState
    extends State<AdminUserVerificationScreen> {
  String _roleFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final users = adminProvider.users;

    final filtered = users.where((u) {
      if (_roleFilter == 'All') return true;
      return u.role.name.toLowerCase() == _roleFilter.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Moderation & Verification'),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                'All',
                'Donor',
                'Hospital',
                'Patient',
                'Ambulance'
              ].map((role) {
                final isSelected = _roleFilter == role;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(role),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (val) {
                      setState(() {
                        _roleFilter = role;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final user = filtered[index];
                final isApproved = user.status == 'approved';
                final isSuspended = user.status == 'suspended';

                return AnimatedCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary.withOpacity(0.12),
                            child: Text(
                              user.name.isNotEmpty ? user.name[0] : 'U',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  '${user.role.displayName} • ${user.phone}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isApproved
                                  ? AppColors.success.withOpacity(0.12)
                                  : (isSuspended
                                      ? AppColors.error.withOpacity(0.12)
                                      : AppColors.warning.withOpacity(0.12)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user.status.toUpperCase(),
                              style: TextStyle(
                                color: isApproved
                                    ? AppColors.success
                                    : (isSuspended
                                        ? AppColors.error
                                        : AppColors.warning),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (user.organizationOrVehicle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Organization/Vehicle: ${user.organizationOrVehicle}',
                          style: const TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isApproved) ...[
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                minimumSize: const Size(100, 34),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onPressed: () {
                                adminProvider.updateUserStatus(
                                  user.uid,
                                  'approved',
                                  reason: 'Verified by system admin',
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (!isSuspended) ...[
                            OutlinedButton.icon(
                              icon: const Icon(Icons.block_rounded,
                                  size: 16, color: AppColors.error),
                              label: const Text('Suspend',
                                  style: TextStyle(color: AppColors.error)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                minimumSize: const Size(90, 34),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              onPressed: () {
                                _showSuspendModal(context, adminProvider, user);
                              },
                            ),
                          ],
                        ],
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

  void _showSuspendModal(
    BuildContext context,
    AdminProvider adminProvider,
    UserModel user,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Suspend ${user.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This will immediately revoke their access and exclude them from emergency matching.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Audit Justification Reason',
                  hintText: 'e.g. Failed document verification',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () {
                adminProvider.updateUserStatus(
                  user.uid,
                  'suspended',
                  reason: reasonController.text.trim().isNotEmpty
                      ? reasonController.text.trim()
                      : 'Administrative sanction',
                );
                Navigator.pop(ctx);
              },
              child: const Text('Confirm Suspension'),
            ),
          ],
        );
      },
    );
  }
}
