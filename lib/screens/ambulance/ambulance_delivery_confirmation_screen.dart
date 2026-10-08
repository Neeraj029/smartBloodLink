import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ambulance_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Screen verifying blood delivery completion through recipient OTP and signature
class AmbulanceDeliveryConfirmationScreen extends StatefulWidget {
  const AmbulanceDeliveryConfirmationScreen({super.key});

  @override
  State<AmbulanceDeliveryConfirmationScreen> createState() =>
      _AmbulanceDeliveryConfirmationScreenState();
}

class _AmbulanceDeliveryConfirmationScreenState
    extends State<AmbulanceDeliveryConfirmationScreen> {
  final _otpController = TextEditingController();
  final _recipientNameController =
      TextEditingController(text: 'Nurse In-Charge, ICU');
  bool _isSignatureConfirmed = true;

  @override
  void dispose() {
    _otpController.dispose();
    _recipientNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ambulanceProvider = context.watch<AmbulanceProvider>();
    final trip = ambulanceProvider.currentTrip;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Handoff Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mission ${trip.tripId} reached destination hospital. Complete clinical handoff.',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // OTP Verification Input
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 1: Recipient OTP Authentication',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ask the receiving hospital attendant / patient for their 6-digit confirmation PIN:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Recipient 6-Digit OTP',
                    hint: 'Enter 6-digit code',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.lock_outline_rounded,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.bolt_rounded,
                        size: 16, color: AppColors.primary),
                    label: Text('Auto-Fill Patient OTP (${trip.recipientOtp})'),
                    onPressed: () {
                      _otpController.text = trip.recipientOtp;
                    },
                  ),
                  if (ambulanceProvider.otpError != null) ...[
                    Text(
                      ambulanceProvider.otpError!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 2: Receiving Clinician Details & Signature
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 2: Clinician Receipt Acknowledgement',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Receiving Medical Staff Name',
                    controller: _recipientNameController,
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Digital Signature Pad Simulation',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 90,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        _isSignatureConfirmed
                            ? '✓ Digital Signature Recorded: [Dr. K. Sharma]'
                            : 'Sign here with stylus or finger',
                        style: TextStyle(
                          color: _isSignatureConfirmed
                              ? AppColors.success
                              : Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            CustomButton(
              text: 'Complete Emergency Transfusion Hand-off',
              icon: Icons.done_all_rounded,
              isLoading: ambulanceProvider.isVerifyingOtp,
              onPressed: () async {
                final otp = _otpController.text.trim();
                final success =
                    await ambulanceProvider.verifyDeliveryOtp(otp);

                if (success && mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Row(
                          children: const [
                            Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 28),
                            SizedBox(width: 8),
                            Text('Handoff Complete!'),
                          ],
                        ),
                        content: const Text(
                          'Blood unit delivered safely into clinical possession. Trip logged in immutable audit records.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                            child: const Text('Back to Dashboard'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
