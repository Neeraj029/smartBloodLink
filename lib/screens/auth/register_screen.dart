import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/blood_group_chip.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'otp_verification_screen.dart';

/// User Registration Screen requiring 6-digit OTP verification
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _orgController = TextEditingController();

  UserRole _selectedRole = UserRole.patient;
  String _selectedBloodGroup = 'O+';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join Smart BloodLink',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select your role to start saving or coordinating lives',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Role Selector Dropdown
                const Text(
                  'Select User Role',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Row(
                        children: [
                          Icon(role.icon, size: 18),
                          const SizedBox(width: 8),
                          Text(role.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRole = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full legal name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Email Address',
                  hint: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (val) =>
                      val == null || !val.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Mobile Number',
                  hint: '+91 98765 43210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (val) => val == null || val.length < 10
                      ? 'Valid 10-digit mobile number required'
                      : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (val) => val == null || val.length < 6
                      ? 'Minimum 6 characters'
                      : null,
                ),
                const SizedBox(height: 16),

                if (_selectedRole == UserRole.hospital ||
                    _selectedRole == UserRole.ambulance) ...[
                  CustomTextField(
                    label: _selectedRole == UserRole.hospital
                        ? 'Hospital / Blood Bank Center Name'
                        : 'Ambulance Registration Vehicle Number',
                    hint: _selectedRole == UserRole.hospital
                        ? 'e.g. City General Blood Center'
                        : 'e.g. MH 12 AB 1008',
                    controller: _orgController,
                    prefixIcon: _selectedRole == UserRole.hospital
                        ? Icons.local_hospital_rounded
                        : Icons.emergency_rounded,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                const Text(
                  'Select Blood Group',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                const SizedBox(height: 28),

                CustomButton(
                  text: 'Continue to OTP Verification',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtpVerificationScreen(
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            phone: _phoneController.text.trim(),
                            password: _passwordController.text.trim(),
                            bloodGroup: _selectedBloodGroup,
                            role: _selectedRole,
                            organizationOrVehicle:
                                _orgController.text.trim().isNotEmpty
                                    ? _orgController.text.trim()
                                    : null,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
