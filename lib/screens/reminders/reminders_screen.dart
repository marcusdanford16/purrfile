import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/cat.dart';
import '../../models/reminder.dart';
import '../../services/reminder_service.dart';
import '../../utils/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cat_avatar.dart';
import '../../widgets/date_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/reminder_tile.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/skeleton.dart';

/// Reminders for [cat]. [allCats] is only used to label the screen; every
/// reminder shown/created here is scoped to `cat.id`, matching the
/// Dashboard → cat card → Reminders shortcut in the navigation diagram.
class RemindersScreen extends StatefulWidget {
  final Cat cat;
  final List<Cat> allCats;

  const RemindersScreen({super.key, required this.cat, required this.allCats});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  final _service = ReminderService();
  late final TabController _tabController;

  List<Reminder> _reminders = [];
  bool _loading = true;
  String? _error;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reminders = await _service.getRemindersForCat(widget.cat.id);
      setState(() => _reminders = reminders);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Reminder> get _upcoming => _reminders
      .where((r) => r.effectiveStatus != ReminderStatus.completed)
      .toList()
    ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));

  List<Reminder> get _history => _reminders
      .where((r) => r.effectiveStatus == ReminderStatus.completed)
      .toList()
    ..sort((a, b) => b.reminderDate.compareTo(a.reminderDate));

  Future<void> _markDone(Reminder r) async {
    try {
      await _service.markCompleted(r.id);
      await _load();
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<void> _delete(Reminder r) async {
    // A swiped-away Dismissible must leave the widget tree immediately, so
    // drop it from the list first and only then talk to the server.
    setState(() => _reminders = _reminders.where((x) => x.id != r.id).toList());
    try {
      await _service.deleteReminder(r.id);
    } catch (e) {
      _showSnack(e.toString());
      await _load();
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openReminderForm({Reminder? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ReminderFormDialog(catId: widget.cat.id, existing: existing),
    );
    if (saved == true) await _load();
  }

  Future<void> _tryEnableNotifications() async {
    // Web / desktop and many platforms need explicit permission plumbing
    // (flutter_local_notifications, web push, etc.) that's out of scope for
    // the MVP. Degrade gracefully: represent the reminder in-app regardless.
    setState(() => _notificationsEnabled = true);
    _showSnack(
        'Reminders are tracked in-app. Push notifications depend on your platform and aren\'t guaranteed on web.');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openReminderForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
      body: Column(
        children: [
          PurrHeader(
            leading: CatAvatar(cat: widget.cat, size: 44),
            title: 'Reminders',
            subtitle: widget.cat.name,
          ),
          // Segmented Upcoming / History switch.
          Container(
            margin: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.sm),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: scheme.tertiary,
              borderRadius: AppRadius.pill,
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              splashBorderRadius: AppRadius.pill,
              labelColor: scheme.primary,
              unselectedLabelColor: scheme.onTertiary,
              indicator: BoxDecoration(
                color: scheme.surface,
                borderRadius: AppRadius.pill,
                boxShadow: context.purr.shadowSoft,
              ),
              tabs: const [Tab(text: 'Upcoming'), Tab(text: 'History')],
            ),
          ),
          Expanded(
            child: _loading
                ? const Padding(
                    padding: AppSpacing.screenPadding,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SkeletonList(count: 3),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: EmptyState(
                          icon: Icons.cloud_off_outlined,
                          title: "Couldn't load reminders",
                          message: _error!,
                          actionLabel: 'Try again',
                          onAction: _load,
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _list(
                            _upcoming,
                            empty: EmptyState(
                              icon: Icons.notifications_none,
                              title: 'Nothing coming up',
                              message:
                                  'Add a reminder for the next vaccine, checkup or medication.',
                              actionLabel: 'Add reminder',
                              onAction: () => _openReminderForm(),
                            ),
                            showActions: true,
                            text: text,
                          ),
                          _list(
                            _history,
                            empty: const EmptyState(
                              icon: Icons.task_alt_outlined,
                              title: 'No completed reminders yet',
                              message:
                                  'Reminders you mark as done will show up here.',
                            ),
                            showActions: false,
                            text: text,
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<Reminder> items,
      {required Widget empty,
      required bool showActions,
      required TextTheme text}) {
    final scheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md, 96),
        children: [
          if (items.isEmpty)
            empty
          else
            for (final r in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Dismissible(
                  key: ValueKey(r.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: scheme.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Delete',
                            style: text.labelMedium
                                ?.copyWith(color: scheme.onError)),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(Icons.delete_outline, color: scheme.onError),
                      ],
                    ),
                  ),
                  onDismissed: (_) => _delete(r),
                  child: ReminderTile(
                    reminder: r,
                    onTap: () => _openReminderForm(existing: r),
                    onMarkDone: showActions ? () => _markDone(r) : null,
                  ),
                ),
              ),
          if (!_notificationsEnabled) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: AppRadius.md,
                border: Border.all(color: scheme.tertiary),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      color: scheme.onTertiaryContainer),
                  const SizedBox(width: AppSpacing.md - 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Never miss an important update',
                            style: text.titleSmall?.copyWith(
                                color: scheme.onTertiaryContainer)),
                        Text('Enable push notifications.',
                            style: text.bodySmall?.copyWith(
                                color: scheme.onTertiaryContainer)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _tryEnableNotifications,
                    child: const Text('Enable'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderFormDialog extends StatefulWidget {
  final String catId;
  final Reminder? existing;

  const _ReminderFormDialog({required this.catId, this.existing});

  @override
  State<_ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<_ReminderFormDialog> {
  final _service = ReminderService();
  late final TextEditingController _type;
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _type = TextEditingController(text: widget.existing?.reminderType ?? '');
    _date = widget.existing?.reminderDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _type.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (_type.text.trim().isEmpty) {
      setState(() => _error = 'Please describe the reminder.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final reminder = Reminder(
        id: widget.existing?.id ?? '',
        catId: widget.catId,
        reminderType: _type.text.trim(),
        reminderDate: _date,
        notificationStatus:
            widget.existing?.notificationStatus ?? ReminderStatus.upcoming,
      );
      if (widget.existing != null) {
        await _service.updateReminder(reminder);
      } else {
        await _service.addReminder(reminder);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Reminder' : 'Edit Reminder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _type,
            decoration: const InputDecoration(
                labelText: 'Reminder (e.g. Rabies vaccine)'),
          ),
          const SizedBox(height: AppSpacing.sm),
          DateField(
            label: 'Date',
            valueText: DateFormat.yMMMd().format(_date),
            onTap: _pickDate,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            FormErrorBox(_error!),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
