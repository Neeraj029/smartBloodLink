import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/pulse_animation.dart';
import '../patient/patient_main_navigation.dart';
import '../donor/donor_main_navigation.dart';
import '../hospital/hospital_main_navigation.dart';
import '../ambulance/ambulance_main_navigation.dart';
import '../admin/admin_main_navigation.dart';
import 'onboarding_screen.dart';

/// Splash Screen with animated pulse and role-based routing
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  void _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      final role = authProvider.currentRole;
      Widget target;
      switch (role) {
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => target),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PulseAnimation(
              pulseColor: Colors.white,
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bloodtype_rounded,
                  color: AppColors.primary,
                  size: 54,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Smart BloodLink',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Intelligent Emergency Blood Matching & IoT Tracking',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
