import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Animated scanner viewfinder for simulated RFID / Barcode reading
class RfidScannerOverlay extends StatefulWidget {
  final VoidCallback onTriggerScan;
  final bool isScanning;

  const RfidScannerOverlay({
    super.key,
    required this.onTriggerScan,
    required this.isScanning,
  });

  @override
  State<RfidScannerOverlay> createState() => _RfidScannerOverlayState();
}

class _RfidScannerOverlayState extends State<RfidScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corner markers
          Positioned(
            top: 20,
            left: 20,
            child: _CornerMarker(angle: 0),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: _CornerMarker(angle: 1.5708),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _CornerMarker(angle: 4.71239),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _CornerMarker(angle: 3.14159),
          ),

          // Laser Scanning Beam
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                top: 40 + (_animationController.value * 180),
                left: 30,
                right: 30,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Center Icon & Instructions
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.nfc_rounded,
                size: 48,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(height: 10),
              const Text(
                'Hold RFID Tag Near Reader',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Supports 13.56 MHz High-Frequency Blood Bag Tags',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CornerMarker extends StatelessWidget {
  final double angle;
  const _CornerMarker({required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.primary, width: 3),
            left: BorderSide(color: AppColors.primary, width: 3),
          ),
        ),
      ),
    );
  }
}
