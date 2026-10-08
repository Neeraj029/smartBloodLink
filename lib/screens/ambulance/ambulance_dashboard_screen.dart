import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ambulance_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/emergency_sos_banner.dart';
import '../../widgets/role_app_bar.dart';
import 'ambulance_navigation_screen.dart';
import 'ambulance_trip_details_screen.dart';

/// Ambulance Operator Dashboard showing assigned emergency trip mission
class AmbulanceDashboardScreen extends StatelessWidget {
  const AmbulanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ambulanceProvider = context.watch<AmbulanceProvider>();
    final trip = ambulanceProvider.currentTrip;
    final isOnMission = trip.status == 'in_transit' || trip.status == 'dispatched';

    return Scaffold(
      appBar: const RoleAppBar(title: 'EMS Dispatch Portal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Mission Emergency Alert
            if (isOnMission) ...[
              EmergencySosBanner(
                title: 'URGENT BLOOD TRANSPORT DISPATCH 🚨',
                subtitle:
                    'Trip: ${trip.tripId} • Delivery to ${trip.destinationAddress.split(',')[0]} (ETA: ${trip.etaMinutes}m)',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AmbulanceNavigationScreen(),
                    ),
                  );
                },
              ),
            ],

            // Active Dispatch Mission Card
            AnimatedCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT ASSIGNED MISSION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trip.tripId,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          trip.status.toUpperCase().replaceAll('_', ' '),
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Route Visual
                  _RoutePoint(
                    icon: Icons.local_hospital_rounded,
                    iconColor: const Color(0xFF1976D2),
                    title: 'Pickup Location',
                    name: trip.pickupHospitalName,
                    address: 'Blood Bank Storage Wing, Floor 1',
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 11),
                    child: SizedBox(
                      height: 20,
                      child: VerticalDivider(thickness: 2),
                    ),
                  ),
                  _RoutePoint(
                    icon: Icons.personal_injury_rounded,
                    iconColor: AppColors.primary,
                    title: 'Delivery Destination',
                    name: trip.destinationAddress,
                    address: 'Emergency Trauma Care Center',
                  ),
                  const SizedBox(height: 20),

                  // Live Metrics Bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Metric('ETA', '${trip.etaMinutes} mins'),
                        _Metric('Distance', '${trip.distanceRemainingKm} km'),
                        _Metric('Speed', '48 km/h'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Open GPS Navigation',
                          icon: Icons.navigation_rounded,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AmbulanceNavigationScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.info_outline_rounded),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AmbulanceTripDetailsScreen(
                                trip: trip,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Vehicle Specs & Telemetry Card
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ambulance Vehicle Readiness',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _InfoRow('Registration No.', trip.vehicleNumber),
                  _InfoRow('Assigned Driver', trip.driverName),
                  _InfoRow('Blood Portable Fridge', 'Active (Cold Temp: 4.1°C)'),
                  _InfoRow('GPS Telemetry Frequency', 'Live 5-second beacon'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _RoutePoint({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String name,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _Metric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
