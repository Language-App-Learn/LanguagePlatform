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
  String get skip => 'Geç';

  @override
  String get next => 'İleri';

  @override
  String get back => 'Geri';

  @override
  String get done => 'Tamam';

  @override
  String get startLesson => 'Derse başla';

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
  String get answerCorrect => 'Doğru!';

  @override
  String get answerIncorrect => 'Tam olarak değil.';

  @override
  String get nextLesson => 'Sonraki ders';

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
  String get answerTrue => 'Doğru';

  @override
  String get answerFalse => 'Yanlış';

  @override
  String get pageNotFoundTitle => 'Sayfa bulunamadı';

  @override
  String get pageNotFoundMessage => 'Açmaya çalıştığın sayfa mevcut değil.';

  @override
  String get goHome => 'Ana sayfaya git';

  @override
  String get brandTagline => 'DİL ÖĞRENME PLATFORMU';

  @override
  String lessonPosition(int current, int total) {
    return 'Ders $current / $total';
  }

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
  String get wordBank => 'Kelime havuzu';

  @override
  String get stageContentMissing =>
      'Bu dersin bu aşaması için henüz yayınlanmış içerik yok.';

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
  String get remoteSignInPrompt =>
      'İlerlemeni görmek ve kaydetmek için giriş yap.';

  @override
  String get remoteBeginLesson => 'Bu derse başla';

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
  String mediaVideoAvailable(String title) {
    return 'Öğretmen videosu: $title';
  }

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

  @override
  String get appLanguageTitle => 'Uygulama hangi dilde çalışsın?';

  @override
  String get appLanguageSubtitle => 'Uygulamanın arayüz dilini seçin.';

  @override
  String get menuLearn => 'Dil Öğren';

  @override
  String get menuTranslate => 'Tüm Dillerde Çeviri';

  @override
  String get menuTranslateSoon => 'Çeviri yakında geliyor.';

  @override
  String get languagePairTitle => 'Dil Seçimi';

  @override
  String get languagePairSubtitle =>
      'Bildiğin dili ve öğrenmek istediğin dili seç.';

  @override
  String get pairKnownLabel => 'Bildiğin Dil';

  @override
  String get pairTargetLabel => 'Öğreneceğin Dil';

  @override
  String get languageNameTr => 'Türkçe';

  @override
  String get languageNameAr => 'Arapça';

  @override
  String get sectionLearnArabic => 'Arapça Öğren';

  @override
  String get sectionReadingWriting => 'Okuma Yazma Öğren';

  @override
  String get sectionQuran => 'Kur\'an-ı Kerim';

  @override
  String get sectionExams => 'YDS / YDT / YÖKDİL';

  @override
  String get sectionAi => 'AI ile Pratik Yap';

  @override
  String get comingSoonTag => 'Yakında';

  @override
  String get featureUnavailable => 'Bu bölüm henüz kullanıma açılmadı.';

  @override
  String get levelPickerTitle => 'Seviye Seçimi';

  @override
  String get levelPickerSubtitle => 'Arapça öğrenmek için seviyeni seç.';

  @override
  String get levelFromScratch => 'Sıfırdan Öğren';

  @override
  String get lessonMenuSubtitle => 'Öğrenme modunu seç.';

  @override
  String get modeTest => 'Test';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get lessonMenuTitle => 'Arapça Dersleri';
}
