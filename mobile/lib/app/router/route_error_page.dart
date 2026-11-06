import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/widgets/state_views.dart';
import '../../core/l10n/l10n.dart';
import 'app_routes.dart';

/// Shown for unknown or malformed routes (e.g. a bad deep link).
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: EmptyStateView(
          icon: Icons.explore_off_outlined,
          title: l10n.pageNotFoundTitle,
          message: l10n.pageNotFoundMessage,
          actionLabel: l10n.goHome,
          onAction: () => context.go(AppRoutes.splash),
        ),
      ),
    );
  }
}
