import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/donor_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/pulse_animation.dart';
import 'active_donation_tracker_screen.dart';

/// Incoming Emergency Request Screen with acceptance timer and instant fallback handling
class IncomingRequestScreen extends StatefulWidget {
  const IncomingRequestScreen({super.key});

  @override
  State<IncomingRequestScreen> createState() => _IncomingRequestScreenState();
}

class _IncomingRequestScreenState extends State<IncomingRequestScreen> {
  int _secondsRemaining = 48;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        // Time out triggers automatic fallback to hospital stock
        final donorProvider = context.read<DonorProvider>();
        donorProvider.rejectEmergencyRequest();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donorProvider = context.watch<DonorProvider>();
    final request = donorProvider.incomingEmergencyRequest;

    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Emergency Requests')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 54,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Pending Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'You are currently on standby for emergency calls.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Emergency SOS'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Heartbeat Alert Indicator
              PulseAnimation(
                pulseColor: AppColors.primary,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.flash_on_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Patient Needs ${request.bloodGroup} Blood',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Response Timer: $_secondsRemaining seconds remaining',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Request Breakdown Card
              AnimatedCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _DetailRow('Request ID', request.requestId),
                    const Divider(),
                    _DetailRow('Units Required', '${request.units} Unit(s)'),
                    const Divider(),
                    _DetailRow('Urgency Level', 'CRITICAL (Immediate)'),
                    const Divider(),
                    _DetailRow('Distance from You', '2.4 km (~8 mins drive)'),
                    const Divider(),
                    _DetailRow('Hospital Center', request.address),
                    if (request.notes != null) ...[
                      const Divider(),
                      _DetailRow('Condition', request.notes!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Emergency bonus card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.stars_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Responding to this emergency awards +150 bonus points and the "Emergency Hero ⚡" badge!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              CustomButton(
                text: 'Accept Emergency Call 🩸',
                variant: ButtonVariant.emergency,
                isLoading: donorProvider.isLoading,
                onPressed: () async {
                  _timer?.cancel();
                  await donorProvider.acceptEmergencyRequest();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ActiveDonationTrackerScreen(),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Decline (Triggers Hospital Stock Fallback)',
                variant: ButtonVariant.outline,
                onPressed: () async {
                  _timer?.cancel();
                  await donorProvider.rejectEmergencyRequest();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Request rejected. Parallel matching immediately activated hospital standby inventory.',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _DetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
