import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hospital_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/rfid_scanner_overlay.dart';
import 'rfid_bag_details_screen.dart';

/// Interactive RFID / NFC scanner interface with simulated hardware triggers
class RfidScannerScreen extends StatefulWidget {
  const RfidScannerScreen({super.key});

  @override
  State<RfidScannerScreen> createState() => _RfidScannerScreenState();
}

class _RfidScannerScreenState extends State<RfidScannerScreen> {
  final _manualTagController = TextEditingController(text: 'RFID-9844-B-POS');

  @override
  void dispose() {
    _manualTagController.dispose();
    super.dispose();
  }

  void _processScannedTag(String tag) async {
    final hospitalProvider = context.read<HospitalProvider>();
    final success = await hospitalProvider.scanRfidTag(tag);

    if (success && mounted && hospitalProvider.lastScannedBag != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RFID Tag scanned successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RfidBagDetailsScreen(bag: hospitalProvider.lastScannedBag!),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hospitalProvider.scanError ?? 'Tag not found'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hospitalProvider = context.watch<HospitalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('RFID Blood Bag Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Animated Scanner Viewfinder
            RfidScannerOverlay(
              isScanning: hospitalProvider.isScanning,
              onTriggerScan: () =>
                  _processScannedTag(_manualTagController.text.trim()),
            ),
            const SizedBox(height: 24),

            // Simulation Action Card
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simulated RFID Hardware Probe',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Simulate hardware read of blood bag RFID tag:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'RFID Tag UID or Bag ID',
                    controller: _manualTagController,
                    prefixIcon: Icons.nfc_rounded,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Simulate Hardware Tag Tap',
                    icon: Icons.contactless_rounded,
                    isLoading: hospitalProvider.isScanning,
                    onPressed: () =>
                        _processScannedTag(_manualTagController.text.trim()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sample Tags for Quick Test
            const Text(
              'Sample Pre-configured Blood Bag Tags',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('RFID-9844-B-POS (B+)'),
                  onPressed: () {
                    _manualTagController.text = 'RFID-9844-B-POS';
                    _processScannedTag('RFID-9844-B-POS');
                  },
                ),
                ActionChip(
                  label: const Text('RFID-9842-O-POS (O+)'),
                  onPressed: () {
                    _manualTagController.text = 'RFID-9842-O-POS';
                    _processScannedTag('RFID-9842-O-POS');
                  },
                ),
                ActionChip(
                  label: const Text('RFID-9843-O-NEG (O-)'),
                  onPressed: () {
                    _manualTagController.text = 'RFID-9843-O-NEG';
                    _processScannedTag('RFID-9843-O-NEG');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
