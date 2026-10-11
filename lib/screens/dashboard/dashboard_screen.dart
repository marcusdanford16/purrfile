import 'package:flutter/material.dart';

import '../../models/cat.dart';
import '../../services/auth_service.dart';
import '../../utils/app_spacing.dart';
import '../../widgets/cat_card.dart';
import '../../widgets/decor.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/paw_logo.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/skeleton.dart';
import '../profile/cat_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  final List<Cat> cats;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final ValueChanged<Cat> onOpenCat;
  final ValueChanged<Cat> onOpenTimeline;
  final ValueChanged<Cat> onOpenReminders;
  final ValueChanged<Cat> onOpenAi;

  const DashboardScreen({
    super.key,
    required this.cats,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onOpenCat,
    required this.onOpenTimeline,
    required this.onOpenReminders,
    required this.onOpenAi,
  });

  Future<void> _addCat(BuildContext context) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CatFormScreen()),
    );
    if (saved == true) await onRefresh();
  }

  /// First name from the sign-up form (stored in Supabase user metadata).
  String? _firstName() {
    try {
      final name = AuthService().currentUser?.userMetadata?['name'];
      if (name is String && name.trim().isNotEmpty) {
        return name.trim().split(RegExp(r'\s+')).first;
      }
    } catch (_) {
      // Greeting is a nicety; never let it break the screen.
    }
    return null;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final showFab = cats.isNotEmpty;

    return Scaffold(
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () => _addCat(context),
              icon: const Icon(Icons.add),
              label: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add Cat'),
                  SizedBox(width: AppSpacing.sm),
                  Icon(Icons.pets, size: 20),
                ],
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
          children: [
            _Header(
              greeting: _greeting(),
              name: _firstName(),
              catCount: cats.length,
              loading: loading && cats.isEmpty,
              showPeek: cats.isNotEmpty && !loading,
            ),
            const SizedBox(height: AppSpacing.lg),
            ..._buildBody(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    if (loading && cats.isEmpty) {
      return const [SkeletonList(count: 2, itemHeight: 168)];
    }
    if (error != null) {
      return [
        EmptyState(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load your cats",
          message: error!,
          actionLabel: 'Try again',
          onAction: onRefresh,
        ),
      ];
    }
    if (cats.isEmpty) {
      return [
        EmptyState(
          icon: Icons.pets,
          title: 'No cats yet',
          message:
              'Add your first cat to start their health timeline, reminders and records.',
          actionLabel: 'Add your first cat',
          onAction: () => _addCat(context),
        ),
      ];
    }
    return [
      for (var i = 0; i < cats.length; i++) ...[
        CatCard(
          cat: cats[i],
          onTap: () => onOpenCat(cats[i]),
          onTimeline: () => onOpenTimeline(cats[i]),
          onReminders: () => onOpenReminders(cats[i]),
          onAiAssistant: () => onOpenAi(cats[i]),
          onProfile: () => onOpenCat(cats[i]),
        ),
        if (i != cats.length - 1) const SizedBox(height: AppSpacing.md),
      ],
    ];
  }
}

class _Header extends StatelessWidget {
  final String greeting;
  final String? name;
  final int catCount;
  final bool loading;
  final bool showPeek;

  const _Header({
    required this.greeting,
    required this.name,
    required this.catCount,
    required this.loading,
    required this.showPeek,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final subtitle = loading
        ? 'Fetching your cats…'
        : catCount == 0
            ? "Let's set up your first cat."
            : catCount == 1
                ? "Here's how your cat is doing."
                : "Here are your $catCount cats.";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(
          right: 0,
          top: 52,
          child: ExcludeSemantics(child: PawPrints()),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const PurrLogo(markSize: 46),
                const Spacer(),
                PurrIconButton(
                  icon: Icons.logout,
                  tooltip: 'Log out',
                  onPressed: () => AuthService().logOut(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              header: true,
              child: Text(
                name == null ? greeting : '$greeting,',
                style: text.headlineMedium?.copyWith(fontSize: 30),
              ),
            ),
            if (name != null)
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name!,
                      style: text.headlineMedium?.copyWith(
                        fontSize: 34,
                        color: scheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.favorite_border, size: 22, color: scheme.primary),
                ],
              ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        if (showPeek)
          const Positioned(
            right: 22,
            bottom: -(AppSpacing.lg + 4),
            child: ExcludeSemantics(child: CatPeek(width: 112)),
          ),
      ],
    );
  }
}
