import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Color-coded status badge pill for urgency, request lifecycle, or bag statuses
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusBadge.fromUrgency(UrgencyLevel urgency) {
    return StatusBadge(
      label: urgency.name.toUpperCase(),
      color: urgency.color,
      icon: urgency == UrgencyLevel.critical
          ? Icons.flash_on_rounded
          : Icons.access_time_rounded,
    );
  }

  factory StatusBadge.fromRequestStatus(RequestStatus status) {
    Color col;
    IconData ic;
    switch (status) {
      case RequestStatus.searching:
        col = const Color(0xFF1976D2);
        ic = Icons.radar_rounded;
        break;
      case RequestStatus.donorFound:
      case RequestStatus.hospitalConfirmed:
        col = const Color(0xFF00897B);
        ic = Icons.check_circle_outline_rounded;
        break;
      case RequestStatus.sourceLocked:
        col = const Color(0xFF7E57C2);
        ic = Icons.lock_rounded;
        break;
      case RequestStatus.ambulanceAssigned:
      case RequestStatus.inTransit:
        col = const Color(0xFFF57C00);
        ic = Icons.emergency_rounded;
        break;
      case RequestStatus.delivered:
        col = const Color(0xFF2E7D32);
        ic = Icons.done_all_rounded;
        break;
      case RequestStatus.cancelled:
        col = const Color(0xFF757575);
        ic = Icons.cancel_outlined;
        break;
    }
    return StatusBadge(
      label: status.displayName,
      color: col,
      icon: ic,
    );
  }

  factory StatusBadge.fromBagStatus(BagStatus status) {
    return StatusBadge(
      label: status.displayName,
      color: status.color,
      icon: Icons.inventory_2_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
