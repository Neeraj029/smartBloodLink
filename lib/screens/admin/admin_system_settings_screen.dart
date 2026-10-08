import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';

/// System settings panel for administrators.
/// Controls platform-wide toggles, notification policies, and maintenance mode.
class AdminSystemSettingsScreen extends StatefulWidget {
  const AdminSystemSettingsScreen({super.key});

  @override
  State<AdminSystemSettingsScreen> createState() =>
      _AdminSystemSettingsScreenState();
}

class _AdminSystemSettingsScreenState
    extends State<AdminSystemSettingsScreen> {
  // ── Toggle states (in a real app these would come from AdminProvider / Firestore) ──
  bool _maintenanceMode = false;
  bool _autoVerifyDonors = false;
  bool _emergencyAlerts = true;
  bool _iotBreachAlerts = true;
  bool _rfidScanRequired = true;
  bool _gamificationEnabled = true;
  bool _demoDataVisible = true;
  double _matchRadiusKm = 25.0;
  double _tempBreachThresholdC = 8.0;

  void _showRestartDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply Changes?'),
        content: const Text(
          'Some settings require a service restart to take effect. '
          'Active sessions will not be interrupted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved. Restart scheduled.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Apply & Restart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save'),
            onPressed: _showRestartDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ─── Appearance ──────────────────────────────────────────────
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle light / dark theme for the entire app'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ─── Platform Controls ───────────────────────────────────────
          _SectionHeader(title: 'Platform Controls'),
          SwitchListTile(
            secondary: Icon(
              Icons.construction_rounded,
              color: _maintenanceMode ? AppColors.warning : null,
            ),
            title: const Text('Maintenance Mode'),
            subtitle: const Text('Locks non-admin access to the platform'),
            value: _maintenanceMode,
            onChanged: (v) {
              if (v) {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Enable Maintenance Mode?'),
                    content: const Text(
                      'All non-admin users will see a maintenance screen '
                      'until this is disabled.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.warning),
                        onPressed: () {
                          setState(() => _maintenanceMode = true);
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Enable'),
                      ),
                    ],
                  ),
                );
              } else {
                setState(() => _maintenanceMode = false);
              }
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.verified_user_rounded),
            title: const Text('Auto-Verify Donors'),
            subtitle: const Text('Skip manual review for new donor sign-ups'),
            value: _autoVerifyDonors,
            onChanged: (v) => setState(() => _autoVerifyDonors = v),
          ),
          SwitchListTile(
            secondary: Icon(Icons.inventory_2_rounded,
                color: _rfidScanRequired ? theme.colorScheme.primary : null),
            title: const Text('Require RFID Scan'),
            subtitle: const Text(
                'Blood bag check-in/out mandates RFID confirmation'),
            value: _rfidScanRequired,
            onChanged: (v) => setState(() => _rfidScanRequired = v),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.emoji_events_rounded),
            title: const Text('Gamification & Rewards'),
            subtitle: const Text('Donor badges, points, and leaderboard'),
            value: _gamificationEnabled,
            onChanged: (v) => setState(() => _gamificationEnabled = v),
          ),
          SwitchListTile(
            secondary: Icon(Icons.data_object_rounded,
                color: _demoDataVisible ? AppColors.info : null),
            title: const Text('Demo Data Visible'),
            subtitle: const Text(
                'Seed data shown during demos — disable for production'),
            value: _demoDataVisible,
            onChanged: (v) => setState(() => _demoDataVisible = v),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ─── Notifications ───────────────────────────────────────────
          _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            secondary: Icon(Icons.notification_important_rounded,
                color: _emergencyAlerts ? AppColors.error : null),
            title: const Text('Emergency Blood Alerts'),
            subtitle: const Text('Push FCM alerts for critical blood requests'),
            value: _emergencyAlerts,
            onChanged: (v) => setState(() => _emergencyAlerts = v),
          ),
          SwitchListTile(
            secondary: Icon(Icons.thermostat_rounded,
                color: _iotBreachAlerts ? AppColors.warning : null),
            title: const Text('IoT Temperature Breach Alerts'),
            subtitle: const Text(
                'Alert hospital staff when cold-chain thresholds are exceeded'),
            value: _iotBreachAlerts,
            onChanged: (v) => setState(() => _iotBreachAlerts = v),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ─── Thresholds ──────────────────────────────────────────────
          _SectionHeader(title: 'Thresholds'),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Donor Match Radius'),
                    Text(
                      '${_matchRadiusKm.toStringAsFixed(0)} km',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _matchRadiusKm,
                  min: 5,
                  max: 100,
                  divisions: 19,
                  label: '${_matchRadiusKm.toStringAsFixed(0)} km',
                  onChanged: (v) => setState(() => _matchRadiusKm = v),
                ),
                Text(
                  'Max radius to search for compatible donors',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Temp. Breach Threshold'),
                    Text(
                      '${_tempBreachThresholdC.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _tempBreachThresholdC,
                  min: 4,
                  max: 12,
                  divisions: 16,
                  label: '${_tempBreachThresholdC.toStringAsFixed(1)}°C',
                  activeColor: AppColors.warning,
                  onChanged: (v) =>
                      setState(() => _tempBreachThresholdC = v),
                ),
                Text(
                  'IoT alert fired when fridge exceeds this temperature',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ─── Danger Zone ─────────────────────────────────────────────
          _SectionHeader(title: 'Danger Zone', color: AppColors.error),

          ListTile(
            leading: const Icon(Icons.delete_sweep_rounded,
                color: AppColors.error),
            title: const Text('Clear All Demo Data'),
            subtitle: const Text('Permanently deletes all seed / mock records'),
            trailing: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demo data cleared (not really — this is a demo 😉)'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
              child: const Text('Clear'),
            ),
          ),

          ListTile(
            leading:
                const Icon(Icons.restore_rounded, color: AppColors.error),
            title: const Text('Factory Reset'),
            subtitle:
                const Text('Resets all settings to installation defaults'),
            trailing: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Factory reset is disabled in demo mode'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
              child: const Text('Reset'),
            ),
          ),

          const SizedBox(height: 32),

          // ─── Version footer ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Smart BloodLink v1.0.0 · Build 2024.09 · Demo Mode',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Section header helper ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const _SectionHeader({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color ?? theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
