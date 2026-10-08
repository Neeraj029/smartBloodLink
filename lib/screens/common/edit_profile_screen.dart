import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/blood_group_chip.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Screen allowing user to edit personal info, phone, and blood group
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _orgController;
  late String _selectedBloodGroup;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _orgController =
        TextEditingController(text: user?.organizationOrVehicle ?? '');
    _selectedBloodGroup = user?.bloodGroup ?? 'O+';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Full Name',
                controller: _nameController,
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Mobile Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter phone' : null,
              ),
              const SizedBox(height: 16),
              if (user?.role == UserRole.hospital ||
                  user?.role == UserRole.ambulance) ...[
                CustomTextField(
                  label: user?.role == UserRole.ambulance
                      ? 'Vehicle Number'
                      : 'Hospital Name',
                  controller: _orgController,
                  prefixIcon: Icons.business_rounded,
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Select Blood Group',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save Changes',
                isLoading: authProvider.isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await authProvider.updateProfile(
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      bloodGroup: _selectedBloodGroup,
                      organizationOrVehicle: _orgController.text.trim().isNotEmpty
                          ? _orgController.text.trim()
                          : null,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
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
