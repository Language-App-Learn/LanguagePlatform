// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'LanguagePlatform';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti. Lütfen tekrar dene.';

  @override
  String get errorNotFound => 'Aradığın içeriği bulamadık.';

  @override
  String get loadingLabel => 'Yükleniyor';

  @override
  String get demoNotice => 'Demo verisi. Hiçbir şey sunucuya kaydedilmez.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get interfaceLanguageTitle => 'Uygulama dili';

  @override
  String get themeTitle => 'Görünüm';

  @override
  String get themeModeSystem => 'Sistem';

  @override
  String get themeModeLight => 'Açık';

  @override
  String get themeModeDark => 'Koyu';

  @override
  String get skip => 'Geç';

  @override
  String get next => 'İleri';

  @override
  String get back => 'Geri';

  @override
  String get getStarted => 'Başla';

  @override
  String get continueAction => 'Devam et';

  @override
  String get onboarding1Title => 'Yeni bir dil öğren';

  @override
  String get onboarding1Body =>
      'Öğrenmek istediğin dili seç ve bildiğin dilden başla.';

  @override
  String get onboarding2Title => 'Etkileşimli derslerle ilerle';

  @override
  String get onboarding2Body =>
      'Diyalog, kelime ve dilbilgisi içeren kısa dersler adım adım ilerlemeni sağlar.';

  @override
  String get onboarding3Title => 'Kelime ve konuşma pratiği yap';

  @override
  String get onboarding3Body =>
      'Bugün kelimeleri tekrar et. Konuşma pratiği yolda.';

  @override
  String get onboarding4Title => 'Gelişimini takip et';

  @override
  String get onboarding4Body =>
      'Tamamlanan dersleri, test sonuçlarını ve günlük hedefini tek yerde gör.';

  @override
  String onboardingStepSemantics(int current, int total) {
    return 'Adım $current / $total';
  }

  @override
  String get languageSetupTitle => 'Dillerini seç';

  @override
  String get languageSetupSubtitle =>
      'Uygulama dili, bildiğin dil ve öğrenmek istediğin dil üç ayrı seçimdir.';

  @override
  String get knownLanguageTitle => 'Konuştuğum dil';

  @override
  String get targetLanguageTitle => 'Öğrenmek istediğim dil';

  @override
  String get sameLanguageHint =>
      '\"Konuştuğum dil\" ve \"Öğrenmek istediğim dil\" için birbirinden farklı iki dil seç.';

  @override
  String get chooseBothLanguagesHint =>
      'Bildiğin dili ve öğrenmek istediğin dili seç.';

  @override
  String get done => 'Tamam';

  @override
  String get viewAll => 'Tümünü gör';

  @override
  String get startLesson => 'Derse başla';

  @override
  String get continueCourse => 'Devam et';

  @override
  String get startCourse => 'Kursa başla';

  @override
  String get reviewCourse => 'Kursu tekrar et';

  @override
  String get navHome => 'Ana sayfa';

  @override
  String get navCourses => 'Kurslar';

  @override
  String get navVocabulary => 'Kelimeler';

  @override
  String get navProgress => 'İlerleme';

  @override
  String get navProfile => 'Profil';

  @override
  String get homeGreeting => 'Tekrar hoş geldin';

  @override
  String homeLearningLabel(String language) {
    return 'Öğrenilen dil: $language';
  }

  @override
  String get homeChooseTargetHint => 'Ayarlardan öğrenmek istediğin dili seç.';

  @override
  String get homeDailyGoalTitle => 'Günlük hedef';

  @override
  String get homeGoalReached => 'Bugünkü hedefe ulaştın!';

  @override
  String homeDailyGoalProgress(int done, int goal) {
    return 'Bugün $done/$goal ders';
  }

  @override
  String get homeContinueTitle => 'Öğrenmeye devam et';

  @override
  String get homeStartTitle => 'İlk dersine başla';

  @override
  String get homeNextLessonTitle => 'Sıradaki ders';

  @override
  String get homeAllDone => 'Mevcut tüm dersleri tamamladın. Harika!';

  @override
  String get homeFeaturedCourses => 'Öne çıkan kurslar';

  @override
  String get homeRecommendedPractice => 'Önerilen pratik';

  @override
  String get practiceVocabularyTitle => 'Kelimeleri tekrar et';

  @override
  String get practiceVocabularySubtitle =>
      'Kelimelerine göz at ve öğrenme durumunu güncelle';

  @override
  String get practiceQuizTitle => 'Kendini test et';

  @override
  String get homeProgressTitle => 'İlerlemen';

  @override
  String get coursesTitle => 'Kurslar';

  @override
  String get searchCoursesHint => 'Kurs ara';

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String get filterLanguageTitle => 'Dil';

  @override
  String get filterLevelTitle => 'Seviye';

  @override
  String get filterAll => 'Tümü';

  @override
  String get noCoursesTitle => 'Kurs bulunamadı';

  @override
  String get noCoursesMessage => 'Aramayı veya filtreleri değiştirmeyi dene.';

  @override
  String get clearFilters => 'Filtreleri temizle';

  @override
  String lessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ders',
      one: '1 ders',
      zero: 'Ders yok',
    );
    return '$_temp0';
  }

  @override
  String lessonMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String courseProgressLabel(int done, int total) {
    return '$done/$total ders';
  }

  @override
  String get courseLessonsTitle => 'Dersler';

  @override
  String get noLessonsTitle => 'Dersler yakında';

  @override
  String get noLessonsMessage => 'Bu kursun içeriği hazırlanıyor.';

  @override
  String quizBestScore(String score) {
    return 'En iyi: $score';
  }

  @override
  String get lessonDialogue => 'Diyalog';

  @override
  String get lessonVocabulary => 'Kelimeler';

  @override
  String get lessonGrammar => 'Dilbilgisi';

  @override
  String get lessonExample => 'Örnek';

  @override
  String get lessonExercise => 'Alıştırma';

  @override
  String get checkAnswer => 'Cevabı kontrol et';

  @override
  String get answerCorrect => 'Doğru!';

  @override
  String get answerIncorrect => 'Tam olarak değil.';

  @override
  String get markLessonComplete => 'Tamamlandı olarak işaretle';

  @override
  String get lessonCompleted => 'Tamamlandı';

  @override
  String get takeQuiz => 'Teste başla';

  @override
  String get previousLesson => 'Önceki ders';

  @override
  String get nextLesson => 'Sonraki ders';

  @override
  String get quizTitle => 'Test';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Soru $current / $total';
  }

  @override
  String get quizNext => 'Sonraki soru';

  @override
  String get quizFinish => 'Sonucu gör';

  @override
  String get quizResultTitle => 'Sonucun';

  @override
  String quizScoreSummary(int correct, int total) {
    return '$total sorudan $correct doğru';
  }

  @override
  String get quizPassed => 'Harika iş!';

  @override
  String get quizFailed => 'Çalışmaya devam et.';

  @override
  String get quizTryAgain => 'Tekrar dene';

  @override
  String get quizLocalOnly =>
      'Bu demo sürümünde sonuçlar yalnızca bu cihazda tutulur.';

  @override
  String get quizEmptyTitle => 'Henüz soru yok';

  @override
  String get vocabularyTitle => 'Kelimeler';

  @override
  String get vocabularyEmptyTitle => 'Kelime bulunamadı';

  @override
  String get vocabularyEmptyMessage =>
      'Filtreyi değiştir veya öğrenmek için bir dil seç.';

  @override
  String get vocabularyStatusNew => 'Yeni';

  @override
  String get vocabularyStatusLearning => 'Öğreniliyor';

  @override
  String get vocabularyStatusLearned => 'Öğrenildi';

  @override
  String get wordMeaning => 'Anlamı';

  @override
  String get wordStatusTitle => 'Öğrenme durumu';

  @override
  String get progressTitle => 'İlerleme';

  @override
  String get progressDemoNotice =>
      'İlerleme yalnızca bu cihazda tutulur ve uygulama kapanınca sıfırlanır. Bir hesaba kaydedilmez.';

  @override
  String get progressCompletedLessons => 'Tamamlanan ders';

  @override
  String get progressAverageScore => 'Ortalama test puanı';

  @override
  String get progressNoQuizYet => 'Henüz test yok';

  @override
  String get progressDailyGoalTitle => 'Günlük hedef';

  @override
  String dailyGoalOption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Günde $count ders',
      one: 'Günde 1 ders',
    );
    return '$_temp0';
  }

  @override
  String get progressCoursesTitle => 'Kurs ilerlemesi';

  @override
  String get progressEmptyTitle => 'Henüz ilerleme yok';

  @override
  String get progressEmptyMessage =>
      'İlerlemeni burada görmek için bir ders tamamla.';

  @override
  String get browseCourses => 'Kurslara göz at';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileDemoName => 'Demo öğrenci';

  @override
  String get profileGuestName => 'Misafir';

  @override
  String get profileDemoSubtitle => 'Demo modu, giriş yapılmadı';

  @override
  String get profileSignedOutSubtitle => 'Giriş yapılmadı';

  @override
  String get profileLanguagesTitle => 'Diller';

  @override
  String get accountIntegrationPending =>
      'Hesap özellikleri sunucu bağlantısı gerektirir ve henüz kullanılamaz.';

  @override
  String get exitDemoMode => 'Demo modundan çık';

  @override
  String get accountSectionTitle => 'Hesap';

  @override
  String get editProfile => 'Profili düzenle';

  @override
  String get changePassword => 'Şifreyi değiştir';

  @override
  String get aboutTitle => 'Hakkında';

  @override
  String get aboutDescription =>
      'LanguagePlatform, dilleri kendi dilinde öğrenmeni sağlar. Bu bir demo sürümüdür.';

  @override
  String get loginTitle => 'Giriş yap';

  @override
  String get loginSubtitle => 'Devam etmek için giriş yap';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get forgotPasswordLink => 'Şifremi unuttum';

  @override
  String get loginButton => 'Giriş yap';

  @override
  String get noAccountPrompt => 'Hesabın yok mu?';

  @override
  String get registerButton => 'Kayıt ol';

  @override
  String get demoModeExplain =>
      'Demo modu, uygulamayı örnek içerikle gezmeni sağlar. Hesap oluşturulmaz ve hiçbir şey kaydedilmez.';

  @override
  String get continueDemo => 'Demo modunda devam et';

  @override
  String get registerTitle => 'Hesap oluştur';

  @override
  String get registerSubtitle =>
      'Hesap oluşturma, servis bağlandığında kullanılabilir olacak.';

  @override
  String get nameLabel => 'Ad';

  @override
  String get confirmPasswordLabel => 'Şifre tekrar';

  @override
  String get haveAccountPrompt => 'Zaten hesabın var mı?';

  @override
  String get forgotPasswordTitle => 'Şifreyi sıfırla';

  @override
  String get forgotPasswordSubtitle =>
      'E-postanı gir, sıfırlama yönergelerini gönderelim.';

  @override
  String get sendResetButton => 'Sıfırlama bağlantısı gönder';

  @override
  String get fieldRequired => 'Bu alan zorunlu';

  @override
  String get invalidEmail => 'Geçerli bir e-posta adresi gir';

  @override
  String passwordTooShort(int min) {
    return 'Şifre en az $min karakter olmalı';
  }

  @override
  String get passwordsDontMatch => 'Şifreler eşleşmiyor';

  @override
  String get showPassword => 'Şifreyi göster';

  @override
  String get hidePassword => 'Şifreyi gizle';

  @override
  String get authUnavailable =>
      'Giriş henüz bir sunucuya bağlı değil. Bu sürüm hesap oluşturamaz veya doğrulayamaz.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get homeResumeTitle => 'Dersine devam et';

  @override
  String get weeklyActivityTitle => 'Son 7 gün';

  @override
  String activityStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days günlük seri',
      one: '1 günlük seri',
    );
    return '$_temp0';
  }

  @override
  String get activityNone =>
      'Henüz kayıtlı etkinlik yok. Bir ders, test veya tekrar tamamladığında burada görünür.';

  @override
  String get statWordsLearned => 'Öğrenilen kelime';

  @override
  String get statWordsLearning => 'Devam eden kelime';

  @override
  String get statReviewsDue => 'Bekleyen tekrar';

  @override
  String get vocabularySearchHint => 'Kelime ara';

  @override
  String get vocabularyFavorites => 'Favoriler';

  @override
  String get favoriteAdd => 'Favorilere ekle';

  @override
  String get favoriteRemove => 'Favorilerden çıkar';

  @override
  String get reviewDueBadge => 'Tekrar zamanı geldi';

  @override
  String reviewDueBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kelime tekrar bekliyor',
      one: '1 kelime tekrar bekliyor',
      zero: 'Tekrar bekleyen kelime yok. Yeni kelimeler çalış',
    );
    return '$_temp0';
  }

  @override
  String get startReview => 'Tekrar';

  @override
  String get reviewTitle => 'Kelime kartları';

  @override
  String get reviewShowAnswer => 'Cevabı göster';

  @override
  String reviewProgress(int current, int total) {
    return 'Kart $current / $total';
  }

  @override
  String get ratingAgain => 'Tekrar';

  @override
  String get ratingHard => 'Zor';

  @override
  String get ratingGood => 'İyi';

  @override
  String get ratingEasy => 'Kolay';

  @override
  String get reviewDoneTitle => 'Oturum tamamlandı';

  @override
  String reviewDoneSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kelime tekrar ettin.',
      one: '1 kelime tekrar ettin.',
    );
    return '$_temp0';
  }

  @override
  String get reviewNothingTitle => 'Tekrar edilecek bir şey yok';

  @override
  String get reviewNothingMessage =>
      'Öğrenmek için bir dil seç veya kelimelerin zamanı gelince geri dön.';

  @override
  String get settingsDemoNotice =>
      'Demo sürümü: ayarların ve ilerlemen yalnızca bu cihazda tutulur, bir hesapta değil.';

  @override
  String get resetDataTitle => 'Yerel demo verilerini sıfırla';

  @override
  String get resetDataSubtitle =>
      'Bu cihazdaki ilerleme, kelime durumu ve tercihleri siler';

  @override
  String get resetDataConfirmTitle => 'Yerel veriler sıfırlansın mı?';

  @override
  String get resetDataConfirmMessage =>
      'Bu cihazdaki tanıtım durumu, dil seçimleri, ilerleme ve kelime kayıtları silinir. Geri alınamaz.';

  @override
  String get resetDataConfirmAction => 'Sıfırla';

  @override
  String get errorNetwork =>
      'İnternet bağlantısı yok. Bağlantını kontrol edip tekrar dene.';

  @override
  String get errorTimeout => 'İstek çok uzun sürdü. Lütfen tekrar dene.';

  @override
  String get errorUnauthorized => 'Devam etmek için lütfen giriş yap.';

  @override
  String get errorForbidden => 'Bu içeriğe erişimin yok.';

  @override
  String get errorServer =>
      'Sunucuda bir sorun oluştu. Lütfen daha sonra tekrar dene.';

  @override
  String get errorUnavailable => 'Bu özellik henüz bağlı değil.';

  @override
  String get storageWriteFailed =>
      'Bazı değişiklikler bu cihaza kaydedilemedi ve uygulamayı kapatınca kaybolabilir.';

  @override
  String get answerTrue => 'Doğru';

  @override
  String get answerFalse => 'Yanlış';

  @override
  String get unsupportedContent =>
      'Bu içerik uygulamanın bu sürümünde desteklenmiyor.';

  @override
  String get pageNotFoundTitle => 'Sayfa bulunamadı';

  @override
  String get pageNotFoundMessage => 'Açmaya çalıştığın sayfa mevcut değil.';

  @override
  String get goHome => 'Ana sayfaya git';

  @override
  String get activeCourseTitle => 'Kursun';

  @override
  String get activeCourseEmptyTitle => 'Henüz kurs yok';

  @override
  String get activeCourseEmptyMessage =>
      'Seviyeni ve ilerlemeni burada görmek için bir kurs seç.';

  @override
  String get openCourse => 'Kursu aç';

  @override
  String get reviewHistoryTitle => 'Tekrar geçmişi';

  @override
  String get reviewHistoryEmptyTitle => 'Henüz tekrar yok';

  @override
  String get reviewHistoryEmptyMessage =>
      'Kelime kartı tekrarların burada görünecek.';

  @override
  String historyNextReview(String date) {
    return 'Sonraki tekrar: $date';
  }

  @override
  String get historyUnknownWord => 'Kelime artık mevcut değil';

  @override
  String get reviewHistoryOpen => 'Tekrar geçmişi';

  @override
  String get brandTagline => 'Dilleri kendi dilinde öğren.';

  @override
  String lessonPosition(int current, int total) {
    return 'Ders $current / $total';
  }

  @override
  String get lessonCompletedSnack => 'Ders tamamlandı olarak işaretlendi';

  @override
  String get leaveQuizTitle => 'Testten çıkılsın mı?';

  @override
  String get leaveQuizMessage => 'Bu denemedeki cevapların kaydedilmeyecek.';

  @override
  String get leaveQuizConfirm => 'Çık';

  @override
  String optionLetterSemantics(String letter) {
    return '$letter şıkkı';
  }

  @override
  String get trackTitle => 'Türkçeden Arapça Öğrenme';

  @override
  String get trackSubtitle => 'CEFR seviyeni seç';

  @override
  String get demoContentBadge => 'Demo içerik';

  @override
  String get levelNameA1 => 'Başlangıç';

  @override
  String get levelNameA2 => 'Temel';

  @override
  String get levelNameB1 => 'Orta';

  @override
  String get levelNameB2 => 'Orta Üstü';

  @override
  String get levelNameC1 => 'İleri';

  @override
  String get levelNameC2 => 'Yetkin';

  @override
  String levelPublishedCount(int published, int total) {
    return '$total dersten $published tanesi yayında';
  }

  @override
  String levelCompletedCount(int count) {
    return '$count tamamlandı';
  }

  @override
  String get levelNoLessons => 'Henüz yayınlanmış ders yok';

  @override
  String lessonNumber(int number) {
    return 'Ders $number';
  }

  @override
  String get lessonInPreparation => 'Hazırlanıyor';

  @override
  String get stageReading => 'Okuma';

  @override
  String get stageSpeaking => 'Konuşma';

  @override
  String get stageListening => 'Dinleme';

  @override
  String get stageWriting => 'Yazma';

  @override
  String get stageTranslation => 'Tercüme';

  @override
  String get stageReadingDesc =>
      'Arapça metni oku, her satırı dinle ve soruları cevapla.';

  @override
  String get stageSpeakingDesc => 'Diyaloğu incele ve konuşma pratiği yap.';

  @override
  String get stageListeningDesc => 'Dinle ve kelimeleri boşluklara yerleştir.';

  @override
  String get stageWritingDesc => 'Eksik kelimeleri tamamla ve cümle kur.';

  @override
  String get stageTranslationDesc => 'Türkçeden Arapçaya çevir.';

  @override
  String get stageStatusAvailable => 'Açık';

  @override
  String get stageStatusInProgress => 'Devam ediyor';

  @override
  String get stageStatusCompleted => 'Tamamlandı';

  @override
  String get stageStatusLocked => 'Henüz erişilemez';

  @override
  String get stageStatusUnavailable => 'İçerik henüz yayınlanmadı';

  @override
  String get stageRetry => 'Tekrar çalış';

  @override
  String get lessonStatusNotStarted => 'Başlanmadı';

  @override
  String get lessonStatusInProgress => 'Devam ediyor';

  @override
  String get lessonStatusAwaiting => 'Resmî değerlendirme bekleniyor';

  @override
  String get lessonStatusPassed => 'Geçti';

  @override
  String get lessonStatusFailed => 'Geçilemedi, tekrar dene';

  @override
  String get overallScoreNone => 'Henüz resmî puan yok';

  @override
  String passMarkInfo(int mark) {
    return 'Genel geçme notu: 100 üzerinden $mark';
  }

  @override
  String get scoringPolicyMissing =>
      'Aşama ağırlıkları sunucu tarafından belirlenir ve henüz mevcut değil; bu yüzden nihai puan gösterilmiyor.';

  @override
  String get demoScoreNotice =>
      'Demo alıştırma sonucu. Resmî puan değildir ve geçmeye sayılmaz.';

  @override
  String stageScoreLabel(String score) {
    return 'Alıştırma puanı: $score';
  }

  @override
  String get audioUnavailable => 'Ses henüz mevcut değil';

  @override
  String get pdfUnavailable => 'Orijinal PDF henüz mevcut değil';

  @override
  String get videoUnavailable => 'Öğretmen videosu henüz mevcut değil';

  @override
  String get aiPracticeTitle => 'Konuşma pratiği';

  @override
  String get aiPracticeUnavailable =>
      'Yapay zekâ konuşma pratiği henüz bağlı değil. Hiçbir kayıt alınmaz veya gönderilmez.';

  @override
  String get dialogueTitle => 'Diyalog';

  @override
  String get readingQuestionsTitle => 'Sorular';

  @override
  String get listeningInstruction =>
      'Ses henüz mevcut değil. Her kelimeyi doğru boşluğa yerleştir.';

  @override
  String get writingFillTitle => 'Boşluğu doldur';

  @override
  String get writingArrangeTitle => 'Kelimeleri sırala';

  @override
  String get translationChoiceTitle => 'Doğru çeviriyi seç';

  @override
  String get translationWriteTitle => 'Çeviriyi yaz';

  @override
  String get wordBank => 'Kelime havuzu';

  @override
  String get tapToPlace =>
      'Bir kelimeye, sonra bir boşluğa dokun (veya kelimeyi sürükle).';

  @override
  String blankLabel(int number) {
    return '$number. boşluk';
  }

  @override
  String get checkStage => 'Cevapları kontrol et';

  @override
  String get resetStage => 'Sıfırla';

  @override
  String get undoStep => 'Geri al';

  @override
  String get yourAnswer => 'Cevabın';

  @override
  String get finishPractice => 'Alıştırmayı bitir';

  @override
  String get stageContentMissing =>
      'Bu dersin bu aşaması için henüz yayınlanmış içerik yok.';

  @override
  String resultCorrect(int correct, int total) {
    return '$total sorudan $correct doğru';
  }

  @override
  String get practiceRecorded => 'Alıştırma bu cihazda kaydedildi (demo).';

  @override
  String get authInvalidCredentials =>
      'E-posta veya şifre hatalı ya da hesap henüz onaylanmamış.';

  @override
  String get registerAccepted =>
      'Kayıt isteği gönderildi. Hesabını onaylamak için e-postanı kontrol et.';

  @override
  String get resetRequested =>
      'Bu adres bir hesaba aitse sıfırlama yönergeleri gönderilecek.';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get profileAccountSubtitle => 'Hesabına giriş yapıldı';

  @override
  String get remoteSignInPrompt =>
      'İlerlemeni görmek ve kaydetmek için giriş yap.';

  @override
  String get remoteNotConfigured =>
      'Bu sürümde öğrenme sunucusu yapılandırılmamış.';

  @override
  String get remoteBeginLesson => 'Bu derse başla';

  @override
  String get remoteNoCourse =>
      'Henüz yayınlanmış bir Türkçeden Arapçaya kurs yok.';

  @override
  String stageAttempts(int count) {
    return 'Deneme: $count';
  }

  @override
  String stageWeight(String weight) {
    return 'Ağırlık: %$weight';
  }

  @override
  String get remoteStageNoAssessment =>
      'Bu aşama için henüz puanlanan bir etkinlik yayınlanmadı.';

  @override
  String get remoteStageTextTitle => 'Aşama metni';

  @override
  String get startAssessment => 'Puanlı etkinliği başlat';

  @override
  String get submitAnswers => 'Cevapları gönder';

  @override
  String get officialResultTitle => 'Resmî sonuç';

  @override
  String officialResultScore(String score, String max) {
    return '$max üzerinden $score';
  }

  @override
  String get attemptPassed => 'Geçti';

  @override
  String get attemptNotPassed => 'Geçemedi';

  @override
  String get nextLessonAction => 'Sonraki derse git';

  @override
  String get unsupportedQuestion =>
      'Bu soru türü uygulamanın bu sürümünde desteklenmiyor.';

  @override
  String get errorConflict =>
      'Bu işlem şu anda yapılamıyor. Aşama kilitli olabilir veya deneme hakkı dolmuş olabilir.';

  @override
  String get errorRateLimited =>
      'Çok fazla istek gönderildi. Lütfen biraz bekleyip tekrar deneyin.';

  @override
  String get errorTooLarge => 'Dosya çok büyük.';

  @override
  String get errorUnsupportedMedia => 'Bu dosya türü desteklenmiyor.';

  @override
  String get readingMaterialTitle => 'Öğretmen onaylı Arapça metin';

  @override
  String get readingMaterialEmpty => 'Okuma metni henüz yayınlanmadı.';

  @override
  String get readingPdfDownload => 'Orijinal PDF\'i indir';

  @override
  String get readingPdfDownloading => 'İndiriliyor…';

  @override
  String readingPdfReady(String size) {
    return 'PDF indirildi ($size)';
  }

  @override
  String get readingPdfHandoffUnavailable =>
      'Bu sürüm PDF dosyalarını henüz kaydedemiyor veya açamıyor.';

  @override
  String readingLineLabel(int number) {
    return 'Satır $number';
  }

  @override
  String get mediaAudioAvailable => 'Dinleme sesi hazır.';

  @override
  String mediaVideoAvailable(String title) {
    return 'Öğretmen videosu: $title';
  }

  @override
  String get mediaPlaybackUnavailable =>
      'Oynatma bu sürümde henüz etkin değil.';

  @override
  String get mediaNone => 'Bu aşama için ses veya video yayınlanmadı.';

  @override
  String get speakingStartAttempt => 'Konuşma denemesini başlat';

  @override
  String get speakingWaitingTitle => 'Değerlendirme bekleniyor';

  @override
  String get speakingWaitingBody =>
      'Konuşmanız yetkili bir değerlendirmeci tarafından puanlanır. Sonuç kaydedilince burada görünür.';

  @override
  String get speakingCheckResult => 'Sonucu kontrol et';

  @override
  String get speakingStillPending => 'Henüz sonuç yok.';

  @override
  String get speakingAiUnavailable =>
      'Yapay zekâ ile konuşma pratiği henüz kullanılamıyor.';

  @override
  String get rqTypeAnswer => 'Cevabınız';

  @override
  String get rqArabicHint => 'Arapça yazın';

  @override
  String get rqWordBank => 'Kullanılabilir kelimeler';

  @override
  String get rqYourOrder => 'Sıralamanız';

  @override
  String get rqUndo => 'Geri al';

  @override
  String get rqReset => 'Sıfırla';

  @override
  String get rqBlank => 'boşluk';

  @override
  String get rqChooseWord => 'Boşluğa uygun kelimeyi seçin';

  @override
  String get rqNoQuestions => 'Bu etkinlikte henüz soru yok.';

  @override
  String get attemptRestored => 'Yarım kalan denemeniz geri yüklendi.';

  @override
  String get attemptSubmitUnsure =>
      'Gönderim doğrulanamadı. Cevaplarınız saklandı, tekrar deneyin.';

  @override
  String get resendConfirmation => 'Onay e-postasını yeniden gönder';

  @override
  String get confirmationResent =>
      'Bu adres onay bekliyorsa yeni bir e-posta gönderilecek.';

  @override
  String get resetCodeLabel => 'E-postadaki kod';

  @override
  String get newPasswordLabel => 'Yeni parola';

  @override
  String get resetConfirmAction => 'Parolayı değiştir';

  @override
  String get resetDone => 'Parola değiştirildi. Şimdi giriş yapabilirsiniz.';

  @override
  String get confirmEmailTitle => 'E-postanız onaylanıyor';

  @override
  String get confirmEmailDone =>
      'E-posta onaylandı. Şimdi giriş yapabilirsiniz.';

  @override
  String get confirmEmailFailed =>
      'Onay bağlantısı geçersiz veya süresi dolmuş.';

  @override
  String get passwordPolicy =>
      'En az 12 karakter; büyük ve küçük harf, rakam ve sembol kullanın.';

  @override
  String get authInvalidInput => 'Lütfen girdiğiniz bilgileri kontrol edin.';

  @override
  String get attemptRecorded =>
      'Sonuç kaydedildi. Ders sonucu ders sayfasında güncellenir.';

  @override
  String get homeRemoteNotice =>
      'Dersleriniz ve resmî sonuçlarınız hesabınızdan gelir. Kelime, tekrar ve etkinlik özetleri hesabınıza bağlandığında burada görünecek.';

  @override
  String get localPracticeNotice =>
      'Bu veriler yalnızca bu cihazda saklanan alıştırma verileridir. Hesabınıza bağlı değildir ve resmî sonuç sayılmaz.';

  @override
  String get authenticatorCodeLabel =>
      'Doğrulayıcı kodu (yalnızca kullanıyorsanız)';

  @override
  String get deleteAccountTitle => 'Hesabı sil';

  @override
  String get deleteAccountAction => 'Hesap silme talebi gönder';

  @override
  String get deleteAccountIntro =>
      'Silme talebi hesabınızı hemen devre dışı bırakır ve tüm cihazlardaki oturumlarınızı kapatır.';

  @override
  String get deleteAccountReview =>
      'Talebiniz daha sonra hizmet işletmecisi tarafından incelenir. Verileriniz anında silinmez; kalıcı silme işlemini işletmeci tamamlar.';

  @override
  String get deleteAccountPermanent =>
      'Bu hesapla bir daha giriş yapamazsınız.';

  @override
  String get deleteAccountReauth =>
      'Sizin olduğunuzu doğrulamak için parolanızı girin.';

  @override
  String get deleteAccountUnderstand =>
      'Anladım ve silme talebi göndermek istiyorum';

  @override
  String get deleteAccountDialogTitle => 'Silme talebi gönderilsin mi?';

  @override
  String get deleteAccountDialogBody =>
      'Hesabınız şimdi devre dışı bırakılacak. Bu işlem uygulamadan geri alınamaz.';

  @override
  String get deleteAccountDone =>
      'Silme talebiniz alındı. Hesabınız devre dışı bırakıldı ve oturumunuz kapatıldı. Verilerinizin kalıcı silinmesini işletmeci tamamlar.';

  @override
  String get deleteAccountInvalid => 'Parola veya kod geçerli değil.';

  @override
  String get mediaPlay => 'Oynat';

  @override
  String get mediaPause => 'Duraklat';

  @override
  String get mediaStop => 'Durdur';

  @override
  String get mediaPlaybackFailed =>
      'Medya oynatılamadı. Bağlantının süresi dolmuş olabilir veya çevrimdışı olabilirsiniz.';

  @override
  String get mediaListeningAudio => 'Dinleme sesi';
}
