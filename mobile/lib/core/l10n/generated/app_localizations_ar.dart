// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'LanguagePlatform';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorNotFound => 'لم نتمكن من العثور على ما تبحث عنه.';

  @override
  String get loadingLabel => 'جارٍ التحميل';

  @override
  String get demoNotice => 'بيانات تجريبية. لا يتم حفظ أي شيء على خادم.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get interfaceLanguageTitle => 'لغة التطبيق';

  @override
  String get themeTitle => 'المظهر';

  @override
  String get themeModeSystem => 'النظام';

  @override
  String get themeModeLight => 'فاتح';

  @override
  String get themeModeDark => 'داكن';

  @override
  String get skip => 'تخطّي';

  @override
  String get next => 'التالي';

  @override
  String get back => 'السابق';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get continueAction => 'متابعة';

  @override
  String get onboarding1Title => 'تعلّم لغة جديدة';

  @override
  String get onboarding1Body =>
      'اختر اللغة التي تريد تعلّمها وابدأ من اللغة التي تعرفها.';

  @override
  String get onboarding2Title => 'تقدّم عبر دروس تفاعلية';

  @override
  String get onboarding2Body =>
      'دروس قصيرة تضم حوارات ومفردات وقواعد تساعدك على التقدّم خطوة بخطوة.';

  @override
  String get onboarding3Title => 'تدرّب على الكلمات والمحادثة';

  @override
  String get onboarding3Body =>
      'راجع المفردات اليوم. تدريب المحادثة قادم قريبًا.';

  @override
  String get onboarding4Title => 'تابع تقدّمك';

  @override
  String get onboarding4Body =>
      'شاهد الدروس المكتملة ونتائج الاختبارات وهدفك اليومي في مكان واحد.';

  @override
  String onboardingStepSemantics(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get languageSetupTitle => 'اختر لغاتك';

  @override
  String get languageSetupSubtitle =>
      'لغة التطبيق واللغة التي تعرفها واللغة التي تريد تعلّمها ثلاثة خيارات منفصلة.';

  @override
  String get knownLanguageTitle => 'أتحدث';

  @override
  String get targetLanguageTitle => 'أريد أن أتعلّم';

  @override
  String get sameLanguageHint =>
      'اختر لغتين مختلفتين لـ \"أتحدث\" و\"أريد أن أتعلّم\".';

  @override
  String get chooseBothLanguagesHint =>
      'اختر اللغة التي تعرفها واللغة التي تريد تعلّمها.';

  @override
  String get done => 'تم';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get startLesson => 'ابدأ الدرس';

  @override
  String get continueCourse => 'متابعة';

  @override
  String get startCourse => 'ابدأ الدورة';

  @override
  String get reviewCourse => 'مراجعة الدورة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCourses => 'الدورات';

  @override
  String get navVocabulary => 'الكلمات';

  @override
  String get navProgress => 'التقدّم';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get homeGreeting => 'أهلًا بعودتك';

  @override
  String homeLearningLabel(String language) {
    return 'تتعلّم: $language';
  }

  @override
  String get homeChooseTargetHint =>
      'اختر اللغة التي تريد تعلّمها من الإعدادات.';

  @override
  String get homeDailyGoalTitle => 'الهدف اليومي';

  @override
  String get homeGoalReached => 'حققت هدف اليوم!';

  @override
  String homeDailyGoalProgress(int done, int goal) {
    return '$done من $goal دروس اليوم';
  }

  @override
  String get homeContinueTitle => 'تابع التعلّم';

  @override
  String get homeStartTitle => 'ابدأ درسك الأول';

  @override
  String get homeNextLessonTitle => 'الدرس التالي';

  @override
  String get homeAllDone => 'أنهيت كل الدروس المتاحة. عمل رائع!';

  @override
  String get homeFeaturedCourses => 'دورات مميزة';

  @override
  String get homeRecommendedPractice => 'تدريب مقترح';

  @override
  String get practiceVocabularyTitle => 'راجع المفردات';

  @override
  String get practiceVocabularySubtitle => 'تصفّح كلماتك وحدّث مدى إتقانك لها';

  @override
  String get practiceQuizTitle => 'اختبر نفسك';

  @override
  String get homeProgressTitle => 'تقدّمك';

  @override
  String get coursesTitle => 'الدورات';

  @override
  String get searchCoursesHint => 'ابحث عن دورة';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get filterLanguageTitle => 'اللغة';

  @override
  String get filterLevelTitle => 'المستوى';

  @override
  String get filterAll => 'الكل';

  @override
  String get noCoursesTitle => 'لم يتم العثور على دورات';

  @override
  String get noCoursesMessage => 'جرّب تغيير البحث أو عوامل التصفية.';

  @override
  String get clearFilters => 'مسح عوامل التصفية';

  @override
  String lessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count درس',
      many: '$count درسًا',
      few: '$count دروس',
      two: 'درسان',
      one: 'درس واحد',
      zero: 'لا دروس',
    );
    return '$_temp0';
  }

  @override
  String lessonMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String courseProgressLabel(int done, int total) {
    return '$done/$total دروس';
  }

  @override
  String get courseLessonsTitle => 'الدروس';

  @override
  String get noLessonsTitle => 'الدروس قادمة قريبًا';

  @override
  String get noLessonsMessage => 'يجري إعداد محتوى هذه الدورة.';

  @override
  String quizBestScore(String score) {
    return 'الأفضل: $score';
  }

  @override
  String get lessonDialogue => 'حوار';

  @override
  String get lessonVocabulary => 'المفردات';

  @override
  String get lessonGrammar => 'القواعد';

  @override
  String get lessonExample => 'مثال';

  @override
  String get lessonExercise => 'تدريب';

  @override
  String get checkAnswer => 'تحقق من الإجابة';

  @override
  String get answerCorrect => 'صحيح!';

  @override
  String get answerIncorrect => 'ليس تمامًا.';

  @override
  String get markLessonComplete => 'وضع علامة مكتمل';

  @override
  String get lessonCompleted => 'مكتمل';

  @override
  String get takeQuiz => 'ابدأ الاختبار';

  @override
  String get previousLesson => 'الدرس السابق';

  @override
  String get nextLesson => 'الدرس التالي';

  @override
  String get quizTitle => 'اختبار';

  @override
  String quizQuestionOf(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get quizNext => 'السؤال التالي';

  @override
  String get quizFinish => 'عرض النتيجة';

  @override
  String get quizResultTitle => 'نتيجتك';

  @override
  String quizScoreSummary(int correct, int total) {
    return '$correct من $total إجابات صحيحة';
  }

  @override
  String get quizPassed => 'عمل رائع!';

  @override
  String get quizFailed => 'واصل التدرّب.';

  @override
  String get quizTryAgain => 'حاول مرة أخرى';

  @override
  String get quizLocalOnly =>
      'في هذه النسخة التجريبية تُحفظ النتائج على هذا الجهاز فقط.';

  @override
  String get quizEmptyTitle => 'لا توجد أسئلة بعد';

  @override
  String get vocabularyTitle => 'الكلمات';

  @override
  String get vocabularyEmptyTitle => 'لم يتم العثور على كلمات';

  @override
  String get vocabularyEmptyMessage => 'غيّر عامل التصفية أو اختر لغة للتعلّم.';

  @override
  String get vocabularyStatusNew => 'جديدة';

  @override
  String get vocabularyStatusLearning => 'قيد التعلّم';

  @override
  String get vocabularyStatusLearned => 'تم تعلّمها';

  @override
  String get wordMeaning => 'المعنى';

  @override
  String get wordStatusTitle => 'حالة التعلّم';

  @override
  String get progressTitle => 'التقدّم';

  @override
  String get progressDemoNotice =>
      'يُحفظ التقدّم على هذا الجهاز فقط ويُمسح عند إغلاق التطبيق. ولا يُحفظ في حساب.';

  @override
  String get progressCompletedLessons => 'دروس مكتملة';

  @override
  String get progressAverageScore => 'متوسط نتائج الاختبارات';

  @override
  String get progressNoQuizYet => 'لا اختبارات بعد';

  @override
  String get progressDailyGoalTitle => 'الهدف اليومي';

  @override
  String dailyGoalOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count درس يوميًا',
      many: '$count درسًا يوميًا',
      few: '$count دروس يوميًا',
      two: 'درسان يوميًا',
      one: 'درس واحد يوميًا',
    );
    return '$_temp0';
  }

  @override
  String get progressCoursesTitle => 'تقدّم الدورات';

  @override
  String get progressEmptyTitle => 'لا يوجد تقدّم بعد';

  @override
  String get progressEmptyMessage => 'أكمل درسًا لترى تقدّمك هنا.';

  @override
  String get browseCourses => 'تصفّح الدورات';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileDemoName => 'متعلّم تجريبي';

  @override
  String get profileGuestName => 'ضيف';

  @override
  String get profileDemoSubtitle => 'الوضع التجريبي، لم تسجّل الدخول';

  @override
  String get profileSignedOutSubtitle => 'لم تسجّل الدخول';

  @override
  String get profileLanguagesTitle => 'اللغات';

  @override
  String get accountIntegrationPending =>
      'ميزات الحساب تتطلب اتصالًا بالخادم وغير متاحة بعد.';

  @override
  String get exitDemoMode => 'الخروج من الوضع التجريبي';

  @override
  String get accountSectionTitle => 'الحساب';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String get aboutDescription =>
      'يساعدك LanguagePlatform على تعلّم اللغات بلغتك. هذه نسخة تجريبية.';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get loginSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get forgotPasswordLink => 'هل نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get noAccountPrompt => 'ليس لديك حساب؟';

  @override
  String get registerButton => 'إنشاء حساب';

  @override
  String get demoModeExplain =>
      'يتيح لك الوضع التجريبي استكشاف التطبيق بمحتوى تجريبي. لا يتم إنشاء حساب ولا يُحفظ أي شيء.';

  @override
  String get continueDemo => 'المتابعة في الوضع التجريبي';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'ستتوفر إمكانية إنشاء الحساب عند ربط الخدمة.';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get haveAccountPrompt => 'لديك حساب بالفعل؟';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك التعليمات.';

  @override
  String get sendResetButton => 'إرسال رابط إعادة التعيين';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get invalidEmail => 'أدخل بريدًا إلكترونيًا صحيحًا';

  @override
  String passwordTooShort(int min) {
    return 'يجب ألا تقل كلمة المرور عن $min أحرف';
  }

  @override
  String get passwordsDontMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get authUnavailable =>
      'تسجيل الدخول غير متصل بخادم بعد. لا تستطيع هذه النسخة إنشاء الحسابات أو التحقق منها.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get homeResumeTitle => 'تابع درسك';

  @override
  String get weeklyActivityTitle => 'آخر 7 أيام';

  @override
  String activityStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'سلسلة $days يوم',
      many: 'سلسلة $days يومًا',
      few: 'سلسلة $days أيام',
      two: 'سلسلة يومين',
      one: 'سلسلة يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get activityNone =>
      'لا يوجد نشاط مسجّل بعد. أكمل درسًا أو اختبارًا أو مراجعة ليظهر هنا.';

  @override
  String get statWordsLearned => 'كلمات تم تعلّمها';

  @override
  String get statWordsLearning => 'كلمات قيد التعلّم';

  @override
  String get statReviewsDue => 'مراجعات مستحقة';

  @override
  String get vocabularySearchHint => 'ابحث عن كلمة';

  @override
  String get vocabularyFavorites => 'المفضلة';

  @override
  String get favoriteAdd => 'إضافة إلى المفضلة';

  @override
  String get favoriteRemove => 'إزالة من المفضلة';

  @override
  String get reviewDueBadge => 'حان وقت المراجعة';

  @override
  String reviewDueBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count كلمة مستحقة للمراجعة',
      many: '$count كلمة مستحقة للمراجعة',
      few: '$count كلمات مستحقة للمراجعة',
      two: 'كلمتان مستحقتان للمراجعة',
      one: 'كلمة واحدة مستحقة للمراجعة',
      zero: 'لا كلمات مستحقة. تدرّب على كلمات جديدة',
    );
    return '$_temp0';
  }

  @override
  String get startReview => 'مراجعة';

  @override
  String get reviewTitle => 'بطاقات الكلمات';

  @override
  String get reviewShowAnswer => 'إظهار الإجابة';

  @override
  String reviewProgress(int current, int total) {
    return 'البطاقة $current من $total';
  }

  @override
  String get ratingAgain => 'مرة أخرى';

  @override
  String get ratingHard => 'صعب';

  @override
  String get ratingGood => 'جيد';

  @override
  String get ratingEasy => 'سهل';

  @override
  String get reviewDoneTitle => 'اكتملت الجلسة';

  @override
  String reviewDoneSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'راجعت $count كلمة.',
      many: 'راجعت $count كلمة.',
      few: 'راجعت $count كلمات.',
      two: 'راجعت كلمتين.',
      one: 'راجعت كلمة واحدة.',
    );
    return '$_temp0';
  }

  @override
  String get reviewNothingTitle => 'لا شيء للمراجعة';

  @override
  String get reviewNothingMessage =>
      'اختر لغة للتعلّم أو عد عندما تحين مراجعة الكلمات.';

  @override
  String get settingsDemoNotice =>
      'نسخة تجريبية: تُحفظ إعداداتك وتقدّمك على هذا الجهاز فقط وليس في حساب.';

  @override
  String get resetDataTitle => 'إعادة تعيين البيانات التجريبية المحلية';

  @override
  String get resetDataSubtitle =>
      'يحذف التقدّم وحالة الكلمات والتفضيلات على هذا الجهاز';

  @override
  String get resetDataConfirmTitle => 'إعادة تعيين البيانات المحلية؟';

  @override
  String get resetDataConfirmMessage =>
      'سيتم حذف حالة التعريف واختيارات اللغة والتقدّم وسجلات الكلمات على هذا الجهاز. لا يمكن التراجع.';

  @override
  String get resetDataConfirmAction => 'إعادة تعيين';

  @override
  String get errorNetwork =>
      'لا يوجد اتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get errorTimeout =>
      'استغرق الطلب وقتًا طويلًا. يرجى المحاولة مرة أخرى.';

  @override
  String get errorUnauthorized => 'يرجى تسجيل الدخول للمتابعة.';

  @override
  String get errorForbidden => 'ليس لديك صلاحية الوصول إلى هذا المحتوى.';

  @override
  String get errorServer => 'حدثت مشكلة في الخادم. يرجى المحاولة لاحقًا.';

  @override
  String get errorUnavailable => 'هذه الميزة غير متصلة بعد.';

  @override
  String get storageWriteFailed =>
      'تعذّر حفظ بعض التغييرات على هذا الجهاز وقد تضيع عند إغلاق التطبيق.';

  @override
  String get answerTrue => 'صحيح';

  @override
  String get answerFalse => 'خطأ';

  @override
  String get unsupportedContent =>
      'هذا المحتوى غير مدعوم في هذا الإصدار من التطبيق.';

  @override
  String get pageNotFoundTitle => 'الصفحة غير موجودة';

  @override
  String get pageNotFoundMessage => 'الصفحة التي فتحتها غير موجودة.';

  @override
  String get goHome => 'الذهاب إلى الرئيسية';
}
