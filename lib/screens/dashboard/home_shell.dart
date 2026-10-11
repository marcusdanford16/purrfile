import 'package:flutter/material.dart';

import '../../models/cat.dart';
import '../../services/cat_service.dart';
import '../../widgets/decor.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/purr_bottom_nav.dart';
import '../ai/ai_assistant_screen.dart';
import '../profile/profile_screen.dart';
import '../reminders/reminders_screen.dart';
import '../timeline/health_timeline_screen.dart';
import 'dashboard_screen.dart';

/// Owns the cat list + "selected cat" and hosts the five bottom-nav tabs, so
/// switching tabs never loses which cat you were looking at. Every screen is
/// reachable: Dashboard picks a cat, the other four tabs act on it.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final CatService _catService = CatService();

  int _tabIndex = 0;
  Cat? _selectedCat;
  List<Cat> _cats = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCats();
  }

  Future<void> _loadCats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await _catService.getCats();
      setState(() {
        _cats = cats;
        if (_selectedCat != null) {
          // Keep the selection in sync after an edit/delete.
          final match = cats.where((c) => c.id == _selectedCat!.id);
          _selectedCat = match.isEmpty ? null : match.first;
        }
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectCatAndGo(Cat cat, int tab) {
    setState(() {
      _selectedCat = cat;
      _tabIndex = tab;
    });
  }

  void _onNavTap(int index) {
    if (index != 0 && _selectedCat == null && _cats.isNotEmpty) {
      // No cat selected yet but cats exist — default to the first one so a
      // direct bottom-nav tap never dead-ends.
      _selectedCat = _cats.first;
    }
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      DashboardScreen(
        cats: _cats,
        loading: _loading,
        error: _error,
        onRefresh: _loadCats,
        onOpenCat: (cat) => _selectCatAndGo(cat, 4),
        onOpenTimeline: (cat) => _selectCatAndGo(cat, 1),
        onOpenReminders: (cat) => _selectCatAndGo(cat, 2),
        onOpenAi: (cat) => _selectCatAndGo(cat, 3),
      ),
      _requireCat(
        (cat) => HealthTimelineScreen(cat: cat),
      ),
      _requireCat(
        (cat) => RemindersScreen(cat: cat, allCats: _cats),
      ),
      _requireCat(
        (cat) => AiAssistantScreen(cat: cat),
      ),
      _requireCat(
        (cat) => ProfileScreen(
          cat: cat,
          onCatChanged: _loadCats,
          onCatDeleted: () {
            setState(() => _selectedCat = null);
            _loadCats();
          },
        ),
      ),
    ];

    // The cream page + green hills sit behind everything; the Scaffolds on
    // top are transparent so every tab shares the same backdrop.
    return Stack(
      children: [
        const Positioned.fill(child: PurrBackdrop()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Theme(
              data: Theme.of(context)
                  .copyWith(scaffoldBackgroundColor: Colors.transparent),
              child: IndexedStack(index: _tabIndex, children: tabs),
            ),
          ),
          bottomNavigationBar:
              PurrBottomNav(currentIndex: _tabIndex, onTap: _onNavTap),
        ),
      ],
    );
  }

  /// Wraps a tab that needs [_selectedCat] with a friendly empty state
  /// instead of crashing or showing a blank screen when nothing is selected.
  Widget _requireCat(Widget Function(Cat cat) builder) {
    final cat = _selectedCat;
    if (cat == null) {
      return Center(
        child: SingleChildScrollView(
          child: EmptyState(
            icon: Icons.pets,
            title: _cats.isEmpty ? 'No cats yet' : 'Pick a cat first',
            message: _cats.isEmpty
                ? 'Add your first cat to get started.'
                : 'Choose a cat on the Home tab to see their details here.',
            actionLabel: 'Go to Home',
            onAction: () => setState(() => _tabIndex = 0),
          ),
        ),
      );
    }
    return builder(cat);
  }
}
