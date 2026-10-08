import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/hospital_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/blood_group_chip.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Screen allowing hospital staff to register a newly donated blood bag with an RFID tag
class AddBloodUnitScreen extends StatefulWidget {
  const AddBloodUnitScreen({super.key});

  @override
  State<AddBloodUnitScreen> createState() => _AddBloodUnitScreenState();
}

class _AddBloodUnitScreenState extends State<AddBloodUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rfidController = TextEditingController(
    text: 'RFID-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
  );
  final _storageController =
      TextEditingController(text: 'Cold Storage Unit A (ESP32-FRIDGE-01)');

  String _selectedGroup = 'A+';
  int _units = 1;
  DateTime _collectionDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 35));

  @override
  void dispose() {
    _rfidController.dispose();
    _storageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hospitalProvider = context.watch<HospitalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Blood Bag'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Blood Group',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BloodConstants.groups.map((group) {
                  return BloodGroupChip(
                    bloodGroup: group,
                    isSelected: _selectedGroup == group,
                    onTap: () {
                      setState(() {
                        _selectedGroup = group;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Assigned Hardware RFID Tag UID',
                controller: _rfidController,
                prefixIcon: Icons.nfc_rounded,
                validator: (val) => val == null || val.isEmpty
                    ? 'RFID tag UID is required'
                    : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Storage Unit / Cold Fridge Name',
                controller: _storageController,
                prefixIcon: Icons.kitchen_rounded,
              ),
              const SizedBox(height: 16),

              // Collection Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary),
                title: const Text('Collection Date'),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(_collectionDate),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _collectionDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _collectionDate = picked;
                      _expiryDate = picked.add(const Duration(days: 35));
                    });
                  }
                },
              ),
              const Divider(),

              // Expiry Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_busy_rounded,
                    color: AppColors.warning),
                title: const Text('Calculated Expiry Date (35-day shelf life)'),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(_expiryDate),
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Register Unit & Encode RFID',
                icon: Icons.save_rounded,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await hospitalProvider.addNewBloodUnit(
                      bloodGroup: _selectedGroup,
                      units: _units,
                      rfidTag: _rfidController.text.trim(),
                      collectionDate: _collectionDate,
                      expiryDate: _expiryDate,
                      storageUnitName: _storageController.text.trim(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Blood unit successfully registered with RFID traceability!',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
