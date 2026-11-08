# LanguagePlatform — Flutter

Çok dilli eğitim uygulaması (öğrenci uygulaması: Android + iOS). Branch: `Flutter`.

## Kapsam
- Flutter/Dart kodu **yalnızca `mobile/`** içinde yazılır.
- `backend/` ve PostgreSQL dosyalarına **dokunulmaz** (başka branch'te Codex geliştiriyor).
- Yönetici paneli bu uygulamadan ayrı geliştirilecek; öğrenci uygulamasına karıştırılmaz.

## Mimari
- Feature-first: `mobile/lib/features/<feature>/{data,domain,presentation}`, ortak kod `mobile/lib/core/`.
- Çok dilli, RTL/LTR destekli: kullanıcıya görünen metin hardcode edilmez (l10n), `Directionality`/`EdgeInsetsDirectional`/`AlignmentDirectional` kullan.
- Mimari kararlar ve ilerleme: `mobile/PROJECT_STATUS.md` (görev başında oku, önemli görev sonunda güncelle).

## Kurallar
- Aynı işlev iki kez yazılmaz; önce `core/` ve mevcut feature'lara bak.
- Yeni bağımlılık eklemeden önce gerekçe belirt, onay al; `PROJECT_STATUS.md`'ye kaydet.
- Bir seferde tek feature üzerinde çalış; yalnızca ilgili dosyaları oku.
- Test edilmeden "tamamlandı" deme: `flutter analyze` + `flutter test` (cwd: `mobile/`) temiz olmalı.
- **GitHub'a onaysız push yapma.** Commit yalnızca istenirse.

## Skill'ler
- `flutter-feature`: yeni özellik geliştirme
- `flutter-quality`: analyze/test/inceleme/performans
