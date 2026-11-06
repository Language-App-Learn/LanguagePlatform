# PROJECT_STATUS — Mobil (Flutter)

> Her önemli görev sonunda güncelle. Kısa tut. Son güncelleme: 2026-11-06

## Tamamlanan özellikler
- Flutter proje iskeleti (Android/iOS, varsayılan sayaç şablonu; henüz özel kod yok).
- Claude Code yapılandırması: `CLAUDE.md`, `flutter-feature` ve `flutter-quality` skill'leri.

## Aktif geliştirme görevi
- Yok. (İlk görev: mimari temel — klasör yapısı, tema, l10n, state management seçimi.)

## Mimari kararlar
| Konu | Karar | Durum |
|---|---|---|
| Mimari desen | Feature-first (`lib/features/<f>/{data,domain,presentation}`, `lib/core/`) | Kararlı |
| Platform | Öğrenci uygulaması: Android + iOS | Kararlı |
| Yönetici paneli | Ayrı uygulama/proje | Kararlı |
| Dil/Yön | Çok dilli, RTL + LTR | Kararlı |
| State management | — | **Açık** (seçilince buraya yaz) |
| Routing | — | **Açık** |
| HTTP / API istemcisi | — | **Açık** (backend başka branch'te) |
| Localization altyapısı | — | **Açık** (Flutter `gen-l10n` önerilir; henüz kurulmadı) |
| Bağımlılıklar | Yalnızca `cupertino_icons`; yeni paketler gerekçesiyle eklenir | Kararlı |

## Bilinen hatalar
- Yok.

## Sonraki geliştirme adımları
1. Varsayılan şablonu (`lib/main.dart`, `test/widget_test.dart`) kaldırıp uygulama iskeletine geç.
2. `core/` altında tema + l10n (en az bir LTR ve bir RTL dil) kur.
3. State management ve routing kararını ver, yukarıya kaydet.
4. İlk feature'ı seç ve `flutter-feature` skill'i ile geliştir.
