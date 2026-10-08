import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ambulance_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/mock_map_widget.dart';
import 'ambulance_delivery_confirmation_screen.dart';

/// Simulated GPS Turn-by-Turn Navigation Screen with live route and ETA updates
class AmbulanceNavigationScreen extends StatelessWidget {
  const AmbulanceNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ambulanceProvider = context.watch<AmbulanceProvider>();
    final trip = ambulanceProvider.currentTrip;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Emergency Navigation'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Turn-by-Turn Instruction Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A4A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.turn_right_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'In 250 meters',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Turn Right onto Sassoon Road towards ICU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Live Vector GPS Map Canvas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MockMapWidget(
                  currentLat: trip.currentLat,
                  currentLng: trip.currentLng,
                  pickupName: trip.pickupHospitalName,
                  destinationName: trip.destinationAddress,
                  distanceRemainingKm: trip.distanceRemainingKm,
                  etaMinutes: trip.etaMinutes,
                  height: double.infinity,
                ),
              ),
            ),

            // Navigation Telemetry Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavMetric(
                        label: 'Estimated Arrival',
                        value: '${trip.etaMinutes} mins',
                        color: AppColors.primary,
                      ),
                      _NavMetric(
                        label: 'Distance Left',
                        value: '${trip.distanceRemainingKm} km',
                        color: null,
                      ),
                      _NavMetric(
                        label: 'Vehicle Speed',
                        value: '48 km/h',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    text: 'Confirm Arrival & Enter Handoff OTP',
                    icon: Icons.check_circle_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AmbulanceDeliveryConfirmationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _NavMetric({
    required String label,
    required String value,
    required Color? color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
