import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../progress/application/progress_providers.dart';
import '../../application/lesson_providers.dart';
import '../../domain/lesson.dart';

/// Ders sonu eylemleri: tamamla, quiz'e git, önceki/sonraki ders.
class LessonActions extends ConsumerWidget {
  const LessonActions({
    super.key,
    required this.lesson,
    required this.onOpenQuiz,
    required this.onOpenLesson,
  });

  final Lesson lesson;
  final VoidCallback onOpenQuiz;
  final ValueChanged<String> onOpenLesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final done = ref.watch(
      progressProvider.select((p) => p.isCompleted(lesson.id)),
    );
    final siblings =
        ref.watch(lessonsForCourseProvider(lesson.courseId)).value ?? const [];
    final index = siblings.indexWhere((l) => l.id == lesson.id);
    final previous = index > 0 ? siblings[index - 1] : null;
    final next = index >= 0 && index < siblings.length - 1
        ? siblings[index + 1]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPrimaryButton(
          label: done ? l10n.lessonCompleted : l10n.markLessonComplete,
          icon: done ? Icons.check_circle : Icons.check,
          onPressed: done
              ? null
              : () {
                  ref.read(progressProvider.notifier).completeLesson(lesson.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.lessonCompletedSnack)),
                  );
                },
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: onOpenQuiz,
          icon: const Icon(Icons.quiz_outlined),
          label: Text(l10n.takeQuiz),
        ),
        if (previous != null || next != null) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: previous == null
                    ? const SizedBox.shrink()
                    : TextButton.icon(
                        onPressed: () => onOpenLesson(previous.id),
                        // arrow_back RTL'de otomatik aynalanır.
                        icon: const Icon(Icons.arrow_back),
                        label: Text(l10n.previousLesson),
                      ),
              ),
              Expanded(
                child: next == null
                    ? const SizedBox.shrink()
                    : TextButton.icon(
                        onPressed: () => onOpenLesson(next.id),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(l10n.nextLesson),
                      ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
