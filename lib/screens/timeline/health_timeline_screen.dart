import 'package:flutter/material.dart';

import '../../models/cat.dart';
import '../../models/health_record.dart';
import '../../services/health_record_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_spacing.dart';
import '../../widgets/cat_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chip_bar.dart';
import '../../widgets/health_record_tile.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/skeleton.dart';
import 'add_health_record_screen.dart';

const _filterOptions = ['All', 'Vaccination', 'Vet Visit', 'Weight', 'Illness'];

class HealthTimelineScreen extends StatefulWidget {
  final Cat cat;

  const HealthTimelineScreen({super.key, required this.cat});

  @override
  State<HealthTimelineScreen> createState() => _HealthTimelineScreenState();
}

class _HealthTimelineScreenState extends State<HealthTimelineScreen> {
  final _service = HealthRecordService();
  List<HealthRecord> _records = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HealthTimelineScreen old) {
    super.didUpdateWidget(old);
    if (old.cat.id != widget.cat.id) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final records = await _service.getRecordsForCat(widget.cat.id);
      setState(() => _records = records);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openRecord({HealthRecord? existing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AddHealthRecordScreen(catId: widget.cat.id, existing: existing),
      ),
    );
    if (saved == true) await _load();
  }

  List<HealthRecord> get _filtered => _filter == 'All'
      ? _records
      : _records.where((r) => r.recordType.label == _filter).toList();

  Map<int, List<HealthRecord>> get _byYear {
    final map = <int, List<HealthRecord>>{};
    for (final r in _filtered) {
      map.putIfAbsent(r.date.year, () => []).add(r);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRecord(),
        icon: const Icon(Icons.add),
        label: const Text('Add health record'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            PurrHeader(
              leading: CatAvatar(cat: widget.cat, size: 44),
              title: 'Health timeline',
              subtitle: widget.cat.name,
            ),
            FilterChipBar(
              options: _filterOptions,
              selected: _filter,
              onSelected: (v) => setState(() => _filter = v),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._buildBody(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_loading) {
      return const [
        Padding(
          padding: AppSpacing.screenPadding,
          child: SkeletonList(count: 4),
        ),
      ];
    }
    if (_error != null) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load the timeline",
          message: _error!,
          actionLabel: 'Try again',
          onAction: _load,
        ),
      ];
    }
    if (_filtered.isEmpty) {
      return [
        if (_filter == 'All')
          EmptyState(
            icon: Icons.history_edu_outlined,
            title: 'No health records yet',
            message:
                'Vaccinations, vet visits and weigh-ins for ${widget.cat.name} will appear here.',
            actionLabel: 'Add first record',
            onAction: () => _openRecord(),
          )
        else
          EmptyState(
            icon: Icons.filter_list,
            title: 'No ${_filter.toLowerCase()} records',
            message: 'Try another filter to see the rest of the timeline.',
          ),
      ];
    }

    final years = _byYear.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final year in years) _YearSection(
        year: year,
        records: _byYear[year]!,
        onOpen: (r) => _openRecord(existing: r),
      ),
    ];
  }
}

/// One year heading followed by its records on a vertical rail: a coloured
/// dot per record (colour = record type) joined by a thin line.
class _YearSection extends StatelessWidget {
  final int year;
  final List<HealthRecord> records;
  final ValueChanged<HealthRecord> onOpen;

  const _YearSection({
    required this.year,
    required this.records,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final count = records.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$year', style: text.titleLarge),
                const SizedBox(width: AppSpacing.sm),
                Text('$count ${count == 1 ? 'record' : 'records'}',
                    style: text.bodySmall),
              ],
            ),
          ),
          for (var i = 0; i < records.length; i++)
            _RailRow(
              record: records[i],
              isFirst: i == 0,
              isLast: i == records.length - 1,
              onTap: () => onOpen(records[i]),
            ),
        ],
      ),
    );
  }
}

class _RailRow extends StatelessWidget {
  final HealthRecord record;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _RailRow({
    required this.record,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tone = toneForRecordType(context.purr, record.recordType);
    final line = scheme.outline.withValues(alpha: 0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                // Top segment ends where the tile's icon is centred.
                Container(
                    width: 2, height: 28, color: isFirst ? null : line),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tone.color,
                    border: Border.all(
                        color: scheme.surfaceContainerLowest, width: 2),
                  ),
                ),
                Expanded(
                  child: Container(width: 2, color: isLast ? null : line),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: HealthRecordTile(
              record: record,
              onTap: onTap,
              showYear: false,
            ),
          ),
        ],
      ),
    );
  }
}
