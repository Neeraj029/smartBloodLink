import 'package:flutter/material.dart';
import '../../models/ambulance_trip_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';

/// Screen detailing emergency transport manifest, patient particulars, and RFID bag
class AmbulanceTripDetailsScreen extends StatelessWidget {
  final AmbulanceTripModel trip;
  const AmbulanceTripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manifest: ${trip.tripId}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Transport Manifest',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _Row('Trip ID', trip.tripId),
                  _Row('Linked Request ID', trip.requestId),
                  _Row('Pickup Blood Bank', trip.pickupHospitalName),
                  _Row('Destination Center', trip.destinationAddress),
                  _Row('Vehicle Registration', trip.vehicleNumber),
                  _Row('Driver Name', trip.driverName),
                  _Row('Driver Contact', trip.driverPhone),
                  _Row('Handoff OTP Code', trip.recipientOtp),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Blood Box Cold Chain Specs
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Onboard Mobile Cold Storage Unit',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _Row('Container ID', 'PORTABLE-COLD-UNIT-04'),
                  _Row('Target Range', '2.0°C – 6.0°C'),
                  _Row('Current Reading', '4.1°C (Optimal)'),
                  _Row('Power Source', '12V Vehicle Inverter + Li-Ion Backup'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _Row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
