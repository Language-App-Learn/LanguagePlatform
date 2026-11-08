---
name: flutter-quality
description: Use to verify or review Flutter code in mobile/ — running flutter analyze and flutter test, code review, finding duplicated code, and checking performance (rebuilds, lists, images). Trigger on "kontrol et", "analiz çalıştır", "test et", "kod incele", "tekrar eden kod", "performans", "review", or before declaring any Flutter task done.
---

# Flutter kalite kontrolü

Tüm komutlar `mobile/` dizininde çalıştırılır. Token tasarrufu için çıktıyı özetle, ama **hiçbir kontrolü atlama**.

## 1. Zorunlu kapı (her görev sonunda)
```
flutter analyze
flutter test
```
- Hata veya uyarı varsa düzelt, tekrar çalıştır. Temiz değilse "tamamlandı" deme; kalan sorunu açıkça raporla.
- Sonuç raporu: komut, geçti/kaldı, sorun sayısı + (varsa) ilk birkaç kritik satır. Ham çıktıyı yapıştırma.
- `// ignore:` ile susturmak yerine kök nedeni düzelt; ignore gerekiyorsa gerekçe yaz.
- Test için bir şey çalıştırılamadıysa (cihaz/emülatör yok vb.) bunu dürüstçe belirt.

## 2. Kod incelemesi (yalnızca değişen dosyalar)
`git diff --stat` ile kapsamı gör, sadece ilgili dosyaları oku.
- Mimari: feature sınırları, katman bağımlılık yönü (presentation → domain ← data).
- Hardcode metin / left-right kullanımı → l10n ve Directional alternatifleri.
- Hata durumları: loading/error/empty ele alınmış mı; `async` sonrası `context.mounted` kontrolü.
- Dispose edilmeyen controller/stream/subscription.
- Backend'e veya `mobile/` dışına yanlışlıkla değişiklik var mı (`git status`).

## 3. Tekrar eden kod
- Benzer sınıf/fonksiyon ara: `Grep` ile ortak imza, aynı renk/padding/stil sabitleri, kopyalanmış widget ağaçları.
- Aynı işlev ikinci kez varsa tek yere (`core/` veya ilgili feature) birleştir; çağıranları güncelle.
- Magic number ve tekrar eden stil → tema / sabit.

## 4. Performans
- `const` widget'lar; geniş `setState` / geniş rebuild alanları → state'i daraltılmış alt widget'a indir.
- Uzun listeler: `ListView.builder` / `SliverList`; `shrinkWrap` + iç içe scroll'dan kaçın.
- Görseller: boyutlandırılmış/cached; `build()` içinde pahalı hesap, nesne yaratma veya ağ çağrısı yok.
- Ağır iş UI thread'inde olmasın (`compute`/isolate); animasyonlarda gereksiz `Opacity`/`saveLayer`.
- Şüphe varsa varsayma, ölç: `flutter run --profile` + DevTools.

## 5. Güvenlik
- Gizli anahtar/token kodda veya repoda yok; yerel depolamada hassas veri için güvenli depolama.
- HTTP yerine HTTPS; kullanıcı girdisi doğrulanıyor.

## 6. Sonuç
Bulguları önem sırasıyla, dosya:satır ile kısa listele. Büyük bulgular `mobile/PROJECT_STATUS.md` → Bilinen Hatalar'a eklenir.
