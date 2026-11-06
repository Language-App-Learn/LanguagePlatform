import '../../../core/errors/app_exceptions.dart';
import '../../../core/l10n/localized_text.dart';
import '../domain/course.dart';
import '../domain/course_repository.dart';

/// DEMO içerik: yalnızca geliştirme/gösterim içindir, gerçek müfredat değildir.
const demoCourses = <Course>[
  Course(
    id: 'ar-a1-basics',
    languageCode: 'ar',
    level: CourseLevel.a1,
    title: LocalizedText({
      'tr': 'Arapça A1: İlk Adımlar',
      'en': 'Arabic A1: First Steps',
      'ar': 'العربية A1: الخطوات الأولى',
    }),
    description: LocalizedText({
      'tr': 'Selamlaşma, kendini tanıtma ve ilk sayılarla Arapçaya başla.',
      'en':
          'Start Arabic with greetings, introductions and your first numbers.',
      'ar': 'ابدأ العربية بالتحيات والتعريف بالنفس وأولى الأرقام.',
    }),
    lessonIds: ['ar-a1-l1', 'ar-a1-l2', 'ar-a1-l3'],
  ),
  Course(
    id: 'en-a1-everyday',
    languageCode: 'en',
    level: CourseLevel.a1,
    title: LocalizedText({
      'tr': 'İngilizce A1: Günlük İngilizce',
      'en': 'English A1: Everyday English',
      'ar': 'الإنجليزية A1: الإنجليزية اليومية',
    }),
    description: LocalizedText({
      'tr':
          'Günlük hayatta en çok ihtiyaç duyulan temel ifadeler ve kelimeler.',
      'en': 'The basic phrases and words you need most in daily life.',
      'ar': 'العبارات والكلمات الأساسية التي تحتاجها أكثر في الحياة اليومية.',
    }),
    lessonIds: ['en-a1-l1', 'en-a1-l2', 'en-a1-l3'],
  ),
  Course(
    id: 'tr-a1-start',
    languageCode: 'tr',
    level: CourseLevel.a1,
    title: LocalizedText({
      'tr': 'Türkçe A1: Başlangıç',
      'en': 'Turkish A1: Getting Started',
      'ar': 'التركية A1: البداية',
    }),
    description: LocalizedText({
      'tr': 'Türkçede selamlaşma, evet/hayır ve ilk sayılar.',
      'en': 'Greetings, yes/no and the first numbers in Turkish.',
      'ar': 'التحيات ونعم/لا وأولى الأرقام في اللغة التركية.',
    }),
    lessonIds: ['tr-a1-l1', 'tr-a1-l2'],
  ),
  Course(
    id: 'en-a2-travel',
    languageCode: 'en',
    level: CourseLevel.a2,
    title: LocalizedText({
      'tr': 'İngilizce A2: Seyahat',
      'en': 'English A2: Travel',
      'ar': 'الإنجليزية A2: السفر',
    }),
    description: LocalizedText({
      'tr': 'Havalimanı ve yolculukta kullanılan kibar ifadeler.',
      'en': 'Polite phrases for airports and journeys.',
      'ar': 'عبارات مهذبة للمطارات والرحلات.',
    }),
    lessonIds: ['en-a2-l1'],
  ),
  Course(
    id: 'en-b1-work',
    languageCode: 'en',
    level: CourseLevel.b1,
    title: LocalizedText({
      'tr': 'İngilizce B1: İş Hayatı',
      'en': 'English B1: Work',
      'ar': 'الإنجليزية B1: العمل',
    }),
    description: LocalizedText({
      'tr': 'Bu kursun içeriği hazırlanıyor.',
      'en': 'The content for this course is being prepared.',
      'ar': 'يجري إعداد محتوى هذه الدورة.',
    }),
    lessonIds: [],
  ),
];

/// Yerel DEMO verisi. Gerçek API uygulaması aynı arayüzü uygulayıp
/// provider'da bunun yerine geçecek.
class DemoCourseRepository implements CourseRepository {
  const DemoCourseRepository();

  @override
  Future<List<Course>> getCourses() async => demoCourses;

  @override
  Future<Course> getCourse(String courseId) async {
    for (final course in demoCourses) {
      if (course.id == courseId) return course;
    }
    throw NotFoundException('course:$courseId');
  }
}
