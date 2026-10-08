import 'package:flutter/material.dart';
import '../../models/blood_request_model.dart';
import '../../services/mock_data_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';

/// Hospital Emergency Dispatch Queue
class HospitalRequestsScreen extends StatefulWidget {
  const HospitalRequestsScreen({super.key});

  @override
  State<HospitalRequestsScreen> createState() => _HospitalRequestsScreenState();
}

class _HospitalRequestsScreenState extends State<HospitalRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final activeRequests = MockDataService.initialRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Dispatch Orders'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeRequests.length,
        itemBuilder: (context, index) {
          final request = activeRequests[index];
          return AnimatedCard(
            margin: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      request.requestId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    StatusBadge.fromRequestStatus(request.status),
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
                        request.bloodGroup,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${request.units} Unit(s) Required',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Recipient: ${request.patientName} (${request.patientPhone})',
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
                const SizedBox(height: 10),
                Text(
                  'Destination: ${request.address}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (request.notes != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Notes: ${request.notes}',
                    style: const TextStyle(
                        fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 14),
                CustomButton(
                  text: 'Authorize Emergency Blood Unit Issue',
                  icon: Icons.local_shipping_rounded,
                  height: 44,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Blood Unit authorized for Request ${request.requestId}! Ambulance dispatched.',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
