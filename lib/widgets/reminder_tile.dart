import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/reminder.dart';
import '../theme/app_theme.dart';
import '../utils/app_spacing.dart';
import 'purr_card.dart';
import 'status_badge.dart';

IconData _iconForReminder(String type) {
  final t = type.toLowerCase();
  if (t.contains('vacc') || t.contains('shot') || t.contains('rabies')) {
    return Icons.vaccines_outlined;
  }
  if (t.contains('med') || t.contains('tablet') || t.contains('worm') ||
      t.contains('pill')) {
    return Icons.medication_outlined;
  }
  if (t.contains('vet') || t.contains('check') || t.contains('visit')) {
    return Icons.local_hospital_outlined;
  }
  if (t.contains('weigh')) return Icons.monitor_weight_outlined;
  return Icons.notifications_outlined;
}

/// "Today", "Tomorrow", "In 12 days", "3 days ago" — by calendar day, so a
/// reminder dated today never reads "0 days".
String _relativeDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  final target = DateTime.utc(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  if (diff > 1) return 'In $diff days';
  return '${-diff} days ago';
}

class ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback? onMarkDone;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onTap,
    this.onMarkDone,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final purr = context.purr;
    final status = reminder.effectiveStatus;

    final tone = switch (status) {
      ReminderStatus.upcoming => purr.upcoming,
      ReminderStatus.completed => purr.done,
      ReminderStatus.overdue => purr.overdue,
    };

    final date = reminder.reminderDate;
    final dateStr = date.year == DateTime.now().year
        ? DateFormat.MMMd().format(date)
        : DateFormat.yMMMd().format(date);
    final detail = status == ReminderStatus.completed
        ? dateStr
        : '$dateStr · ${_relativeDay(date)}';
    final canComplete = onMarkDone != null && status != ReminderStatus.completed;

    return PurrCard(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md - 2, 12, canComplete ? 4 : AppSpacing.md - 2, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tone.container,
              borderRadius: AppRadius.sm,
            ),
            child: Icon(_iconForReminder(reminder.reminderType),
                color: tone.onContainer, size: 22),
          ),
          const SizedBox(width: AppSpacing.md - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.reminderType,
                    style: text.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusBadge(status: status),
                    Text(
                      detail,
                      style: text.bodySmall?.copyWith(
                        color: status == ReminderStatus.overdue
                            ? purr.overdue.onContainer
                            : scheme.onSurfaceVariant,
                        fontWeight: status == ReminderStatus.overdue
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (canComplete)
            IconButton(
              icon: Icon(Icons.check_circle_outline,
                  size: 28, color: purr.done.color),
              tooltip: 'Mark completed',
              onPressed: onMarkDone,
            ),
        ],
      ),
    );
  }
}
