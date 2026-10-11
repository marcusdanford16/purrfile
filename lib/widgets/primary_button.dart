import 'package:flutter/material.dart';

/// A filled brand button with a built-in loading state. Pass [onPressed] as
/// null (or set [loading] true) to disable it — used everywhere to prevent
/// duplicate submissions while a request is in flight.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final VoidCallback? handler = loading ? null : onPressed;

    // No explicit text color here: the button theme applies `onPrimary`.
    // (Forcing `textTheme.labelLarge` made the label dark-on-dark-green.)
    if (loading) {
      return ElevatedButton(
        onPressed: handler,
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: handler,
        icon: Icon(icon, size: 20),
        label: Text(label),
      );
    }
    return ElevatedButton(onPressed: handler, child: Text(label));
  }
}
