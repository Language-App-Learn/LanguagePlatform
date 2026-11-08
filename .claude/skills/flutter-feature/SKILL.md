---
name: flutter-feature
description: Use when adding or changing a feature, screen, widget, or flow in the Flutter mobile app under mobile/ (e.g. "yeni ekran ekle", "özellik geliştir", "add a lesson screen", "implement login flow"). Covers feature-first structure, widget splitting, state management, localization/RTL, and tests. Not for backend work.
---

# Flutter feature geliştirme

Çalışma dizini: `mobile/`. Backend'e dokunma.

## 1. Hazırlık (kısa tut)
1. `mobile/PROJECT_STATUS.md` oku (mimari kararlar, aktif görev).
2. Yalnızca ilgili feature klasörünü ve `lib/core/` içindeki ilgili yardımcıları incele. Aynı işlev varsa yeniden kullan.
3. Tek feature ile çalış. Kapsam büyüyorsa böl ve kullanıcıya söyle.

## 2. Yapı
```
lib/features/<feature>/
  data/          # repository impl, DTO, API/local kaynak
  domain/        # entity, repository arayüzü, use-case (gerekirse)
  presentation/  # pages/, widgets/, state (controller/notifier/bloc)
lib/core/        # tema, router, l10n, ağ, ortak widget'lar
```
- Feature'lar birbirinin `presentation`/`data` katmanına doğrudan bağımlı olmaz; ortak olan `core/`a çıkar.
- DTO ↔ entity dönüşümü `data/` içinde; UI yalnızca entity görür.

## 3. Widget ayrımı
- `build()` ~80 satırı geçerse özel `StatelessWidget` sınıflarına böl (yardımcı `_buildX` metodu değil, sınıf).
- `const` constructor kullan. İş mantığı widget içinde olmasın; state katmanında olsun.
- Tekrar eden UI ikinci kez gerekirse `core/` veya feature `widgets/` içine çıkar.

## 4. State management
- Projede seçilmiş yaklaşım `PROJECT_STATUS.md` → Mimari Kararlar'da yazar; **ona uy**.
- Henüz seçilmediyse yeni paket eklemeden önce seçenekleri gerekçeyle kullanıcıya sun, onay al, kararı kaydet.
- Ekran state'ini UI'dan ayır; loading / error / empty / data durumlarının hepsini modelle.

## 5. Localization & RTL/LTR
- Kullanıcıya görünen hiçbir metin hardcode edilmez; ARB/l10n anahtarı ekle (tüm desteklenen dillere).
- Yön-bağımsız layout: `EdgeInsetsDirectional`, `AlignmentDirectional`, `start/end` (left/right değil).
- Yönlü ikonlar (geri, ileri) RTL'de aynalanmalı; Arapça metinler için uygun font/satır yüksekliği kontrol et.
- Tarih/sayı biçimleri locale'e göre.

## 6. Test
- Yeni mantık için birim test; kritik UI akışı için widget test (hem LTR hem RTL locale ile en az bir senaryo).
- Bitirmeden `flutter-quality` skill'indeki kontrolleri çalıştır.

## 7. Bitiş
- `mobile/PROJECT_STATUS.md` güncelle (tamamlananlar, kararlar, bilinen hatalar, sonraki adım).
- Yeni bağımlılık eklendiyse gerekçesini oraya yaz.
- Push yok; commit yalnızca kullanıcı isterse.
