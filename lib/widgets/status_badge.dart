import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../theme/app_theme.dart';
import '../utils/app_spacing.dart';

/// Reminder status pill. Always an icon + a word, never colour alone.
class StatusBadge extends StatelessWidget {
  final ReminderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final purr = context.purr;
    late final PurrTone tone;
    late final IconData icon;
    late final String label;

    switch (status) {
      case ReminderStatus.upcoming:
        tone = purr.upcoming;
        icon = Icons.schedule;
        label = 'Upcoming';
        break;
      case ReminderStatus.completed:
        tone = purr.done;
        icon = Icons.check_circle_outline;
        label = 'Done';
        break;
      case ReminderStatus.overdue:
        tone = purr.overdue;
        icon = Icons.error_outline;
        label = 'Overdue';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.container,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tone.onContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tone.onContainer,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
