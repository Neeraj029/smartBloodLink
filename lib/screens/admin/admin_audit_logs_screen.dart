import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/audit_log_model.dart';
import '../../services/mock_data_service.dart';
import '../../utils/app_colors.dart';

/// Immutable, append-only audit trail for all admin and system actions.
/// Mirrors Firestore append-only security rule — no delete/edit affordances.
class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  String _searchQuery = '';
  String _selectedSeverity = 'All';
  List<AuditLogModel> _logs = [];

  static const _severities = ['All', 'info', 'warning', 'critical'];

  @override
  void initState() {
    super.initState();
    _logs = List<AuditLogModel>.from(MockDataService.initialAuditLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<AuditLogModel> get _filtered {
    return _logs.where((log) {
      final matchesQuery = _searchQuery.isEmpty ||
          log.action.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.actorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.details.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSeverity =
          _selectedSeverity == 'All' || log.severity.toLowerCase() == _selectedSeverity.toLowerCase();
      return matchesQuery && matchesSeverity;
    }).toList();
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return Icons.dangerous_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export CSV',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Export queued — will download shortly'),
                behavior: SnackBarBehavior.floating,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Search + Filter bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by action, user, or details…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _severities.map((s) {
                      final selected = _selectedSeverity == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            s == 'All' ? 'All' : s[0].toUpperCase() + s.substring(1),
                          ),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedSeverity = s),
                          selectedColor: s == 'All'
                              ? theme.colorScheme.primaryContainer
                              : _severityColor(s).withOpacity(0.25),
                          labelStyle: TextStyle(
                            color: selected && s != 'All'
                                ? _severityColor(s)
                                : null,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ─── Log count ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} entries',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Read-only',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // ─── Log list ────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.manage_search_rounded,
                            size: 56,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'No logs match your search',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final log = filtered[index];
                      final color = _severityColor(log.severity);
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: color.withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(
                              _severityIcon(log.severity),
                              color: color,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            log.action,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${log.actorName}  ·  ${DateFormat('dd MMM yyyy, HH:mm').format(log.timestamp)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 6),
                            _detailRow(theme, 'Details', log.details),
                            const SizedBox(height: 4),
                            _detailRow(theme, 'Resource', log.entityId),
                            const SizedBox(height: 4),
                            _detailRow(theme, 'Severity',
                                log.severity[0].toUpperCase() +
                                    log.severity.substring(1)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
