import 'package:flutter/material.dart';

/// Single-select chip row used for the Health Timeline's
/// All / Vaccination / Vet Visit / Weight / Illness filter.
/// The selected chip is solid brand green with a check mark.
class FilterChipBar extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry padding;

  const FilterChipBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: options.map((option) {
          final isSelected = option == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              showCheckmark: true,
              checkmarkColor: scheme.onPrimary,
              selectedColor: scheme.primary,
              backgroundColor: scheme.surface,
              side: BorderSide(
                color: isSelected ? scheme.primary : scheme.outlineVariant,
              ),
              labelStyle: text.labelMedium?.copyWith(
                color: isSelected ? scheme.onPrimary : scheme.onSurface,
              ),
              onSelected: (_) => onSelected(option),
            ),
          );
        }).toList(),
      ),
    );
  }
}
