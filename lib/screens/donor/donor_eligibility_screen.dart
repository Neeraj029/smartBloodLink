import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/donor_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/custom_button.dart';

/// Donor Health Assessment & 90-Day Waiting Period Eligibility Checker
class DonorEligibilityScreen extends StatefulWidget {
  const DonorEligibilityScreen({super.key});

  @override
  State<DonorEligibilityScreen> createState() => _DonorEligibilityScreenState();
}

class _DonorEligibilityScreenState extends State<DonorEligibilityScreen> {
  bool _weightAbove50 = true;
  bool _noRecentTattoo = true;
  bool _hemoglobinNormal = true;
  bool _noActiveMedication = true;

  @override
  Widget build(BuildContext context) {
    final donorProvider = context.watch<DonorProvider>();
    final profile = donorProvider.donorProfile;
    final lastDonation = profile.lastDonationDate;
    final daysSinceDonation = lastDonation != null
        ? DateTime.now().difference(lastDonation).inDays
        : 120;
    final is90DaysPassed = daysSinceDonation >= 90;
    final isEligible = _weightAbove50 &&
        _noRecentTattoo &&
        _hemoglobinNormal &&
        _noActiveMedication &&
        is90DaysPassed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Eligibility Check'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Eligibility Status Card
            AnimatedCard(
              padding: const EdgeInsets.all(20),
              color: isEligible
                  ? AppColors.successLight
                  : AppColors.errorLight,
              border: Border.all(
                color: isEligible ? AppColors.success : AppColors.error,
                width: 1.5,
              ),
              child: Row(
                children: [
                  Icon(
                    isEligible
                        ? Icons.verified_user_rounded
                        : Icons.gpp_bad_rounded,
                    size: 40,
                    color: isEligible ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEligible
                              ? 'Eligible to Donate Blood'
                              : 'Temporarily Ineligible',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isEligible
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEligible
                              ? 'All clinical pre-requisites met. Ready for emergency matches.'
                              : 'Please check criteria below before participating.',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 90-Day Waiting Period Card
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Donation Interval Status (90 Days Rule)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last Donation Date:',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            lastDonation != null
                                ? DateFormat('dd MMM yyyy').format(lastDonation)
                                : 'No prior donations recorded',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: is90DaysPassed
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$daysSinceDonation days ago',
                          style: TextStyle(
                            color: is90DaysPassed
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (daysSinceDonation / 90.0).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    color: is90DaysPassed
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Health Checklist
            const Text(
              'Health Self-Assessment Questionnaire',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            AnimatedCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Body Weight is Above 50 kg'),
                    subtitle: const Text('Minimum threshold for adult blood volume'),
                    value: _weightAbove50,
                    activeColor: AppColors.primary,
                    onChanged: (val) =>
                        setState(() => _weightAbove50 = val ?? true),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  CheckboxListTile(
                    title: const Text('No Tattoo or Piercing in Past 6 Months'),
                    subtitle: const Text('Prevents infectious pathogen transmission'),
                    value: _noRecentTattoo,
                    activeColor: AppColors.primary,
                    onChanged: (val) =>
                        setState(() => _noRecentTattoo = val ?? true),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  CheckboxListTile(
                    title: const Text('Hemoglobin Level Normal (≥ 12.5 g/dL)'),
                    subtitle: const Text('Sufficient red blood cell concentration'),
                    value: _hemoglobinNormal,
                    activeColor: AppColors.primary,
                    onChanged: (val) =>
                        setState(() => _hemoglobinNormal = val ?? true),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  CheckboxListTile(
                    title: const Text('No Chronic Illness or Blood Thinners'),
                    subtitle: const Text('Ensures recipient and donor safety'),
                    value: _noActiveMedication,
                    activeColor: AppColors.primary,
                    onChanged: (val) =>
                        setState(() => _noActiveMedication = val ?? true),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Save Eligibility Declaration',
              onPressed: () {
                donorProvider.submitEligibilityCheck(
                  weightAbove50: _weightAbove50,
                  noRecentTattoo: _noRecentTattoo,
                  hemoglobinNormal: _hemoglobinNormal,
                  noActiveMedication: _noActiveMedication,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Eligibility status updated successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
