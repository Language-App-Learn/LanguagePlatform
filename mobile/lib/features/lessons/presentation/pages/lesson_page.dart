import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/content_width.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../language_selection/application/content_language.dart';
import '../../../progress/application/progress_providers.dart';
import '../../application/lesson_providers.dart';
import '../../domain/lesson.dart';
import '../widgets/lesson_actions.dart';
import '../widgets/lesson_content_view.dart';

/// Ders ekranı: içerik blokları sırayla + eylemler (tamamla, quiz, gezinme).
class LessonPage extends ConsumerWidget {
  const LessonPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref.watch(lessonProvider(lessonId));
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.value?.title.resolve(context.languageCode) ?? ''),
      ),
      body: SafeArea(
        child: AsyncValueView<Lesson>(
          value: lesson,
          onRetry: () => ref.invalidate(lessonProvider(lessonId)),
          data: (lesson) => _LessonBody(lesson: lesson),
        ),
      ),
    );
  }
}

class _LessonBody extends ConsumerStatefulWidget {
  const _LessonBody({required this.lesson});

  final Lesson lesson;

  @override
  ConsumerState<_LessonBody> createState() => _LessonBodyState();
}

class _LessonBodyState extends ConsumerState<_LessonBody> {
  @override
  void initState() {
    super.initState();
    // Remember the last opened lesson for "continue". Opening a lesson does
    // NOT complete it. Deferred: providers must not change during build.
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(progressProvider.notifier)
          .markOpened(widget.lesson.courseId, widget.lesson.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final contentLanguage = ref.watch(contentLanguageProvider);
    return ContentWidth(
      // Lazy: only visible blocks of long lessons are built.
      child: ListView.separated(
        padding: AppSpacing.page,
        itemCount: lesson.contents.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xl),
        itemBuilder: (context, i) {
          if (i == lesson.contents.length) {
            return LessonActions(
              lesson: lesson,
              onOpenQuiz: () => context.push(AppRoutes.quizOf(lesson.id)),
              onOpenLesson: (id) =>
                  context.pushReplacement(AppRoutes.lessonOf(id)),
            );
          }
          return LessonContentView(
            lesson: lesson,
            content: lesson.contents[i],
            contentLanguage: contentLanguage,
          );
        },
      ),
    );
  }
}
