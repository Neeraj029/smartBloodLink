import 'package:flutter/material.dart';
import '../../models/blood_request_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/status_badge.dart';

/// Screen displaying the complete audit breakdown and timeline of an emergency request
class PatientRequestDetailsScreen extends StatelessWidget {
  final BloodRequestModel request;
  const PatientRequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details: ${request.requestId}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request Status',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.status.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge.fromRequestStatus(request.status),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Requirements Details
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transfusion Requirement',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _DetailRow('Blood Group', request.bloodGroup),
                  _DetailRow('Units Required', '${request.units} Unit(s)'),
                  _DetailRow('Urgency Level', request.urgency.displayName),
                  _DetailRow('Delivery Location', request.address),
                  if (request.notes != null)
                    _DetailRow('Clinical Notes', request.notes!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Source Allocation Details
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Allocated Source Provenance',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _DetailRow(
                    'Source Type',
                    request.assignedSourceType?.toUpperCase() ?? 'PENDING',
                  ),
                  _DetailRow(
                    'Source Name',
                    request.assignedSourceName ?? 'Searching Candidates',
                  ),
                  _DetailRow(
                    'RFID Tag',
                    request.assignedBagId != null
                        ? 'RFID-9844-B-POS'
                        : 'DIRECT-DONATION-PROVENANCE',
                  ),
                  _DetailRow(
                    'Ambulance Trip ID',
                    request.ambulanceTripId ?? 'TRIP-701',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Timestamp Milestones
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Audit Timestamps',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _DetailRow('Created At', request.createdAt.toString().split('.')[0]),
                  if (request.lockedAt != null)
                    _DetailRow('Source Locked At', request.lockedAt.toString().split('.')[0]),
                  if (request.deliveredAt != null)
                    _DetailRow('Delivered At', request.deliveredAt.toString().split('.')[0]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _DetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
