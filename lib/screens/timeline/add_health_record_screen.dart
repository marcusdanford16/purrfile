import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/health_record.dart';
import '../../services/health_record_service.dart';
import '../../utils/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/date_field.dart';
import '../../widgets/health_record_tile.dart';
import '../../widgets/primary_button.dart';

/// Add or edit a health record for a specific cat. Pass [existing] to edit.
class AddHealthRecordScreen extends StatefulWidget {
  final String catId;
  final HealthRecord? existing;

  const AddHealthRecordScreen({super.key, required this.catId, this.existing});

  @override
  State<AddHealthRecordScreen> createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = HealthRecordService();

  late final TextEditingController _description;
  late final TextEditingController _vet;
  late final TextEditingController _clinic;
  late final TextEditingController _notes;
  RecordType _type = RecordType.vaccination;
  DateTime _date = DateTime.now();
  DateTime? _nextDue;

  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _description = TextEditingController(text: r?.description ?? '');
    _vet = TextEditingController(text: r?.veterinarian ?? '');
    _clinic = TextEditingController(text: r?.clinic ?? '');
    _notes = TextEditingController(text: r?.notes ?? '');
    _type = r?.recordType ?? RecordType.vaccination;
    _date = r?.date ?? DateTime.now();
    _nextDue = r?.nextDueDate;
  }

  @override
  void dispose() {
    _description.dispose();
    _vet.dispose();
    _clinic.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isNextDue}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isNextDue ? _nextDue : _date) ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isNextDue) {
        _nextDue = picked;
      } else {
        _date = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final record = HealthRecord(
        id: widget.existing?.id ?? '',
        catId: widget.catId,
        recordType: _type,
        date: _date,
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        veterinarian: _vet.text.trim().isEmpty ? null : _vet.text.trim(),
        clinic: _clinic.text.trim().isEmpty ? null : _clinic.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        nextDueDate: _nextDue,
      );
      if (_isEditing) {
        await _service.updateRecord(record);
      } else {
        await _service.addRecord(record);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text('This cannot be undone.'),
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
    setState(() => _saving = true);
    try {
      await _service.deleteRecord(widget.existing!.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final purr = context.purr;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Health Record' : 'Add Health Record'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete record',
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Record type as colour-coded chips (same colours the
                    // timeline uses) instead of a hidden dropdown.
                    Padding(
                      padding: const EdgeInsets.only(
                          top: AppSpacing.sm,
                          bottom: AppSpacing.sm,
                          left: AppSpacing.xs),
                      child: Text('What kind of record?',
                          style: text.titleMedium),
                    ),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final t in RecordType.values)
                          Builder(builder: (context) {
                            final tone = toneForRecordType(purr, t);
                            final selected = t == _type;
                            return ChoiceChip(
                              avatar: Icon(iconForRecordType(t),
                                  size: 18, color: tone.onContainer),
                              label: Text(t.label),
                              selected: selected,
                              showCheckmark: false,
                              selectedColor: tone.container,
                              backgroundColor: scheme.surface,
                              side: BorderSide(
                                color: selected
                                    ? tone.color
                                    : scheme.outlineVariant,
                                width: selected ? 2 : 1,
                              ),
                              labelStyle: text.labelMedium?.copyWith(
                                color: selected
                                    ? tone.onContainer
                                    : scheme.onSurface,
                              ),
                              onSelected: (_) => setState(() => _type = t),
                            );
                          }),
                      ],
                    ),
                    const FormSectionTitle('Details'),
                    DateField(
                      label: 'Date',
                      valueText: DateFormat.yMMMd().format(_date),
                      onTap: () => _pickDate(isNextDue: false),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    TextFormField(
                      controller: _description,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    TextFormField(
                      controller: _notes,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const FormSectionTitle('Clinic & follow-up'),
                    TextFormField(
                      controller: _vet,
                      decoration:
                          const InputDecoration(labelText: 'Veterinarian'),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    TextFormField(
                      controller: _clinic,
                      decoration: const InputDecoration(labelText: 'Clinic'),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    DateField(
                      label: 'Next due date (optional)',
                      valueText: _nextDue == null
                          ? 'None'
                          : DateFormat.yMMMd().format(_nextDue!),
                      onTap: () => _pickDate(isNextDue: true),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      FormErrorBox(_error!),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: _saving ? 'Saving…' : 'Save Record',
                      onPressed: _submit,
                      loading: _saving,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
