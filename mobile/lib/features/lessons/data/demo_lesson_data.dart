import '../../../core/l10n/localized_text.dart';
import '../../assessment/domain/quiz.dart';
import '../domain/example_sentence.dart';
import '../domain/lesson.dart';

/// DEMO içerik: yalnızca geliştirme/gösterim içindir, gerçek müfredat değildir.
const demoLessons = <Lesson>[
  // ================= Arapça A1 =================
  Lesson(
    id: 'ar-a1-l1',
    courseId: 'ar-a1-basics',
    languageCode: 'ar',
    order: 1,
    estimatedMinutes: 8,
    title: LocalizedText({
      'tr': 'Selamlaşma',
      'en': 'Greetings',
      'ar': 'التحية',
    }),
    contents: [
      HeadingContent(
        LocalizedText({
          'tr': 'Selam ver ve karşılık ver',
          'en': 'Say hello and reply',
        }),
      ),
      TextContent(
        LocalizedText({
          'tr': 'Bu derste Arapçada selam vermeyi ve karşılık vermeyi öğreneceksin.',
          'en': 'In this lesson you will learn how to greet someone and reply in Arabic.',
        }),
      ),
      DialogueContent([
        DialogueLine(
          speaker: 'Ali',
          text: 'مرحبًا!',
          translation: LocalizedText({'tr': 'Merhaba!', 'en': 'Hello!'}),
        ),
        DialogueLine(
          speaker: 'Sara',
          text: 'أهلًا!',
          translation: LocalizedText({'tr': 'Hoş geldin!', 'en': 'Welcome!'}),
        ),
        DialogueLine(
          speaker: 'Ali',
          text: 'شكرًا.',
          translation: LocalizedText({
            'tr': 'Teşekkürler.',
            'en': 'Thank you.',
          }),
        ),
      ]),
      VocabularyContent([
        'ar-marhaba',
        'ar-ahlan',
        'ar-shukran',
        'ar-ma-salama',
      ]),
      ExampleContent(
        ExampleSentence(
          text: 'مع السلامة!',
          translation: LocalizedText({'tr': 'Hoşça kal!', 'en': 'Goodbye!'}),
        ),
      ),
      ExerciseContent(
        MultipleChoiceQuestion(
          id: 'ar-a1-l1-ex1',
          prompt: LocalizedText({
            'tr': 'Arapçada “teşekkürler” hangisidir?',
            'en': 'Which one means “thank you” in Arabic?',
          }),
          options: [
            QuizOption(id: 'a', text: LocalizedText.plain('شكرًا')),
            QuizOption(id: 'b', text: LocalizedText.plain('مرحبًا')),
            QuizOption(id: 'c', text: LocalizedText.plain('نعم')),
          ],
          correctOptionId: 'a',
          explanation: LocalizedText({
            'tr': '“شكرًا” (shukran) teşekkür etmek için kullanılır.',
            'en': '“شكرًا” (shukran) is used to say thank you.',
          }),
        ),
      ),
    ],
  ),
  Lesson(
    id: 'ar-a1-l2',
    courseId: 'ar-a1-basics',
    languageCode: 'ar',
    order: 2,
    estimatedMinutes: 10,
    title: LocalizedText({
      'tr': 'Kendini tanıtma',
      'en': 'Introducing yourself',
      'ar': 'التعريف بنفسك',
    }),
    contents: [
      HeadingContent(
        LocalizedText({'tr': 'Adını söyle', 'en': 'Say your name'}),
      ),
      DialogueContent([
        DialogueLine(
          speaker: 'Sara',
          text: 'مرحبًا! اسمي سارة.',
          translation: LocalizedText({
            'tr': 'Merhaba! Benim adım Sara.',
            'en': 'Hello! My name is Sara.',
          }),
        ),
        DialogueLine(
          speaker: 'Ali',
          text: 'أهلًا يا سارة! اسمي علي.',
          translation: LocalizedText({
            'tr': 'Hoş geldin Sara! Benim adım Ali.',
            'en': 'Welcome, Sara! My name is Ali.',
          }),
        ),
      ]),
      VocabularyContent(['ar-ismi', 'ar-naam', 'ar-la']),
      GrammarContent(
        title: LocalizedText({'tr': 'Adını söyleme', 'en': 'Saying your name'}),
        explanation: LocalizedText({
          'tr': 'Arapçada burada “-dir” anlamında ayrı bir fiil gerekmez. “اسمي” (ismī) “benim adım” demektir; hemen ardından adını söylersin.',
          'en': 'Arabic needs no separate verb for “is” here. “اسمي” (ismī) means “my name”; just say your name right after it.',
        }),
        examples: [
          ExampleSentence(
            text: 'اسمي علي.',
            translation: LocalizedText({
              'tr': 'Benim adım Ali.',
              'en': 'My name is Ali.',
            }),
          ),
        ],
      ),
      ExerciseContent(
        MultipleChoiceQuestion(
          id: 'ar-a1-l2-ex1',
          prompt: LocalizedText({
            'tr': 'Arapçada “benim adım” nasıl söylenir?',
            'en': 'How do you say “my name is” in Arabic?',
          }),
          options: [
            QuizOption(id: 'a', text: LocalizedText.plain('كتاب')),
            QuizOption(id: 'b', text: LocalizedText.plain('اسمي')),
            QuizOption(id: 'c', text: LocalizedText.plain('مدرسة')),
          ],
          correctOptionId: 'b',
        ),
      ),
    ],
  ),
  Lesson(
    id: 'ar-a1-l3',
    courseId: 'ar-a1-basics',
    languageCode: 'ar',
    order: 3,
    estimatedMinutes: 9,
    title: LocalizedText({
      'tr': 'Sayılar ve okul',
      'en': 'Numbers and school',
      'ar': 'الأرقام والمدرسة',
    }),
    contents: [
      HeadingContent(LocalizedText({'tr': 'Birden üçe', 'en': 'One to three'})),
      TextContent(
        LocalizedText({
          'tr':
              'Birden üçe kadar sayıları ve okulla ilgili iki kelimeyi öğren.',
          'en': 'Learn the numbers one to three and two words about school.',
        }),
      ),
      VocabularyContent([
        'ar-wahid',
        'ar-ithnan',
        'ar-thalatha',
        'ar-kitab',
        'ar-madrasa',
      ]),
      ExampleContent(
        ExampleSentence(
          text: 'هذا كتاب.',
          translation: LocalizedText({
            'tr': 'Bu bir kitap.',
            'en': 'This is a book.',
          }),
        ),
      ),
    ],
  ),

  // ================= İngilizce A1 =================
  Lesson(
    id: 'en-a1-l1',
    courseId: 'en-a1-everyday',
    languageCode: 'en',
    order: 1,
    estimatedMinutes: 8,
    title: LocalizedText({
      'tr': 'Merhaba ve temel ifadeler',
      'en': 'Hello and the basics',
      'ar': 'مرحبًا والأساسيات',
    }),
    contents: [
      HeadingContent(
        LocalizedText({
          'tr': 'İlk cümlelerin',
          'ar': 'جملك الأولى',
          'en': 'Your first sentences',
        }),
      ),
      DialogueContent([
        DialogueLine(
          speaker: 'Anna',
          text: 'Hello! I am Anna.',
          translation: LocalizedText({
            'tr': 'Merhaba! Ben Anna.',
            'ar': 'مرحبًا! أنا آنا.',
          }),
        ),
        DialogueLine(
          speaker: 'Tom',
          text: 'Hi Anna! Thank you for coming.',
          translation: LocalizedText({
            'tr': 'Selam Anna! Geldiğin için teşekkürler.',
            'ar': 'أهلًا آنا! شكرًا لحضورك.',
          }),
        ),
        DialogueLine(
          speaker: 'Anna',
          text: 'Please, call me Ann.',
          translation: LocalizedText({
            'tr': 'Lütfen bana Ann de.',
            'ar': 'من فضلك، نادني آن.',
          }),
        ),
      ]),
      VocabularyContent(['en-hello', 'en-goodbye', 'en-thanks', 'en-please']),
      GrammarContent(
        title: LocalizedText({
          'tr': '“to be” fiili: I am',
          'ar': 'الفعل “to be”: I am',
          'en': 'The verb “to be”: I am',
        }),
        explanation: LocalizedText({
          'tr': 'İngilizcede kendini tanıtırken “I am” + isim kullanılır. Kısa biçimi “I’m”dir.',
          'ar': 'عند التعريف بنفسك بالإنجليزية نستخدم “I am” + الاسم. وصيغتها المختصرة “I’m”.',
          'en': 'To introduce yourself in English, use “I am” + your name. The short form is “I’m”.',
        }),
        examples: [
          ExampleSentence(
            text: 'I am Anna.',
            translation: LocalizedText({'tr': 'Ben Anna.', 'ar': 'أنا آنا.'}),
          ),
        ],
      ),
      ExerciseContent(
        MultipleChoiceQuestion(
          id: 'en-a1-l1-ex1',
          prompt: LocalizedText({
            'tr': 'Hangisi “teşekkürler” anlamına gelir?',
            'ar': 'أيٌّ منها يعني “شكرًا”؟',
            'en': 'Which one means “thank you”?',
          }),
          options: [
            QuizOption(id: 'a', text: LocalizedText.plain('Goodbye')),
            QuizOption(id: 'b', text: LocalizedText.plain('Please')),
            QuizOption(id: 'c', text: LocalizedText.plain('Thank you')),
          ],
          correctOptionId: 'c',
        ),
      ),
    ],
  ),
  Lesson(
    id: 'en-a1-l2',
    courseId: 'en-a1-everyday',
    languageCode: 'en',
    order: 2,
    estimatedMinutes: 7,
    title: LocalizedText({
      'tr': 'Yiyecek ve içecek',
      'en': 'Food and drink',
      'ar': 'الطعام والشراب',
    }),
    contents: [
      HeadingContent(
        LocalizedText({
          'tr': 'Mutfakta',
          'ar': 'في المطبخ',
          'en': 'In the kitchen',
        }),
      ),
      TextContent(
        LocalizedText({
          'tr': 'Günlük hayatta sık kullanılan üç yiyecek-içecek kelimesi.',
          'ar': 'ثلاث كلمات شائعة عن الطعام والشراب في الحياة اليومية.',
          'en': 'Three common food and drink words for daily life.',
        }),
      ),
      VocabularyContent(['en-water', 'en-bread', 'en-apple']),
      ExampleContent(
        ExampleSentence(
          text: 'I want water, please.',
          translation: LocalizedText({
            'tr': 'Lütfen su istiyorum.',
            'ar': 'أريد ماءً من فضلك.',
          }),
        ),
      ),
      ExerciseContent(
        MultipleChoiceQuestion(
          id: 'en-a1-l2-ex1',
          prompt: LocalizedText({
            'tr': '“Ekmek” İngilizcede nedir?',
            'ar': 'ما معنى “خبز” بالإنجليزية؟',
            'en': 'Which word means bread?',
          }),
          options: [
            QuizOption(id: 'a', text: LocalizedText.plain('water')),
            QuizOption(id: 'b', text: LocalizedText.plain('bread')),
            QuizOption(id: 'c', text: LocalizedText.plain('apple')),
          ],
          correctOptionId: 'b',
        ),
      ),
    ],
  ),
  Lesson(
    id: 'en-a1-l3',
    courseId: 'en-a1-everyday',
    languageCode: 'en',
    order: 3,
    estimatedMinutes: 6,
    title: LocalizedText({'tr': 'Aile', 'en': 'Family', 'ar': 'العائلة'}),
    contents: [
      HeadingContent(
        LocalizedText({'tr': 'Ailem', 'ar': 'عائلتي', 'en': 'My family'}),
      ),
      VocabularyContent(['en-mother', 'en-father']),
      GrammarContent(
        title: LocalizedText({
          'tr': 'İyelik: my',
          'ar': 'الملكية: my',
          'en': 'Possessive: my',
        }),
        explanation: LocalizedText({
          'tr': '“my” “benim” demektir ve isimden önce gelir: my mother, my father.',
          'ar': '“my” تعني “الخاص بي” وتأتي قبل الاسم: my mother, my father.',
          'en': '“my” shows that something belongs to you and comes before the noun: my mother, my father.',
        }),
        examples: [
          ExampleSentence(
            text: 'This is my mother.',
            translation: LocalizedText({
              'tr': 'Bu benim annem.',
              'ar': 'هذه أمي.',
            }),
          ),
        ],
      ),
    ],
  ),

  // ================= Türkçe A1 =================
  Lesson(
    id: 'tr-a1-l1',
    courseId: 'tr-a1-start',
    languageCode: 'tr',
    order: 1,
    estimatedMinutes: 8,
    title: LocalizedText({
      'tr': 'Selamlaşma',
      'en': 'Greetings',
      'ar': 'التحية',
    }),
    contents: [
      HeadingContent(
        LocalizedText({
          'tr': 'Merhaba demek',
          'en': 'Saying hello',
          'ar': 'إلقاء التحية',
        }),
      ),
      DialogueContent([
        DialogueLine(
          speaker: 'Ayşe',
          text: 'Merhaba!',
          translation: LocalizedText({'en': 'Hello!', 'ar': 'مرحبًا!'}),
        ),
        DialogueLine(
          speaker: 'Can',
          text: 'Merhaba Ayşe! Nasılsın?',
          translation: LocalizedText({
            'en': 'Hello Ayşe! How are you?',
            'ar': 'مرحبًا عائشة! كيف حالك؟',
          }),
        ),
        DialogueLine(
          speaker: 'Ayşe',
          text: 'İyiyim, teşekkürler.',
          translation: LocalizedText({
            'en': 'I am fine, thank you.',
            'ar': 'بخير، شكرًا.',
          }),
        ),
      ]),
      VocabularyContent([
        'tr-merhaba',
        'tr-tesekkurler',
        'tr-evet',
        'tr-hayir',
      ]),
      ExampleContent(
        ExampleSentence(
          text: 'Evet, teşekkürler.',
          translation: LocalizedText({
            'en': 'Yes, thank you.',
            'ar': 'نعم، شكرًا.',
          }),
        ),
      ),
    ],
  ),
  Lesson(
    id: 'tr-a1-l2',
    courseId: 'tr-a1-start',
    languageCode: 'tr',
    order: 2,
    estimatedMinutes: 7,
    title: LocalizedText({
      'tr': 'Sayılar ve günlük kelimeler',
      'en': 'Numbers and everyday words',
      'ar': 'الأرقام وكلمات يومية',
    }),
    contents: [
      HeadingContent(
        LocalizedText({
          'tr': 'Birden üçe',
          'en': 'One to three',
          'ar': 'من واحد إلى ثلاثة',
        }),
      ),
      TextContent(
        LocalizedText({
          'tr': 'Birden üçe say ve iki günlük kelime öğren.',
          'en': 'Count from one to three and learn two everyday words.',
          'ar': 'عُدّ من واحد إلى ثلاثة وتعلّم كلمتين يوميتين.',
        }),
      ),
      VocabularyContent(['tr-bir', 'tr-iki', 'tr-uc', 'tr-su', 'tr-ekmek']),
      ExerciseContent(
        MultipleChoiceQuestion(
          id: 'tr-a1-l2-ex1',
          prompt: LocalizedText({
            'tr': 'Hangi kelime “iki” anlamına gelir?',
            'en': 'Which word means “two”?',
            'ar': 'أي كلمة تعني “اثنان”؟',
          }),
          options: [
            QuizOption(id: 'a', text: LocalizedText.plain('bir')),
            QuizOption(id: 'b', text: LocalizedText.plain('iki')),
            QuizOption(id: 'c', text: LocalizedText.plain('üç')),
          ],
          correctOptionId: 'b',
        ),
      ),
    ],
  ),

  // ================= İngilizce A2 =================
  Lesson(
    id: 'en-a2-l1',
    courseId: 'en-a2-travel',
    languageCode: 'en',
    order: 1,
    estimatedMinutes: 10,
    title: LocalizedText({
      'tr': 'Havalimanında',
      'en': 'At the airport',
      'ar': 'في المطار',
    }),
    contents: [
      HeadingContent(
        LocalizedText({
          'tr': 'Check-in',
          'ar': 'إجراءات السفر',
          'en': 'Check-in',
        }),
      ),
      DialogueContent([
        DialogueLine(
          speaker: 'Officer',
          text: 'Passport, please.',
          translation: LocalizedText({
            'tr': 'Pasaport, lütfen.',
            'ar': 'جواز السفر من فضلك.',
          }),
        ),
        DialogueLine(
          speaker: 'Traveler',
          text: 'Here you are.',
          translation: LocalizedText({'tr': 'Buyurun.', 'ar': 'تفضّل.'}),
        ),
        DialogueLine(
          speaker: 'Officer',
          text: 'And your ticket?',
          translation: LocalizedText({'tr': 'Biletiniz de?', 'ar': 'وتذكرتك؟'}),
        ),
      ]),
      VocabularyContent(['en-airport', 'en-ticket', 'en-passport']),
      GrammarContent(
        title: LocalizedText({
          'tr': '“please” ile kibar rica',
          'ar': 'الطلب المهذب مع “please”',
          'en': 'Polite requests with “please”',
        }),
        explanation: LocalizedText({
          'tr': 'Rica etmek için “please” cümlenin başına veya sonuna eklenir.',
          'ar': 'لتقديم طلب مهذب نضيف “please” في بداية الجملة أو نهايتها.',
          'en': 'To make a polite request, add “please” at the start or the end of the sentence.',
        }),
        examples: [
          ExampleSentence(
            text: 'Your ticket, please.',
            translation: LocalizedText({
              'tr': 'Biletiniz, lütfen.',
              'ar': 'تذكرتك من فضلك.',
            }),
          ),
        ],
      ),
      ExampleContent(
        ExampleSentence(
          text: 'Where is the airport?',
          translation: LocalizedText({
            'tr': 'Havalimanı nerede?',
            'ar': 'أين المطار؟',
          }),
        ),
      ),
    ],
  ),
];
