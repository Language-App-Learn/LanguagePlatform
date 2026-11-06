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
}
