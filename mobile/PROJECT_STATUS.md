# PROJECT_STATUS — Mobil (Flutter)

> Her önemli görev sonunda güncelle. Kısa tut. Son güncelleme: 2026-11-06

## Aşama durumu
| Aşama | Durum |
|---|---|
| 1 Foundation (Riverpod, GoRouter, tema, l10n, RTL, core UI) | ✅ Tamam |
| 2 Onboarding & tercihler (splash, tanıtım, 3 ayrı dil, tema) | ✅ Tamam |
| 3 Katalog (ana sayfa, kurs listesi, filtre, kurs detay, demo repo) | ✅ Tamam |
| 4 Ders motoru (içerik modeli, ders ekranı, diyalog/kelime/gramer/örnek/alıştırma, gezinme) | ✅ Tamam |
| 5 Quiz & ilerleme & kelimeler | ✅ Tamam |
| 6 Profil, ayarlar, giriş/kayıt UI (entegrasyon yer tutucuları) | ✅ Tamam |
| 7 Refactor, test, doğrulama | ✅ Tamam (Android debug build sonucu aşağıda) |

Devam eden aşama: yok. Sonraki: bkz. "Sonraki adımlar".

## Mimari
```
lib/
  main.dart                      → bootstrap(LanguagePlatformApp)
  app/        app.dart, bootstrap/, router/ (app_router, app_routes), shell/ (alt gezinme)
  core/       config/, error/, l10n/ (ARB, AppLanguage, LocalizedText), theme/ (tokens, renkler, tema),
              design_system/widgets/, utils/ (bidi)
  features/   splash, onboarding, language_selection, authentication, home, catalog, courses,
              lessons, assessment, vocabulary, progress, profile, settings
              (her biri ihtiyaca göre presentation/ application/ domain/ data/)
```
- Bağımlılık yönü: presentation → application → domain ← data. UI'da HTTP/DB yok.
- Tüm veri `*Repository` arayüzlerinden gelir; şu an **Demo** uygulamaları (`Demo*Repository`) provider'da bağlıdır. Gerçek API tek satırda (provider) değiştirilir.
- Router'da **auth guard yoktur** (gerçek kimlik doğrulama yok). Demo ↔ gerçek sınırı: `sessionProvider` (`signedOut | demo`), demo giriş `AppConfig.demoModeEnabled` (`--dart-define=DEMO_MODE=false` ile kapanır).
- Üç ayrı kavram: **arayüz dili** (`appLanguageProvider`, ARB), **bildiğim dil** ve **öğrendiğim dil** (`learningPreferencesProvider`). İçerik çevirileri `contentLanguageProvider` (bildiği dil → arayüz dili → en) ile seçilir; kurs/ders başlıkları arayüz dilinde gösterilir.
- Çok dilli içerik: `LocalizedText` (ör. `{tr, ar, en}`); arayüz metni: ARB (`context.l10n`). Sayılar Latin rakamla gösterilir; teknik değerler (e-posta, "A1", yüzde) `isolateLtr` ile RTL'de bozulmaz. Öğrenilen dil metni `ContentText` ile kendi yönünde çizilir.
- Ders içeriği `sealed LessonContent` (Heading, Text, Dialogue, Vocabulary, Grammar, Example, Exercise). Dinleme/video/ses kaydı/konuşma/AI etkinlikleri yeni alt sınıf olarak eklenir; `switch` derleme zamanında eksikleri gösterir. **Bu türler henüz yok ve çalışıyormuş gibi gösterilmez.**
- Quiz motoru `sealed QuizQuestion/QuizAnswer` + `QuizQuestion.isCorrect`; şu an yalnızca çoktan seçmeli. Quiz soruları demo olarak dersin alıştırma + kelimelerinden üretilir.

