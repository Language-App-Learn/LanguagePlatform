import 'package:flutter/foundation.dart';

import '../../../core/l10n/localized_text.dart';
import '../../assessment/domain/quiz.dart';

/// One logical reading line. The [id] is stable (server-assigned in real
/// content) and identifies the audio unit; lines are never re-split on the
/// device.
@immutable
class ReadingSegment {
  const ReadingSegment({
    required this.id,
    required this.arabic,
    required this.translation,
  });

  final String id;
  final String arabic;
  final LocalizedText translation;
}

@immutable
class ReadingContent {
  const ReadingContent({
    required this.title,
    required this.segments,
    required this.questions,
  });

  final LocalizedText title;
  final List<ReadingSegment> segments;
  final List<MultipleChoiceQuestion> questions;
}

/// A listening sentence: text parts where `null` marks a blank.
@immutable
class ListeningSentence {
  const ListeningSentence({required this.parts});

  /// Text parts and blanks in logical (reading) order.
  final List<String?> parts;
}

@immutable
class ListeningContent {
  const ListeningContent({
    required this.sentences,
    required this.wordBank,
    required this.answers,
  });

  final List<ListeningSentence> sentences;

  /// Words offered to the learner (already in display order).
  final List<String> wordBank;

  /// Correct word per blank, in reading order. DEMO ONLY: real answer keys
  /// stay on the server.
  final List<String> answers;

  int get blankCount => answers.length;
}

@immutable
class FillBlankItem {
  const FillBlankItem({
    required this.before,
    required this.after,
    required this.accepted,
  });

  final String before;
  final String after;

  /// Accepted answers (exact comparison; diacritic variants are listed
  /// explicitly rather than stripped).
  final List<String> accepted;
}

@immutable
class ArrangeItem {
  const ArrangeItem({required this.correctOrder, required this.shownOrder});

  /// Tokens in the correct logical order.
  final List<String> correctOrder;

  /// Indices into [correctOrder] describing the shuffled bank display.
  final List<int> shownOrder;
}

@immutable
class WritingContent {
  const WritingContent({required this.fillBlanks, required this.arrange});

  final List<FillBlankItem> fillBlanks;
  final List<ArrangeItem> arrange;
}

@immutable
class TranslationChoiceItem {
  const TranslationChoiceItem({
    required this.turkish,
    required this.options,
    required this.correctIndex,
  });

  final String turkish;
  final List<String> options;
  final int correctIndex;
}

@immutable
class TranslationWriteItem {
  const TranslationWriteItem({required this.turkish, required this.accepted});

  final String turkish;
  final List<String> accepted;
}

@immutable
class TranslationContent {
  const TranslationContent({required this.choice, required this.write});

  final List<TranslationChoiceItem> choice;
  final List<TranslationWriteItem> write;
}

/// Content of the non-dialogue stages of one lesson. In production this is
/// published server content; today only a small DEMO fixture exists.
@immutable
class LessonStageContent {
  const LessonStageContent({
    this.reading,
    this.listening,
    this.writing,
    this.translation,
  });

  final ReadingContent? reading;
  final ListeningContent? listening;
  final WritingContent? writing;
  final TranslationContent? translation;
}
