import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/blood_group_chip.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'request_matching_screen.dart';

/// Screen to create an emergency blood request with instant parallel search initiation
class CreateBloodRequestScreen extends StatefulWidget {
  const CreateBloodRequestScreen({super.key});

  @override
  State<CreateBloodRequestScreen> createState() =>
      _CreateBloodRequestScreenState();
}

class _CreateBloodRequestScreenState extends State<CreateBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController(
    text: 'Ruby Hall Clinic, Emergency ICU Room 4, Pune',
  );
  final _notesController = TextEditingController(
    text: 'Polytrauma acute blood loss. Immediate whole blood or RBC required.',
  );

  String _selectedBloodGroup = 'B+';
  int _units = 2;
  UrgencyLevel _urgency = UrgencyLevel.critical;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = context.watch<PatientProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Blood Request'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Required Blood Group',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BloodConstants.groups.map((group) {
                    return BloodGroupChip(
                      bloodGroup: group,
                      isSelected: _selectedBloodGroup == group,
                      onTap: () {
                        setState(() {
                          _selectedBloodGroup = group;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Units Required
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Units Required (Bags)',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _units > 1
                              ? () => setState(() => _units--)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_units',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _units < 10
                              ? () => setState(() => _units++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Urgency Selector
                const Text(
                  'Urgency Level',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: UrgencyLevel.values.map((level) {
                    final isSelected = _urgency == level;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _urgency = level),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? level.color
                                : level.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: level.color,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                level == UrgencyLevel.critical
                                    ? Icons.flash_on_rounded
                                    : (level == UrgencyLevel.urgent
                                        ? Icons.access_time_rounded
                                        : Icons.schedule_rounded),
                                color: isSelected ? Colors.white : level.color,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                level.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : level.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Hospital Address & Location
                CustomTextField(
                  label: 'Hospital / Clinic Delivery Address',
                  hint: 'Hospital name, ward, room, city',
                  controller: _addressController,
                  prefixIcon: Icons.location_on_outlined,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter delivery location'
                      : null,
                ),
                const SizedBox(height: 16),

                // Clinical Notes
                CustomTextField(
                  label: 'Clinical Notes / Patient Condition',
                  hint: 'e.g. ICU ward, surgery requirement',
                  controller: _notesController,
                  maxLines: 2,
                  prefixIcon: Icons.notes_rounded,
                ),
                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: 'Start Parallel Matching Search',
                  icon: Icons.radar_rounded,
                  isLoading: patientProvider.isLoading,
                  variant: _urgency == UrgencyLevel.critical
                      ? ButtonVariant.emergency
                      : ButtonVariant.primary,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final newReq =
                          await patientProvider.createEmergencyRequest(
                        patientId: authProvider.currentUser?.uid ??
                            'user_patient_1',
                        patientName: authProvider.currentUser?.name ??
                            'Rohan Sharma',
                        patientPhone: authProvider.currentUser?.phone ??
                            '+91 98234 11223',
                        bloodGroup: _selectedBloodGroup,
                        units: _units,
                        urgency: _urgency,
                        latitude: 18.5284,
                        longitude: 73.8743,
                        address: _addressController.text.trim(),
                        notes: _notesController.text.trim(),
                      );

                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestMatchingScreen(
                              request: newReq,
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
