import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../lessons/application/lesson_providers.dart';
import '../../../lessons/domain/lesson.dart';
import '../../application/track_providers.dart';
import '../../domain/lesson_stage.dart';
import '../widgets/exercise_stages.dart';
import '../widgets/reading_speaking_stages.dart';
import '../widgets/stage_widgets.dart';

/// Dispatches to the purpose-built screen of one stage. Direct URL access to
/// a stage that is locked or has no content shows an explanatory state.
class StagePage extends ConsumerStatefulWidget {
  const StagePage({super.key, required this.lessonId, required this.stage});

  final String lessonId;
  final String stage;

  @override
  ConsumerState<StagePage> createState() => _StagePageState();
}

class _StagePageState extends ConsumerState<StagePage> {
  LessonStage? get _stage => LessonStage.values.asNameMap()[widget.stage];

  @override
  void initState() {
    super.initState();
    // Mark the stage as started (never completes it).
    Future.microtask(() {
      final stage = _stage;
      if (!mounted || stage == null) return;
      ref.read(stageRecordsProvider.notifier).start(widget.lessonId, stage);
    });
  }

  void _finish(int? score) {
    final stage = _stage!;
    ref
        .read(stageRecordsProvider.notifier)
        .complete(widget.lessonId, stage, score);
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stage = _stage;
    final lesson = ref.watch(lessonProvider(widget.lessonId));
    return Scaffold(
      appBar: AppBar(title: Text(stage == null ? '' : l10n.stageName(stage))),
      body: SafeArea(
        child: stage == null
            ? EmptyStateView(icon: Icons.search_off, title: l10n.errorNotFound)
            : AsyncValueView<Lesson>(
                value: lesson,
                onRetry: () => ref.invalidate(lessonProvider(widget.lessonId)),
                data: (lesson) => _buildStage(context, lesson, stage),
              ),
      ),
    );
  }

  Widget _buildStage(BuildContext context, Lesson lesson, LessonStage stage) {
    final l10n = context.l10n;
    final content = ref.watch(stageContentProvider(lesson.id));
    final records = ref.watch(
      stageRecordsProvider.select((m) => m[lesson.id] ?? const {}),
    );
    final status = stageStatus(
      stage: stage,
      records: records,
      hasContent: (s) => stageHasContent(lesson, content, s),
    );
    if (status == StageStatus.locked || status == StageStatus.unavailable) {
      return EmptyStateView(
        icon: status == StageStatus.locked
            ? Icons.lock_outline
            : Icons.hourglass_empty,
        title: l10n.statusName(status),
        message: status == StageStatus.unavailable
            ? l10n.stageContentMissing
            : null,
      );
    }
    final body = switch (stage) {
      LessonStage.reading => ReadingStageBody(
        content: content!.reading!,
        onFinish: _finish,
      ),
      LessonStage.speaking => SpeakingStageBody(
        lesson: lesson,
        onFinish: () => _finish(null),
      ),
      LessonStage.listening => ListeningStageBody(
        content: content!.listening!,
        onFinish: _finish,
      ),
      LessonStage.writing => WritingStageBody(
        content: content!.writing!,
        onFinish: _finish,
      ),
      LessonStage.translation => TranslationStageBody(
        content: content!.translation!,
        onFinish: _finish,
      ),
    };
    return ContentWidth(
      child: ListView(
        padding: AppSpacing.page,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.stageDescription(stage),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const DemoBadge(),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          body,
        ],
      ),
    );
  }
}
