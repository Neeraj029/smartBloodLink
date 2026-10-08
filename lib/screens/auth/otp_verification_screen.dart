import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../patient/patient_main_navigation.dart';
import '../donor/donor_main_navigation.dart';
import '../hospital/hospital_main_navigation.dart';
import '../ambulance/ambulance_main_navigation.dart';
import '../admin/admin_main_navigation.dart';

/// 6-digit OTP verification screen as required by assignment specification
class OtpVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String bloodGroup;
  final UserRole role;
  final String? organizationOrVehicle;

  const OtpVerificationScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.bloodGroup,
    required this.role,
    this.organizationOrVehicle,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 60;
  Timer? _timer;
  bool _isVerifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _resendCountdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  void _autoFillDemoOtp() {
    const code = '123456';
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = code[i];
    }
    _verifyAndComplete();
  }

  Future<void> _verifyAndComplete() async {
    final otp = _getOtp();
    if (otp.length < 6) {
      setState(() {
        _error = 'Please enter all 6 digits.';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final authProvider = context.read<AuthProvider>();

    // 1. Create account
    final registered = await authProvider.register(
      email: widget.email,
      password: widget.password,
      name: widget.name,
      phone: widget.phone,
      bloodGroup: widget.bloodGroup,
      role: widget.role,
      organizationOrVehicle: widget.organizationOrVehicle,
    );

    if (!registered) {
      setState(() {
        _isVerifying = false;
        _error = authProvider.errorMessage ?? 'Failed to register account.';
      });
      return;
    }

    // 2. Verify OTP
    final verified = await authProvider.verifyOtp(widget.phone, otp);
    setState(() {
      _isVerifying = false;
    });

    if (verified && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile verified successfully! Welcome to Smart BloodLink.'),
          backgroundColor: AppColors.success,
        ),
      );

      Widget target;
      switch (widget.role) {
        case UserRole.patient:
          target = const PatientMainNavigation();
          break;
        case UserRole.donor:
          target = const DonorMainNavigation();
          break;
        case UserRole.hospital:
          target = const HospitalMainNavigation();
          break;
        case UserRole.ambulance:
          target = const AmbulanceMainNavigation();
          break;
        case UserRole.admin:
          target = const AdminMainNavigation();
          break;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => target),
        (route) => false,
      );
    } else {
      setState(() {
        _error = 'Invalid OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Verify Mobile Number',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent a 6-digit verification code to\n${widget.phone}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // 6-digit OTP Box Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 54,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_getOtp().length == 6) {
                          _verifyAndComplete();
                        }
                      },
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),

              // Auto-fill demo button
              TextButton.icon(
                icon: const Icon(Icons.bolt_rounded,
                    size: 18, color: AppColors.primary),
                label: const Text('Auto-Fill Demo OTP (123456)'),
                onPressed: _autoFillDemoOtp,
              ),
              const SizedBox(height: 12),

              // Resend code countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive code? "),
                  _resendCountdown > 0
                      ? Text(
                          'Resend in ${_resendCountdown}s',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : TextButton(
                          onPressed: _startTimer,
                          child: const Text('Resend OTP'),
                        ),
                ],
              ),
              const Spacer(),

              CustomButton(
                text: 'Verify & Activate Account',
                isLoading: _isVerifying,
                onPressed: _verifyAndComplete,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
