import 'package:flutter/material.dart';

import '../utils/app_spacing.dart';

/// A tappable, form-styled field that shows a date and opens a picker.
class DateField extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback? onTap;

  const DateField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.md,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
        ),
        child: Text(valueText, style: text.bodyLarge),
      ),
    );
  }
}

/// Small heading that groups related form fields.
class FormSectionTitle extends StatelessWidget {
  final String title;

  const FormSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AppSpacing.lg, bottom: AppSpacing.sm, left: AppSpacing.xs),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// Inline error box used under forms.
class FormErrorBox extends StatelessWidget {
  final String message;

  const FormErrorBox(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: text.bodySmall?.copyWith(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
