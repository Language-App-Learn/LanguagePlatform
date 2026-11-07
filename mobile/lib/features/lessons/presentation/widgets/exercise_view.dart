import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/app_primary_button.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../assessment/domain/quiz.dart';
// Ders içi alıştırma, quiz ile aynı soru görünümünü yeniden kullanır
// (aynı UI'ı iki kez yazmamak için bilinçli feature'lar arası bağımlılık).
import '../../../assessment/presentation/widgets/question_view.dart';
import 'lesson_sections.dart';

/// Ders içi basit alıştırma: seç → kontrol et → (gerekirse) tekrar dene.
/// Sonuç yalnızca ekranda gösterilir, ilerlemeye yazılmaz.
class ExerciseView extends StatefulWidget {
  const ExerciseView({
    super.key,
    required this.question,
    required this.contentLanguage,
  });

  final MultipleChoiceQuestion question;
  final String contentLanguage;

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  String? _selected;
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wrong = _checked && _selected != widget.question.correctOptionId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LessonSectionLabel(icon: Icons.edit_note, label: l10n.lessonExercise),
        QuestionView(
          question: widget.question,
          languageCode: widget.contentLanguage,
          selectedOptionId: _selected,
          checked: _checked,
          onSelect: (id) => setState(() => _selected = id),
        ),
        const SizedBox(height: AppSpacing.md),
        if (!_checked)
          AppPrimaryButton(
            label: l10n.checkAnswer,
            onPressed: _selected == null
                ? null
                : () => setState(() => _checked = true),
          )
        else if (wrong)
          OutlinedButton.icon(
            onPressed: () => setState(() {
              _selected = null;
              _checked = false;
            }),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.quizTryAgain),
          ),
      ],
    );
  }
}
