import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/l10n/app_language.dart';
import 'package:language_platform/core/l10n/localized_text.dart';
import 'package:language_platform/features/assessment/domain/quiz.dart';
import 'package:language_platform/features/assessment/presentation/widgets/question_view.dart';

import '../helpers/pump_app.dart';

/// Neutral placeholders: a test fixture only, never part of any lesson.
const _question = MultipleChoiceQuestion(
  id: 'q',
  prompt: LocalizedText.plain('?'),
  options: [
    QuizOption(id: 'a', text: LocalizedText.plain('one')),
    QuizOption(id: 'b', text: LocalizedText.plain('two')),
    QuizOption(id: 'c', text: LocalizedText.plain('three')),
  ],
  correctOptionId: 'a',
);

Future<void> _pump(WidgetTester tester, AppLanguage language) async {
  useScreen(tester, height: 1200);
  await pumpApp(tester, language: language, initialLocation: '/menu');
  // The shared question card is rendered inside the app theme/localization.
  final context = tester.element(find.byType(Scaffold).first);
  await tester.pumpWidget(
    Localizations.override(
      context: context,
      locale: language.locale,
      child: Directionality(
        textDirection: language == AppLanguage.ar
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Theme(
          data: Theme.of(context),
          child: Material(
            child: QuestionView(
              question: _question,
              languageCode: 'en',
              selectedOptionId: null,
              checked: false,
              onSelect: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('QuestionView (shared by the server-graded exercises)', () {
    testWidgets('options carry Latin letter markers in a Latin UI', (
      tester,
    ) async {
      await _pump(tester, AppLanguage.en);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('an Arabic UI uses Arabic letter markers', (tester) async {
      await _pump(tester, AppLanguage.ar);
      expect(find.text('أ'), findsOneWidget);
      expect(find.text('ب'), findsOneWidget);
    });
  });
}
