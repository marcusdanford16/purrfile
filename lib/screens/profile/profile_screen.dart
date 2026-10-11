import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/cat.dart';
import '../../models/health_record.dart';
import '../../models/reminder.dart';
import '../../services/cat_service.dart';
import '../../services/health_record_service.dart';
import '../../services/reminder_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_spacing.dart';
import '../../utils/cat_format.dart';
import '../../widgets/cat_avatar.dart';
import '../../widgets/date_field.dart';
import '../../widgets/health_record_tile.dart';
import '../../widgets/purr_card.dart';
import '../../widgets/skeleton.dart';
import 'cat_form_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Cat cat;
  final VoidCallback onCatChanged;
  final VoidCallback onCatDeleted;

  const ProfileScreen({
    super.key,
    required this.cat,
    required this.onCatChanged,
    required this.onCatDeleted,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _catService = CatService();
  final _recordService = HealthRecordService();
  final _reminderService = ReminderService();

  List<HealthRecord> _records = [];
  int _upcomingCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen old) {
    super.didUpdateWidget(old);
    if (old.cat.id != widget.cat.id) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final records = await _recordService.getRecordsForCat(widget.cat.id);
      final reminders =
          await _reminderService.getRemindersForCat(widget.cat.id);
      setState(() {
        _records = records;
        _upcomingCount = reminders
            .where((r) => r.effectiveStatus != ReminderStatus.completed)
            .length;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CatFormScreen(existing: widget.cat)),
    );
    if (saved == true) widget.onCatChanged();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${widget.cat.name}?'),
        content: const Text(
            'This removes the cat profile. Health records and reminders tied to this cat will also become inaccessible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _catService.deleteCat(widget.cat.id);
      widget.onCatDeleted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.cat;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
          children: [
            _ProfileHero(cat: cat, onEdit: _edit, onDelete: _delete),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                      icon: Icons.palette_outlined,
                      label: 'Color',
                      value: cat.color ?? '—'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _InfoTile(
                      icon: Icons.cake_outlined,
                      label: 'Date of birth',
                      value: cat.dob != null
                          ? DateFormat.yMMMd().format(cat.dob!)
                          : '—'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                      icon: Icons.memory_outlined,
                      label: 'Microchip',
                      value: cat.microchipNumber ?? '—'),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _InfoTile(
                      icon: Icons.person_outline,
                      label: 'Owner',
                      value: cat.ownerName ?? '—'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            PurrCard(
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md, horizontal: AppSpacing.sm),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _Stat(value: '${_records.length}', label: 'Records')),
                    const _StatDivider(),
                    Expanded(child: _Stat(value: '$_upcomingCount', label: 'Upcoming')),
                    const _StatDivider(),
                    Expanded(
                      child: _Stat(
                        value: _records.isEmpty ? '—' : 'Good',
                        label: 'Overall Health',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Recent Health Records', style: text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            if (_loading)
              const SkeletonList(count: 2)
            else if (_error != null)
              FormErrorBox(_error!)
            else if (_records.isEmpty)
              Text('No health records yet.', style: text.bodyLarge)
            else
              for (final r in _records.take(5))
                HealthRecordTile(record: r, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

/// Green hero card: big photo, name, quick facts, edit / delete.
class _ProfileHero extends StatelessWidget {
  final Cat cat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProfileHero({
    required this.cat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final age = catAgeLabel(cat, long: true);
    final breed = cat.breed;
    final sex = cat.sex;

    final actionStyle = IconButton.styleFrom(
      backgroundColor: scheme.onPrimary.withValues(alpha: 0.16),
      foregroundColor: scheme.onPrimary,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: scheme.heroGradient,
        borderRadius: AppRadius.xl,
        boxShadow: context.purr.shadowRaised,
      ),
      child: Stack(
        children: [
          // One quiet paw watermark; decorative only.
          Positioned(
            right: -28,
            bottom: -34,
            child: ExcludeSemantics(
              child: Transform.rotate(
                angle: -0.35,
                child: Icon(Icons.pets,
                    size: 170, color: scheme.onPrimary.withValues(alpha: 0.07)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.lg - 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      style: actionStyle,
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit profile',
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    IconButton(
                      style: actionStyle,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete cat',
                      onPressed: onDelete,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Row(
                    children: [
                      CatAvatar(cat: cat, size: 92, ring: true),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: text.headlineMedium
                                  ?.copyWith(color: scheme.onPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (breed != null && breed.isNotEmpty)
                                  _HeroPill(label: breed),
                                if (sex != null && sex.isNotEmpty)
                                  _HeroPill(label: sex),
                                if (age != null) _HeroPill(label: age),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;

  const _HeroPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // Darker (not lighter) than the hero so white text stays >= 4.5:1
        // even over the lightest gradient stop.
        color: scheme.onSurface.withValues(alpha: 0.28),
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onPrimary,
            ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return PurrCard(
      padding: const EdgeInsets.all(AppSpacing.md - 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: text.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: text.headlineSmall?.copyWith(color: scheme.primary)),
        Text(label, style: text.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
