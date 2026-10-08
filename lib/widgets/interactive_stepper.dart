import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Interactive 5-6 step emergency tracking timeline
class InteractiveStepper extends StatelessWidget {
  final RequestStatus currentStatus;

  const InteractiveStepper({
    super.key,
    required this.currentStatus,
  });

  static const List<Map<String, dynamic>> _steps = [
    {'title': 'Search Started', 'desc': 'Parallel donor & hospital query'},
    {'title': 'Source Locked', 'desc': 'Stock or donor confirmed'},
    {'title': 'Ambulance Assigned', 'desc': 'EMS dispatch activated'},
    {'title': 'In Transit', 'desc': 'Live GPS telemetry streaming'},
    {'title': 'Delivered', 'desc': 'Transfusion handoff verified'},
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = currentStatus.stepIndex;

    return Column(
      children: List.generate(_steps.length, (index) {
        final isCompleted = index < activeIndex;
        final isCurrent = index == activeIndex;
        final isPending = index > activeIndex;

        Color dotColor;
        if (isCompleted) {
          dotColor = AppColors.success;
        } else if (isCurrent) {
          dotColor = AppColors.primary;
        } else {
          dotColor = Colors.grey.shade400;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < _steps.length - 1)
                  Container(
                    width: 2.5,
                    height: 38,
                    color: isCompleted
                        ? AppColors.success
                        : Colors.grey.withOpacity(0.3),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _steps[index]['title'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.w600,
                        color: isPending
                            ? Colors.grey
                            : (isCurrent ? AppColors.primary : null),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _steps[index]['desc'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