## Kararlar ve paketler
| Konu | Karar |
|---|---|
| State management | `flutter_riverpod` 3.4 (Notifier/AsyncNotifier; otomatik retry kapalı, "Tekrar dene" elle) |
| Routing | `go_router` 18 (`StatefulShellRoute` 5 sekme; detay sayfaları kök navigator'da) |
| Localization | `flutter_localizations` + `intl` + gen-l10n (tr, ar, en; yedek dil en) |
| Tema | Material 3, açık/koyu/sistem; token'lar `core/theme/app_tokens.dart`, marka renkleri `app_colors.dart` |
| HTTP | `dio` — **eklenmedi**, backend entegrasyonunda eklenecek |
| Kurulu paketler | cupertino_icons, flutter_localizations (SDK), intl, flutter_riverpod, go_router |

## Test sonuçları (2026-11-06)
- `flutter analyze`: temiz (0 sorun).
- `flutter test`: **156 test geçti** — alan mantığı (ilerleme, quiz, filtre, doğrulayıcılar, demo veri bütünlüğü, öğrenme yolu, quiz motoru), splash/onboarding/dil seçimi, katalog/kurs/ders/quiz/ilerleme/kelime akışları (loading/error/empty dahil), giriş/kayıt/şifre sıfırlama (sahte başarı yok), profil/ayarlar, RTL/LTR/aynalama, 14 ekran × 3 dil × açık/koyu duman testi (360×640, taşma yok).
- Duman testi giriş/kayıt satırındaki gerçek bir taşmayı yakaladı; düzeltildi.
- Android debug build: bkz. rapor (build uzun sürdü; sonuç raporda).
- iOS derlemesi Windows'ta yapılamaz → **doğrulanmadı**.

## Backend entegrasyonu bekleyenler (hepsi demo/yer tutucu)
- Kimlik doğrulama: `AuthRepository` arayüzü hazır, `UnavailableAuthRepository` her işlemde "servis bağlı değil" döner. Giriş/kayıt/şifre sıfırlama hiçbir şeyi başarılı saymaz; token/oturum üretilmez. Gerekenler: uç noktalar, token türü/yenileme, hata kodları, e-posta doğrulama, güvenli depolama kararı.
- Kurs/ders/kelime/quiz: `Demo*Repository` → DTO + Dio uygulaması. Bilinmeyenler: kimlik türleri, çok dilli alan biçimi, ders gövdesi blok şeması ve medya URL'leri, soru türü ayırt edici alanı, sayfalama.
- İlerleme (ders tamamlama, quiz sonucu, günlük hedef): yerel ve **kalıcı değil**; `ProgressRepository` + olay uçları gerekir.
- Kelime durumu: yerel; flashcard/aralıklı tekrar ve sözlük API'si sonra.
- Tercihler (arayüz dili, tema, bildiğim/öğrendiğim dil, onboarding görüldü): **kalıcı değil**; yerel depolama paketi kararı (ör. `shared_preferences`) onay bekliyor.
- Hesap ayarları (profil düzenleme, şifre değiştirme): devre dışı yer tutucu.
- Abonelik/ödeme: yok, sahte akış eklenmedi.

## Açık görevler
- **Marka / yayıncı kimliği kesinleşince:** Android `applicationId`/`namespace` (`com.example.musab_hoca_arapca`, `android/app/build.gradle.kts`, `MainActivity.kt` paket dizini), iOS `PRODUCT_BUNDLE_IDENTIFIER`, görünen ad, uygulama ikonu. Bilinçli olarak değiştirilmedi.
- Marka renkleri/logo (`AppColors.seed`, `BrandMark`) geçici.
- Arapça için özel font ihtiyacı gerçek cihazda değerlendirilecek (şimdilik sistem fontu).
- Gerçek cihazda erişilebilirlik (TalkBack/VoiceOver) ve büyük yazı boyutu elle denenmeli (otomatik testte yalnızca 360×640 ve semantics etiketleri var).
- Hesap bağımlı ekranlar için Dio + hata eşleme (`core/network/`).

## Bilinen sorunlar
- Tercihler ve ilerleme uygulama kapanınca sıfırlanır (bilinçli, kalıcılık bekliyor).
- Ders içi alıştırma sonucu ilerlemeye yazılmaz (yalnızca quiz yazar).
- `flutter pub get` linux/macos/windows `generated_plugin*` dosyalarını otomatik değiştirir (üretilmiş dosyalar).

## Sonraki geliştirme adımları
1. Yerel depolama kararı ve tercih/ilerleme kalıcılığı (onay gerekir).
2. Backend sözleşmesi netleşince `dio` + DTO eşlemeleri, gerçek `AuthRepository`, auth guard.
3. Flashcard / aralıklı tekrar; ses (dinleme) içeriği için yeni `LessonContent` türü.
4. Marka kimliği → paket kimlikleri, ikon, splash.
