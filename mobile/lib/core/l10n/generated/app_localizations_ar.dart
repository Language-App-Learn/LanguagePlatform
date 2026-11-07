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

  @override
  String get activeCourseTitle => 'دورتك';

  @override
  String get activeCourseEmptyTitle => 'لا توجد دورة بعد';

  @override
  String get activeCourseEmptyMessage => 'اختر دورة لترى مستواك وتقدّمك هنا.';

  @override
  String get openCourse => 'فتح الدورة';

  @override
  String get reviewHistoryTitle => 'سجل المراجعة';

  @override
  String get reviewHistoryEmptyTitle => 'لا توجد مراجعات بعد';

  @override
  String get reviewHistoryEmptyMessage => 'ستظهر هنا مراجعات بطاقات الكلمات.';

  @override
  String historyNextReview(String date) {
    return 'المراجعة التالية: $date';
  }

  @override
  String get historyUnknownWord => 'الكلمة لم تعد متاحة';

  @override
  String get reviewHistoryOpen => 'سجل المراجعة';

  @override
  String get brandTagline => 'تعلّم اللغات بلغتك.';

  @override
  String lessonPosition(int current, int total) {
    return 'الدرس $current من $total';
  }

  @override
  String get lessonCompletedSnack => 'تم وضع علامة اكتمال على الدرس';

  @override
  String get leaveQuizTitle => 'مغادرة الاختبار؟';

  @override
  String get leaveQuizMessage => 'لن يتم حفظ إجاباتك في هذه المحاولة.';

  @override
  String get leaveQuizConfirm => 'مغادرة';

  @override
  String optionLetterSemantics(String letter) {
    return 'الخيار $letter';
  }

  @override
  String get trackTitle => 'تعلّم العربية من التركية';

  @override
  String get trackSubtitle => 'اختر مستواك وفق CEFR';

  @override
  String get demoContentBadge => 'محتوى تجريبي';

  @override
  String get levelNameA1 => 'مبتدئ';

  @override
  String get levelNameA2 => 'أساسي';

  @override
  String get levelNameB1 => 'متوسط';

  @override
  String get levelNameB2 => 'فوق المتوسط';

  @override
  String get levelNameC1 => 'متقدم';

  @override
  String get levelNameC2 => 'متمكّن';

  @override
  String levelPublishedCount(int published, int total) {
    return '$published من $total دروس منشورة';
  }

  @override
  String levelCompletedCount(int count) {
    return '$count مكتملة';
  }

  @override
  String get levelNoLessons => 'لا توجد دروس منشورة بعد';

  @override
  String lessonNumber(int number) {
    return 'الدرس $number';
  }

  @override
  String get lessonInPreparation => 'قيد الإعداد';

  @override
  String get stageReading => 'القراءة';

  @override
  String get stageSpeaking => 'المحادثة';

  @override
  String get stageListening => 'الاستماع';

  @override
  String get stageWriting => 'الكتابة';

  @override
  String get stageTranslation => 'الترجمة';

  @override
  String get stageReadingDesc =>
      'اقرأ النص العربي واستمع إلى كل سطر وأجب عن الأسئلة.';

  @override
  String get stageSpeakingDesc => 'ادرس الحوار وتدرّب على التحدث.';

  @override
  String get stageListeningDesc => 'استمع وضع الكلمات في الفراغات.';

  @override
  String get stageWritingDesc => 'أكمل الكلمات الناقصة وكوّن الجمل.';

  @override
  String get stageTranslationDesc => 'ترجم من التركية إلى العربية.';

  @override
  String get stageStatusAvailable => 'متاح';

  @override
  String get stageStatusInProgress => 'قيد التقدم';

  @override
  String get stageStatusCompleted => 'مكتمل';

  @override
  String get stageStatusLocked => 'غير متاح بعد';

  @override
  String get stageStatusUnavailable => 'المحتوى غير منشور بعد';

  @override
  String get stageRetry => 'تدرّب مرة أخرى';

  @override
  String get lessonStatusNotStarted => 'لم يبدأ';

  @override
  String get lessonStatusInProgress => 'قيد التقدم';

  @override
  String get lessonStatusAwaiting => 'بانتظار التقييم الرسمي';

  @override
  String get lessonStatusPassed => 'ناجح';

  @override
  String get lessonStatusFailed => 'لم تنجح، حاول مرة أخرى';

  @override
  String get overallScoreNone => 'لا توجد درجة رسمية بعد';

  @override
  String passMarkInfo(int mark) {
    return 'درجة النجاح العامة: $mark من 100';
  }

  @override
  String get scoringPolicyMissing =>
      'أوزان المراحل يحددها الخادم وليست متاحة بعد، لذلك لا تُعرض درجة نهائية.';

  @override
  String get demoScoreNotice =>
      'نتيجة تدريب تجريبي. ليست درجة رسمية ولا تُحتسب للنجاح.';

  @override
  String stageScoreLabel(String score) {
    return 'درجة التدريب: $score';
  }

  @override
  String get audioUnavailable => 'الصوت غير متاح بعد';

  @override
  String get pdfUnavailable => 'ملف PDF الأصلي غير متاح بعد';

  @override
  String get videoUnavailable => 'فيديو المعلم غير متاح بعد';

  @override
  String get aiPracticeTitle => 'تدريب المحادثة';

  @override
  String get aiPracticeUnavailable =>
      'تدريب المحادثة بالذكاء الاصطناعي غير متصل بعد. لا يتم تسجيل أو إرسال أي صوت.';

  @override
  String get dialogueTitle => 'الحوار';

  @override
  String get readingQuestionsTitle => 'الأسئلة';

  @override
  String get listeningInstruction =>
      'الصوت غير متاح بعد. ضع كل كلمة في الفراغ الصحيح.';

  @override
  String get writingFillTitle => 'أكمل الفراغ';

  @override
  String get writingArrangeTitle => 'رتّب الكلمات';

  @override
  String get translationChoiceTitle => 'اختر الترجمة الصحيحة';

  @override
  String get translationWriteTitle => 'اكتب الترجمة';

  @override
  String get wordBank => 'بنك الكلمات';

  @override
  String get tapToPlace => 'المس كلمة ثم المس فراغًا (أو اسحب الكلمة).';

  @override
  String blankLabel(int number) {
    return 'الفراغ $number';
  }

  @override
  String get checkStage => 'تحقق من الإجابات';

  @override
  String get resetStage => 'إعادة تعيين';

  @override
  String get undoStep => 'تراجع';

  @override
  String get yourAnswer => 'إجابتك';

  @override
  String get finishPractice => 'إنهاء التدريب';

  @override
  String get stageContentMissing =>
      'لا يوجد محتوى منشور لهذه المرحلة من الدرس بعد.';

  @override
  String resultCorrect(int correct, int total) {
    return '$correct من $total صحيحة';
  }

  @override
  String get practiceRecorded => 'تم حفظ التدريب على هذا الجهاز (تجريبي).';

  @override
  String get authInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة، أو لم يتم تأكيد الحساب بعد.';

  @override
  String get registerAccepted =>
      'تم إرسال طلب التسجيل. تحقق من بريدك الإلكتروني لتأكيد حسابك.';

  @override
  String get resetRequested =>
      'إذا كان هذا العنوان يخص حسابًا فسيتم إرسال تعليمات إعادة التعيين.';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get profileAccountSubtitle => 'تم تسجيل الدخول إلى حسابك';

  @override
  String get remoteSignInPrompt => 'سجّل الدخول لعرض تقدّمك وحفظه.';

  @override
  String get remoteNotConfigured => 'خادم التعلّم غير مُعدّ في هذه النسخة.';

  @override
  String get remoteBeginLesson => 'ابدأ هذا الدرس';

  @override
  String get remoteNoCourse =>
      'لا توجد دورة منشورة من التركية إلى العربية بعد.';

  @override
  String stageAttempts(int count) {
    return 'المحاولات: $count';
  }

  @override
  String stageWeight(String weight) {
    return 'الوزن: $weight%';
  }

  @override
  String get remoteStageNoAssessment =>
      'لا يوجد نشاط مُقيَّم منشور لهذه المرحلة بعد.';

  @override
  String get remoteStageTextTitle => 'نص المرحلة';

  @override
  String get startAssessment => 'ابدأ النشاط المُقيَّم';

  @override
  String get submitAnswers => 'إرسال الإجابات';

  @override
  String get officialResultTitle => 'النتيجة الرسمية';

  @override
  String officialResultScore(String score, String max) {
    return '$score من $max';
  }

  @override
  String get attemptPassed => 'ناجح';

  @override
  String get attemptNotPassed => 'لم تنجح';

  @override
  String get nextLessonAction => 'انتقل إلى الدرس التالي';

  @override
  String get unsupportedQuestion =>
      'نوع هذا السؤال غير مدعوم في هذا الإصدار من التطبيق.';

  @override
  String get errorConflict =>
      'هذا الإجراء غير متاح الآن. قد تكون المرحلة مقفلة أو قد تم استنفاد عدد المحاولات.';

  @override
  String get errorRateLimited =>
      'تم إرسال طلبات كثيرة. يرجى الانتظار قليلًا ثم المحاولة مرة أخرى.';

  @override
  String get errorTooLarge => 'الملف كبير جدًا.';

  @override
  String get errorUnsupportedMedia => 'نوع الملف هذا غير مدعوم.';

  @override
  String get readingMaterialTitle => 'النص العربي المعتمد من المعلم';

  @override
  String get readingMaterialEmpty => 'لم يتم نشر نص القراءة بعد.';

  @override
  String get readingPdfDownload => 'تنزيل ملف PDF الأصلي';

  @override
  String get readingPdfDownloading => 'جارٍ التنزيل…';

  @override
  String readingPdfReady(String size) {
    return 'تم تنزيل الملف ($size)';
  }

  @override
  String get readingPdfHandoffUnavailable =>
      'لا يمكن لهذا الإصدار حفظ ملفات PDF أو فتحها بعد.';

  @override
  String readingLineLabel(int number) {
    return 'السطر $number';
  }

  @override
  String get mediaAudioAvailable => 'الملف الصوتي للاستماع متاح.';

  @override
  String mediaVideoAvailable(String title) {
    return 'فيديو المعلم: $title';
  }

  @override
  String get mediaPlaybackUnavailable =>
      'التشغيل غير مفعّل في هذا الإصدار بعد.';

  @override
  String get mediaNone => 'لم يتم نشر صوت أو فيديو لهذه المرحلة.';

  @override
  String get speakingStartAttempt => 'ابدأ محاولة التحدث';

  @override
  String get speakingWaitingTitle => 'بانتظار التقييم';

  @override
  String get speakingWaitingBody =>
      'يقيّم مقيّم معتمد حديثك. ستظهر النتيجة هنا بمجرد تسجيلها.';

  @override
  String get speakingCheckResult => 'تحقق من النتيجة';

  @override
  String get speakingStillPending => 'لا توجد نتيجة بعد.';

  @override
  String get speakingAiUnavailable =>
      'ممارسة المحادثة بالذكاء الاصطناعي غير متاحة بعد.';

  @override
  String get rqTypeAnswer => 'إجابتك';

  @override
  String get rqArabicHint => 'اكتب بالعربية';

  @override
  String get rqWordBank => 'الكلمات المتاحة';

  @override
  String get rqYourOrder => 'ترتيبك';

  @override
  String get rqUndo => 'تراجع';

  @override
  String get rqReset => 'إعادة ضبط';

  @override
  String get rqBlank => 'فراغ';

  @override
  String get rqChooseWord => 'اختر الكلمة المناسبة للفراغ';

  @override
  String get rqNoQuestions => 'لا توجد أسئلة في هذا النشاط بعد.';

  @override
  String get attemptRestored => 'تمت استعادة محاولتك غير المكتملة.';

  @override
  String get attemptSubmitUnsure =>
      'تعذّر تأكيد الإرسال. إجاباتك محفوظة، حاول مرة أخرى.';

  @override
  String get resendConfirmation => 'إعادة إرسال رسالة التأكيد';

  @override
  String get confirmationResent =>
      'إذا كان هذا العنوان بحاجة إلى تأكيد فسيتم إرسال رسالة جديدة.';

  @override
  String get resetCodeLabel => 'الرمز الموجود في البريد';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get resetConfirmAction => 'تغيير كلمة المرور';

  @override
  String get resetDone => 'تم تغيير كلمة المرور. يمكنك تسجيل الدخول الآن.';

  @override
  String get confirmEmailTitle => 'جارٍ تأكيد بريدك الإلكتروني';

  @override
  String get confirmEmailDone =>
      'تم تأكيد البريد الإلكتروني. يمكنك تسجيل الدخول الآن.';

  @override
  String get confirmEmailFailed => 'رابط التأكيد غير صالح أو منتهي الصلاحية.';

  @override
  String get passwordPolicy =>
      'استخدم 12 حرفًا على الأقل مع أحرف كبيرة وصغيرة ورقم ورمز.';

  @override
  String get authInvalidInput => 'يرجى التحقق من البيانات التي أدخلتها.';

  @override
  String get attemptRecorded =>
      'تم تسجيل النتيجة. يتم تحديث نتيجة الدرس في صفحة الدرس.';

  @override
  String get homeRemoteNotice =>
      'دروسك ونتائجك الرسمية تأتي من حسابك. ستظهر ملخصات المفردات والمراجعة والنشاط هنا عند ربطها بحسابك.';

  @override
  String get localPracticeNotice =>
      'هذه بيانات تدريب محفوظة على هذا الجهاز فقط. وهي غير مرتبطة بحسابك وليست نتيجة رسمية.';

  @override
  String get authenticatorCodeLabel => 'رمز المصادقة (فقط إذا كنت تستخدمه)';

  @override
  String get deleteAccountTitle => 'حذف الحساب';

  @override
  String get deleteAccountAction => 'طلب حذف الحساب';

  @override
  String get deleteAccountIntro =>
      'يؤدي طلب الحذف إلى تعطيل حسابك فورًا وتسجيل خروجك من جميع الأجهزة.';

  @override
  String get deleteAccountReview =>
      'ثم يراجع مشغّل الخدمة طلبك. لا تُمحى بياناتك فورًا؛ يتولى المشغّل إتمام الإزالة النهائية.';

  @override
  String get deleteAccountPermanent =>
      'لن تتمكن من تسجيل الدخول بهذا الحساب مرة أخرى.';

  @override
  String get deleteAccountReauth =>
      'أدخل كلمة المرور للتأكد من أنك صاحب الحساب.';

  @override
  String get deleteAccountUnderstand => 'أفهم ذلك وأريد طلب الحذف';

  @override
  String get deleteAccountDialogTitle => 'طلب الحذف؟';

  @override
  String get deleteAccountDialogBody =>
      'سيتم تعطيل حسابك الآن. لا يمكن التراجع عن ذلك من التطبيق.';

  @override
  String get deleteAccountDone =>
      'تم استلام طلب الحذف. تم تعطيل حسابك وتسجيل خروجك. يتولى المشغّل إتمام الإزالة النهائية لبياناتك.';

  @override
  String get deleteAccountInvalid => 'كلمة المرور أو الرمز غير صالح.';

  @override
  String get mediaPlay => 'تشغيل';

  @override
  String get mediaPause => 'إيقاف مؤقت';

  @override
  String get mediaStop => 'إيقاف';

  @override
  String get mediaPlaybackFailed =>
      'تعذّر تشغيل الوسائط. قد تكون صلاحية الرابط قد انتهت أو قد تكون غير متصل.';

  @override
  String get mediaListeningAudio => 'الاستماع الصوتي';
}
