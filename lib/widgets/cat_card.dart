import 'package:flutter/material.dart';

import '../models/cat.dart';
import '../theme/app_theme.dart';
import '../utils/app_spacing.dart';
import '../utils/cat_format.dart';
import 'cat_avatar.dart';
import 'purr_card.dart';

/// A dashboard card for one cat: photo, quick facts, and four colour-coded
/// shortcuts into Timeline / Reminders / AI Assistant / Profile.
class CatCard extends StatelessWidget {
  final Cat cat;
  final VoidCallback onTap;
  final VoidCallback onTimeline;
  final VoidCallback onReminders;
  final VoidCallback onAiAssistant;
  final VoidCallback onProfile;

  const CatCard({
    super.key,
    required this.cat,
    required this.onTap,
    required this.onTimeline,
    required this.onReminders,
    required this.onAiAssistant,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final purr = context.purr;

    final breed = cat.breed;
    final sex = cat.sex;
    final age = catAgeLabel(cat);

    return PurrCard(
      onTap: onTap,
      borderRadius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CatAvatar(cat: cat, size: 84),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            cat.name,
                            style: text.titleLarge?.copyWith(fontSize: 24),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (sex != null && sex.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          _SexBadge(female: sex.toLowerCase() == 'female'),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (breed != null && breed.isNotEmpty)
                          _FactPill(icon: Icons.pets, label: breed),
                        if (sex != null && sex.isNotEmpty)
                          _FactPill(
                            icon: sex.toLowerCase() == 'female'
                                ? Icons.female
                                : Icons.male,
                            label: sex,
                          ),
                        if (age != null)
                          _FactPill(icon: Icons.cake_outlined, label: age),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ShortcutTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Timeline',
                  tone: purr.vetVisit,
                  onTap: onTimeline,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ShortcutTile(
                  icon: Icons.notifications_outlined,
                  label: 'Reminders',
                  tone: purr.accent,
                  onTap: onReminders,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ShortcutTile(
                  icon: Icons.auto_awesome_outlined,
                  label: 'AI Assistant',
                  tone: purr.vaccination,
                  onTap: onAiAssistant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ShortcutTile(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  tone: purr.other,
                  onTap: onProfile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small round male / female badge next to the name.
class _SexBadge extends StatelessWidget {
  final bool female;

  const _SexBadge({required this.female});

  @override
  Widget build(BuildContext context) {
    final tone = context.purr.vetVisit;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: tone.container, shape: BoxShape.circle),
      child: Icon(female ? Icons.female : Icons.male,
          size: 16, color: tone.onContainer),
    );
  }
}

class _FactPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FactPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: text.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final PurrTone tone;
  final VoidCallback onTap;

  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: tone.container,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: tone.onContainer),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: text.labelSmall?.copyWith(color: tone.onContainer),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
