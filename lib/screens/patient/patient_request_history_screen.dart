import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/blood_request_model.dart';
import '../../providers/patient_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/status_badge.dart';
import 'patient_request_details_screen.dart';

/// Screen listing patient's blood request history with filtering
class PatientRequestHistoryScreen extends StatefulWidget {
  const PatientRequestHistoryScreen({super.key});

  @override
  State<PatientRequestHistoryScreen> createState() =>
      _PatientRequestHistoryScreenState();
}

class _PatientRequestHistoryScreenState
    extends State<PatientRequestHistoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();
    final history = patientProvider.history;

    final filtered = history.where((r) {
      if (_filter == 'All') return true;
      if (_filter == 'Delivered') return r.status.name == 'delivered';
      if (_filter == 'Active') return r.status.name != 'delivered';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request History'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Active', 'Delivered'].map((label) {
                final isSelected = _filter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (val) {
                      setState(() {
                        _filter = label;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          // Requests List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No requests found matching filter'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return AnimatedCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PatientRequestDetailsScreen(request: item),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.requestId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                StatusBadge.fromRequestStatus(item.status),
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
                                    item.bloodGroup,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${item.units} Unit(s) • ${item.urgency.name.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Source: ${item.assignedSourceName ?? "Searching"}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Colors.grey,
                                ),
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
}
