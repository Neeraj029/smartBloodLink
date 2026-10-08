import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/inventory_item_model.dart';
import '../../providers/hospital_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/status_badge.dart';
import 'add_blood_unit_screen.dart';
import 'rfid_bag_details_screen.dart';

/// Hospital Blood Bank Inventory Management Screen
class HospitalInventoryScreen extends StatefulWidget {
  const HospitalInventoryScreen({super.key});

  @override
  State<HospitalInventoryScreen> createState() =>
      _HospitalInventoryScreenState();
}

class _HospitalInventoryScreenState extends State<HospitalInventoryScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final hospitalProvider = context.watch<HospitalProvider>();
    final bags = hospitalProvider.bags;

    final filtered = bags.where((b) {
      if (_statusFilter == 'All') return true;
      return b.status.name.toLowerCase() == _statusFilter.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Bank Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddBloodUnitScreen(),
                ),
              );
            },
          ),
        ],
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
                'Stored',
                'Reserved',
                'Issued',
                'Transferred',
                'Discarded'
              ].map((status) {
                final isSelected = _statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (val) {
                      setState(() {
                        _statusFilter = status;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No blood units matching selected filter'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final bag = filtered[index];
                      return AnimatedCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RfidBagDetailsScreen(bag: bag),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  bag.bloodGroup,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        bag.bagId,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      StatusBadge.fromBagStatus(bag.status),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'RFID: ${bag.rfidTag}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Expires: ${DateFormat("dd MMM yyyy").format(bag.expiryDate)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: bag.daysUntilExpiry < 7
                                              ? AppColors.error
                                              : Colors.grey,
                                          fontWeight: bag.daysUntilExpiry < 7
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 13,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ],
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
