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
  String get skip => 'تخطّي';

  @override
  String get next => 'التالي';

  @override
  String get back => 'السابق';

  @override
  String get done => 'تم';

  @override
  String get startLesson => 'ابدأ الدرس';

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
  String get answerCorrect => 'صحيح!';

  @override
  String get answerIncorrect => 'ليس تمامًا.';

  @override
  String get nextLesson => 'الدرس التالي';

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
  String get answerTrue => 'صحيح';

  @override
  String get answerFalse => 'خطأ';

  @override
  String get pageNotFoundTitle => 'الصفحة غير موجودة';

  @override
  String get pageNotFoundMessage => 'الصفحة التي فتحتها غير موجودة.';

  @override
  String get goHome => 'الذهاب إلى الرئيسية';

  @override
  String get brandTagline => 'منصة تعلّم اللغات';

  @override
  String lessonPosition(int current, int total) {
    return 'الدرس $current من $total';
  }

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
  String get wordBank => 'بنك الكلمات';

  @override
  String get stageContentMissing =>
      'لا يوجد محتوى منشور لهذه المرحلة من الدرس بعد.';

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
  String get remoteSignInPrompt => 'سجّل الدخول لعرض تقدّمك وحفظه.';

  @override
  String get remoteBeginLesson => 'ابدأ هذا الدرس';

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
  String mediaVideoAvailable(String title) {
    return 'فيديو المعلم: $title';
  }

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

  @override
  String get appLanguageTitle => 'بأي لغة يعمل التطبيق؟';

  @override
  String get appLanguageSubtitle => 'اختر لغة واجهة التطبيق.';

  @override
  String get menuLearn => 'تعلّم لغة';

  @override
  String get menuTranslate => 'الترجمة بجميع اللغات';

  @override
  String get menuTranslateSoon => 'الترجمة قريبًا.';

  @override
  String get languagePairTitle => 'اختيار اللغة';

  @override
  String get languagePairSubtitle =>
      'اختر اللغة التي تعرفها واللغة التي تريد تعلّمها.';

  @override
  String get pairKnownLabel => 'اللغة التي تعرفها';

  @override
  String get pairTargetLabel => 'اللغة التي ستتعلّمها';

  @override
  String get languageNameTr => 'التركية';

  @override
  String get languageNameAr => 'العربية';

  @override
  String get sectionLearnArabic => 'تعلّم العربية';

  @override
  String get sectionReadingWriting => 'تعلّم القراءة والكتابة';

  @override
  String get sectionQuran => 'القرآن الكريم';

  @override
  String get sectionExams => 'YDS / YDT / YÖKDİL';

  @override
  String get sectionAi => 'تدرّب مع الذكاء الاصطناعي';

  @override
  String get comingSoonTag => 'قريبًا';

  @override
  String get featureUnavailable => 'هذا القسم غير متاح بعد.';

  @override
  String get levelPickerTitle => 'اختيار المستوى';

  @override
  String get levelPickerSubtitle => 'اختر مستواك لتعلّم العربية.';

  @override
  String get levelFromScratch => 'ابدأ من الصفر';

  @override
  String get lessonMenuSubtitle => 'اختر وضع التعلّم.';

  @override
  String get modeTest => 'الاختبار';

  @override
  String get continueButton => 'متابعة';

  @override
  String get lessonMenuTitle => 'دروس العربية';
}
