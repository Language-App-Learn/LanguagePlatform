import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../courses/application/course_providers.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../../application/catalog_filter.dart';
import '../../../learning_track/application/track_providers.dart';
import '../widgets/catalog_filters.dart';
import '../widgets/remote_catalog_view.dart';

/// Kurs kataloğu: arama, dil ve seviye filtreleri, kurs kartları.
class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (ref.watch(contentModeProvider) == ContentMode.remote) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.coursesTitle)),
        body: const SafeArea(child: ContentWidth(child: RemoteCatalogView())),
      );
    }
    final courses = ref.watch(filteredCoursesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.coursesTitle)),
      body: SafeArea(
        child: ContentWidth(
          child: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                sliver: SliverToBoxAdapter(child: CatalogFilters()),
              ),
              courses.when(
                skipLoadingOnReload: true,
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: LoadingView(),
                ),
                error: (error, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorStateView(
                    error: error,
                    onRetry: () => ref.invalidate(coursesProvider),
                  ),
                ),
                data: (list) => list.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyStateView(
                          icon: Icons.search_off,
                          title: l10n.noCoursesTitle,
                          message: l10n.noCoursesMessage,
                          actionLabel: l10n.clearFilters,
                          onAction: ref
                              .read(catalogFilterProvider.notifier)
                              .clear,
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xxl,
                        ),
                        // Lazy liste: yalnızca görünen kartlar oluşturulur.
                        sliver: SliverList.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, i) =>
                              CourseCard(course: list[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
