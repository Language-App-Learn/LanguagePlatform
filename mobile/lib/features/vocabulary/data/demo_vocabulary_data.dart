import '../../../core/l10n/localized_text.dart';
import '../../lessons/domain/example_sentence.dart';
import '../domain/vocabulary_item.dart';

/// DEMO içerik: yalnızca geliştirme/gösterim içindir, gerçek müfredat değildir.
const demoVocabulary = <VocabularyItem>[
  // ---- Arapça ----
  VocabularyItem(
    id: 'ar-marhaba',
    languageCode: 'ar',
    term: 'مرحبًا',
    transliteration: 'marḥaban',
    meaning: LocalizedText({'tr': 'Merhaba', 'en': 'Hello'}),
    example: ExampleSentence(
      text: 'مرحبًا يا أحمد!',
      translation: LocalizedText({
        'tr': 'Merhaba Ahmet!',
        'en': 'Hello, Ahmad!',
      }),
    ),
  ),
  VocabularyItem(
    id: 'ar-ahlan',
    languageCode: 'ar',
    term: 'أهلًا',
    transliteration: 'ahlan',
    meaning: LocalizedText({'tr': 'Hoş geldin', 'en': 'Welcome'}),
    example: ExampleSentence(
      text: 'أهلًا بك.',
      translation: LocalizedText({'tr': 'Hoş geldin.', 'en': 'Welcome.'}),
    ),
  ),
  VocabularyItem(
    id: 'ar-shukran',
    languageCode: 'ar',
    term: 'شكرًا',
    transliteration: 'shukran',
    meaning: LocalizedText({'tr': 'Teşekkürler', 'en': 'Thank you'}),
    example: ExampleSentence(
      text: 'شكرًا جزيلًا.',
      translation: LocalizedText({
        'tr': 'Çok teşekkürler.',
        'en': 'Thank you very much.',
      }),
    ),
  ),
  VocabularyItem(
    id: 'ar-ma-salama',
    languageCode: 'ar',
    term: 'مع السلامة',
    transliteration: 'maʿa s-salāma',
    meaning: LocalizedText({'tr': 'Hoşça kal', 'en': 'Goodbye'}),
  ),
  VocabularyItem(
    id: 'ar-ismi',
    languageCode: 'ar',
    term: 'اسمي',
    transliteration: 'ismī',
    meaning: LocalizedText({'tr': 'Benim adım', 'en': 'My name is'}),
    example: ExampleSentence(
      text: 'اسمي سارة.',
      translation: LocalizedText({
        'tr': 'Benim adım Sara.',
        'en': 'My name is Sara.',
      }),
    ),
  ),
  VocabularyItem(
    id: 'ar-naam',
    languageCode: 'ar',
    term: 'نعم',
    transliteration: 'naʿam',
    meaning: LocalizedText({'tr': 'Evet', 'en': 'Yes'}),
  ),
  VocabularyItem(
    id: 'ar-la',
    languageCode: 'ar',
    term: 'لا',
    transliteration: 'lā',
    meaning: LocalizedText({'tr': 'Hayır', 'en': 'No'}),
  ),
  VocabularyItem(
    id: 'ar-wahid',
    languageCode: 'ar',
    term: 'واحد',
    transliteration: 'wāḥid',
    meaning: LocalizedText({'tr': 'Bir', 'en': 'One'}),
  ),
  VocabularyItem(
    id: 'ar-ithnan',
    languageCode: 'ar',
    term: 'اثنان',
    transliteration: 'ithnān',
    meaning: LocalizedText({'tr': 'İki', 'en': 'Two'}),
  ),
  VocabularyItem(
    id: 'ar-thalatha',
    languageCode: 'ar',
    term: 'ثلاثة',
    transliteration: 'thalātha',
    meaning: LocalizedText({'tr': 'Üç', 'en': 'Three'}),
  ),
  VocabularyItem(
    id: 'ar-kitab',
    languageCode: 'ar',
    term: 'كتاب',
    transliteration: 'kitāb',
    meaning: LocalizedText({'tr': 'Kitap', 'en': 'Book'}),
    example: ExampleSentence(
      text: 'هذا كتاب.',
      translation: LocalizedText({
        'tr': 'Bu bir kitap.',
        'en': 'This is a book.',
      }),
    ),
  ),
  VocabularyItem(
    id: 'ar-madrasa',
    languageCode: 'ar',
    term: 'مدرسة',
    transliteration: 'madrasa',
    meaning: LocalizedText({'tr': 'Okul', 'en': 'School'}),
  ),

  // ---- İngilizce ----
  VocabularyItem(
    id: 'en-hello',
    languageCode: 'en',
    term: 'hello',
    meaning: LocalizedText({'tr': 'merhaba', 'ar': 'مرحبًا'}),
    example: ExampleSentence(
      text: 'Hello, how are you?',
      translation: LocalizedText({
        'tr': 'Merhaba, nasılsın?',
        'ar': 'مرحبًا، كيف حالك؟',
      }),
    ),
  ),
  VocabularyItem(
    id: 'en-goodbye',
    languageCode: 'en',
    term: 'goodbye',
    meaning: LocalizedText({'tr': 'hoşça kal', 'ar': 'مع السلامة'}),
  ),
  VocabularyItem(
    id: 'en-thanks',
    languageCode: 'en',
    term: 'thank you',
    meaning: LocalizedText({'tr': 'teşekkürler', 'ar': 'شكرًا'}),
    example: ExampleSentence(
      text: 'Thank you very much.',
      translation: LocalizedText({
        'tr': 'Çok teşekkür ederim.',
        'ar': 'شكرًا جزيلًا.',
      }),
    ),
  ),
  VocabularyItem(
    id: 'en-please',
    languageCode: 'en',
    term: 'please',
    meaning: LocalizedText({'tr': 'lütfen', 'ar': 'من فضلك'}),
  ),
  VocabularyItem(
    id: 'en-water',
    languageCode: 'en',
    term: 'water',
    meaning: LocalizedText({'tr': 'su', 'ar': 'ماء'}),
    example: ExampleSentence(
      text: 'I drink water.',
      translation: LocalizedText({
        'tr': 'Ben su içerim.',
        'ar': 'أنا أشرب الماء.',
      }),
    ),
  ),
  VocabularyItem(
    id: 'en-bread',
    languageCode: 'en',
    term: 'bread',
    meaning: LocalizedText({'tr': 'ekmek', 'ar': 'خبز'}),
  ),
  VocabularyItem(
    id: 'en-apple',
    languageCode: 'en',
    term: 'apple',
    meaning: LocalizedText({'tr': 'elma', 'ar': 'تفاحة'}),
  ),
  VocabularyItem(
    id: 'en-mother',
    languageCode: 'en',
    term: 'mother',
    meaning: LocalizedText({'tr': 'anne', 'ar': 'أم'}),
  ),
  VocabularyItem(
    id: 'en-father',
    languageCode: 'en',
    term: 'father',
    meaning: LocalizedText({'tr': 'baba', 'ar': 'أب'}),
  ),
  VocabularyItem(
    id: 'en-airport',
    languageCode: 'en',
    term: 'airport',
    meaning: LocalizedText({'tr': 'havalimanı', 'ar': 'مطار'}),
  ),
  VocabularyItem(
    id: 'en-ticket',
    languageCode: 'en',
    term: 'ticket',
    meaning: LocalizedText({'tr': 'bilet', 'ar': 'تذكرة'}),
  ),
  VocabularyItem(
    id: 'en-passport',
    languageCode: 'en',
    term: 'passport',
    meaning: LocalizedText({'tr': 'pasaport', 'ar': 'جواز سفر'}),
  ),

  // ---- Türkçe ----
  VocabularyItem(
    id: 'tr-merhaba',
    languageCode: 'tr',
    term: 'merhaba',
    meaning: LocalizedText({'en': 'hello', 'ar': 'مرحبًا'}),
    example: ExampleSentence(
      text: 'Merhaba, ben Ayşe.',
      translation: LocalizedText({
        'en': 'Hello, I am Ayşe.',
        'ar': 'مرحبًا، أنا عائشة.',
      }),
    ),
  ),
  VocabularyItem(
    id: 'tr-tesekkurler',
    languageCode: 'tr',
    term: 'teşekkürler',
    meaning: LocalizedText({'en': 'thank you', 'ar': 'شكرًا'}),
  ),
  VocabularyItem(
    id: 'tr-evet',
    languageCode: 'tr',
    term: 'evet',
    meaning: LocalizedText({'en': 'yes', 'ar': 'نعم'}),
  ),
  VocabularyItem(
    id: 'tr-hayir',
    languageCode: 'tr',
    term: 'hayır',
    meaning: LocalizedText({'en': 'no', 'ar': 'لا'}),
  ),
  VocabularyItem(
    id: 'tr-bir',
    languageCode: 'tr',
    term: 'bir',
    meaning: LocalizedText({'en': 'one', 'ar': 'واحد'}),
  ),
  VocabularyItem(
    id: 'tr-iki',
    languageCode: 'tr',
    term: 'iki',
    meaning: LocalizedText({'en': 'two', 'ar': 'اثنان'}),
  ),
  VocabularyItem(
    id: 'tr-uc',
    languageCode: 'tr',
    term: 'üç',
    meaning: LocalizedText({'en': 'three', 'ar': 'ثلاثة'}),
  ),
  VocabularyItem(
    id: 'tr-su',
    languageCode: 'tr',
    term: 'su',
    meaning: LocalizedText({'en': 'water', 'ar': 'ماء'}),
    example: ExampleSentence(
      text: 'Su içiyorum.',
      translation: LocalizedText({
        'en': 'I am drinking water.',
        'ar': 'أنا أشرب الماء.',
      }),
    ),
  ),
  VocabularyItem(
    id: 'tr-ekmek',
    languageCode: 'tr',
    term: 'ekmek',
    meaning: LocalizedText({'en': 'bread', 'ar': 'خبز'}),
  ),
];
