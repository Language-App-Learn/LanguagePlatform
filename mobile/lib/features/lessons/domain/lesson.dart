import 'package:flutter/foundation.dart';

import '../../../core/l10n/localized_text.dart';
import '../../assessment/domain/quiz.dart';
import 'example_sentence.dart';

/// Bir kursun dersi. İçerik, sıralı [LessonContent] bloklarından oluşur.
///
/// Backend sözleşmesi bilinmiyor: ders gövdesinin tek yanıtla mı yoksa blok
/// blok mu geleceği, blok türü ayırt edici alanı ve medya URL biçimi
/// netleşince `data/` katmanında eşlenecek.
@immutable
class Lesson {
  const Lesson({
    required this.id,
    required this.courseId,
    required this.languageCode,
    required this.title,
    required this.order,
    required this.estimatedMinutes,
    required this.contents,
  });

  final String id;
  final String courseId;

  /// Öğrenilen dil (içerik metinlerinin dili; yazı yönünü belirler).
  final String languageCode;
  final LocalizedText title;
  final int order;
  final int estimatedMinutes;
  final List<LessonContent> contents;

  /// Dersteki tüm kelime kimlikleri (quiz üretimi için).
  List<String> get vocabularyIds => [
    for (final content in contents)
      if (content is VocabularyContent) ...content.itemIds,
  ];
}

/// Ders içerik bloğu. Gelecekte dinleme, video, ses kaydı, konuşma ve AI
/// etkinlikleri yeni alt sınıflar olarak eklenir; `switch` ifadelerinin
/// tümü sealed olduğu için derleyici eksik işlenen yerleri gösterir.
@immutable
sealed class LessonContent {
  const LessonContent();
}

final class HeadingContent extends LessonContent {
  const HeadingContent(this.text);

  final LocalizedText text;
}

final class TextContent extends LessonContent {
  const TextContent(this.text);

  final LocalizedText text;
}

@immutable
class DialogueLine {
  const DialogueLine({
    required this.speaker,
    required this.text,
    required this.translation,
  });

  final String speaker;

  /// Öğrenilen dildeki satır.
  final String text;
  final LocalizedText translation;
}

final class DialogueContent extends LessonContent {
  const DialogueContent(this.lines);

  final List<DialogueLine> lines;
}

/// Kelime listesi; kelimeler kimlikle `VocabularyRepository`'den çözülür.
final class VocabularyContent extends LessonContent {
  const VocabularyContent(this.itemIds);

  final List<String> itemIds;
}

final class GrammarContent extends LessonContent {
  const GrammarContent({
    required this.title,
    required this.explanation,
    this.examples = const [],
  });

  final LocalizedText title;
  final LocalizedText explanation;
  final List<ExampleSentence> examples;
}

final class ExampleContent extends LessonContent {
  const ExampleContent(this.example);

  final ExampleSentence example;
}

/// Ders içi basit alıştırma (quiz motoru ile aynı soru modeli).
final class ExerciseContent extends LessonContent {
  const ExerciseContent(this.question);

  final MultipleChoiceQuestion question;
}
