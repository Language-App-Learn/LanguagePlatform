import '../../../core/l10n/localized_text.dart';
import '../../assessment/domain/quiz.dart';
import '../domain/stage_content.dart';

/// DEMO fixture for lesson `ar-a1-l1` only. It exists to exercise the stage
/// screens; it is not teacher-approved curriculum and the answer keys are
/// local (real keys stay on the server). All other lessons have no stage
/// content and show an honest "not published" state.
const demoStageContent = <String, LessonStageContent>{
  'ar-a1-l1': LessonStageContent(
    reading: ReadingContent(
      title: LocalizedText({'tr': 'Tanışma', 'en': 'Meeting someone'}),
      segments: [
        ReadingSegment(
          id: 'ar-a1-l1-r1',
          arabic: 'مَرْحَبًا! أَنَا أَحْمَدُ.',
          translation: LocalizedText({
            'tr': 'Merhaba! Ben Ahmet.',
            'en': 'Hello! I am Ahmad.',
          }),
        ),
        ReadingSegment(
          id: 'ar-a1-l1-r2',
          arabic: 'أَنَا مِنْ تُرْكِيَا.',
          translation: LocalizedText({
            'tr': 'Ben Türkiye’denim.',
            'en': 'I am from Turkey.',
          }),
        ),
        ReadingSegment(
          id: 'ar-a1-l1-r3',
          arabic: 'أَنَا طَالِبٌ.',
          translation: LocalizedText({
            'tr': 'Ben öğrenciyim.',
            'en': 'I am a student.',
          }),
        ),
      ],
      questions: [
        MultipleChoiceQuestion(
          id: 'demo-r-q1',
          prompt: LocalizedText({
            'tr': 'Metindeki kişinin adı nedir?',
            'en': 'What is the person’s name?',
          }),
          options: [
            QuizOption(id: 'a', text: LocalizedText.plain('أَحْمَدُ')),
            QuizOption(id: 'b', text: LocalizedText.plain('سَارَةُ')),
            QuizOption(id: 'c', text: LocalizedText.plain('عَلِيٌّ')),
          ],
          correctOptionId: 'a',
        ),
        MultipleChoiceQuestion(
          id: 'demo-r-q2',
          prompt: LocalizedText({
            'tr': 'Kişi nereli?',
            'en': 'Where is the person from?',
          }),
          options: [
            QuizOption(id: 'a', text: LocalizedText.plain('مِصْرُ')),
            QuizOption(id: 'b', text: LocalizedText.plain('تُرْكِيَا')),
            QuizOption(id: 'c', text: LocalizedText.plain('سُورِيَا')),
          ],
          correctOptionId: 'b',
        ),
        MultipleChoiceQuestion(
          id: 'demo-r-q3',
          prompt: LocalizedText({
            'tr': 'Kişi ne iş yapıyor?',
            'en': 'What does the person do?',
          }),
          options: [
            QuizOption(id: 'a', text: LocalizedText.plain('مُعَلِّمٌ')),
            QuizOption(id: 'b', text: LocalizedText.plain('طَبِيبٌ')),
            QuizOption(id: 'c', text: LocalizedText.plain('طَالِبٌ')),
          ],
          correctOptionId: 'c',
        ),
      ],
    ),
    listening: ListeningContent(
      sentences: [
        ListeningSentence(parts: [null, ' يَا أَحْمَدُ!']),
        ListeningSentence(parts: [null, ' لَكَ.']),
      ],
      wordBank: ['شُكْرًا', 'نَعَمْ', 'مَرْحَبًا'],
      answers: ['مَرْحَبًا', 'شُكْرًا'],
    ),
    writing: WritingContent(
      fillBlanks: [
        FillBlankItem(
          before: 'اِسْمِي ',
          after: '.',
          accepted: ['سَارَةُ', 'سارة'],
        ),
      ],
      arrange: [
        ArrangeItem(
          correctOrder: ['أَهْلًا', 'بِكَ', 'يَا', 'سَارَةُ'],
          shownOrder: [2, 0, 3, 1],
        ),
      ],
    ),
    translation: TranslationContent(
      choice: [
        TranslationChoiceItem(
          turkish: 'Merhaba!',
          options: ['شُكْرًا', 'مَرْحَبًا', 'نَعَمْ'],
          correctIndex: 1,
        ),
      ],
      write: [
        TranslationWriteItem(
          turkish: 'Teşekkürler.',
          accepted: ['شُكْرًا', 'شكرا'],
        ),
      ],
    ),
  ),
};
