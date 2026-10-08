import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/blood_request_model.dart';
import '../../providers/patient_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/pulse_animation.dart';
import 'live_tracking_screen.dart';

/// Screen visually displaying parallel search across donors & hospital inventory in real-time
class RequestMatchingScreen extends StatefulWidget {
  final BloodRequestModel request;
  const RequestMatchingScreen({super.key, required this.request});

  @override
  State<RequestMatchingScreen> createState() => _RequestMatchingScreenState();
}

class _RequestMatchingScreenState extends State<RequestMatchingScreen> {
  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();
    final candidates = patientProvider.matchingCandidates;
    final hospitalCandidates = candidates['hospital'] ?? [];
    final donorCandidates = candidates['donor'] ?? [];
    final activeRequest = patientProvider.activeRequest ?? widget.request;
    final isSourceLocked = activeRequest.status != RequestStatus.searching;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligent Parallel Search'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Radar Pulse Visual
              Center(
                child: PulseAnimation(
                  pulseColor: AppColors.primary,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        isSourceLocked
                            ? Icons.check_circle_rounded
                            : Icons.radar_rounded,
                        color: isSourceLocked
                            ? AppColors.success
                            : AppColors.primary,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isSourceLocked
                    ? 'Source Confirmed & Locked! 🩸'
                    : 'Querying Donors & Blood Banks Simultaneously...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Request ID: ${widget.request.requestId} • Blood Group: ${widget.request.bloodGroup}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Two Parallel Search Columns
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1: Hospital Inventory
                    Expanded(
                      child: AnimatedCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.local_hospital_rounded,
                                    size: 16, color: Color(0xFF1976D2)),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Hospital Stock',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            if (hospitalCandidates.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                  child: Text(
                                    'Checking nearby blood banks...',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              ...hospitalCandidates.map((c) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${c.distanceKm} km • ETA: ${c.estimatedEtaMinutes}m',
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Column 2: Verified Donors
                    Expanded(
                      child: AnimatedCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.volunteer_activism_rounded,
                                    size: 16, color: Color(0xFFE91E63)),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Verified Donors',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            if (donorCandidates.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(
                                  child: Text(
                                    'Alerting available donors in 25km radius...',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            else
                              ...donorCandidates.map((c) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE91E63)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${c.distanceKm} km • Standby',
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action button
              CustomButton(
                text: isSourceLocked
                    ? 'Proceed to Live Tracking & Map'
                    : 'Searching Sources (Please wait)...',
                isLoading: !isSourceLocked,
                icon: Icons.map_rounded,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LiveTrackingScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
