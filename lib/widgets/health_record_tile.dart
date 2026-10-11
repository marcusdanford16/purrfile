import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/health_record.dart';
import '../theme/app_theme.dart';
import '../utils/app_spacing.dart';
import 'purr_card.dart';

IconData iconForRecordType(RecordType type) {
  switch (type) {
    case RecordType.vaccination:
      return Icons.vaccines_outlined;
    case RecordType.vetVisit:
      return Icons.local_hospital_outlined;
    case RecordType.weight:
      return Icons.monitor_weight_outlined;
    case RecordType.illness:
      return Icons.healing_outlined;
    case RecordType.other:
      return Icons.sticky_note_2_outlined;
  }
}

/// Each record type has its own colour family so the timeline can be
/// scanned at a glance.
PurrTone toneForRecordType(PurrColors purr, RecordType type) {
  switch (type) {
    case RecordType.vaccination:
      return purr.vaccination;
    case RecordType.vetVisit:
      return purr.vetVisit;
    case RecordType.weight:
      return purr.weight;
    case RecordType.illness:
      return purr.illness;
    case RecordType.other:
      return purr.other;
  }
}

class HealthRecordTile extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onTap;

  /// Hide the year when a parent already groups by year (the Timeline).
  final bool showYear;

  const HealthRecordTile({
    super.key,
    required this.record,
    required this.onTap,
    this.showYear = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tone = toneForRecordType(context.purr, record.recordType);
    final dateStr = showYear
        ? DateFormat.yMMMd().format(record.date)
        : DateFormat.MMMd().format(record.date);

    final title = record.description?.isNotEmpty == true
        ? record.description!
        : record.recordType.label;
    final clinic = record.clinic;
    final subtitle = [
      record.recordType.label,
      if (clinic != null && clinic.isNotEmpty) clinic,
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PurrCard(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md - 2, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tone.container,
                borderRadius: AppRadius.sm,
              ),
              child: Icon(iconForRecordType(record.recordType),
                  color: tone.onContainer, size: 22),
            ),
            const SizedBox(width: AppSpacing.md - 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: text.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (record.nextDueDate != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 14, color: tone.onContainer),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Next due ${DateFormat.yMMMd().format(record.nextDueDate!)}',
                            style: text.bodySmall?.copyWith(
                              color: tone.onContainer,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                dateStr,
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
