import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ambulance_provider.dart';
import '../../providers/patient_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/interactive_stepper.dart';
import '../../widgets/mock_map_widget.dart';
import '../../widgets/status_badge.dart';

/// Live Emergency Tracking Screen with real-time GPS map, stepper, and driver contact
class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();
    final ambulanceProvider = context.watch<AmbulanceProvider>();
    final activeRequest = patientProvider.activeRequest;
    final trip = ambulanceProvider.currentTrip;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (activeRequest == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Tracking')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off_rounded,
                  size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No Active Emergency Request',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create an emergency request to track live blood delivery.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Back to Dashboard',
                width: 200,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking: ${activeRequest.requestId}'),
        actions: [
          StatusBadge.fromRequestStatus(activeRequest.status),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Vector GPS Map
            MockMapWidget(
              currentLat: trip.currentLat,
              currentLng: trip.currentLng,
              pickupName: trip.pickupHospitalName,
              destinationName: activeRequest.address,
              distanceRemainingKm: trip.distanceRemainingKm,
              etaMinutes: trip.etaMinutes,
              height: 220,
            ),
            const SizedBox(height: 16),

            // OTP Delivery Hand-Off Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DELIVERY CONFIRMATION OTP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Provide this code to the driver upon arrival',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      trip.recipientOtp,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Assigned Source & RFID Traceability Card
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assigned Blood Source Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bloodtype_rounded,
                            color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeRequest.assignedSourceName ??
                                  'City Apex Blood Center',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'RFID Tag: ${activeRequest.assignedBagId != null ? "RFID-9844-B-POS" : "RFID-DIRECT-DONOR"} • RBC Unit 1',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Cold Temp: 4.1°C',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ambulance Driver Details & Contact
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.warning.withOpacity(0.15),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: AppColors.warning,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.driverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Vehicle: ${trip.vehicleNumber}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_rounded,
                          color: Colors.white, size: 18),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling Driver at ${trip.driverPhone}'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step Progress Timeline
            const Text(
              'Emergency Dispatch Milestones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: InteractiveStepper(
                currentStatus: activeRequest.status,
              ),
            ),
            const SizedBox(height: 20),

            // Simulation step button for evaluation demo
            CustomButton(
              text: 'Simulate Next Tracking Step (Demo Control)',
              variant: ButtonVariant.outline,
              icon: Icons.fast_forward_rounded,
              onPressed: () {
                patientProvider.advanceTrackingStep();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
