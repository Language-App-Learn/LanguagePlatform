# ADR 0005 — Yayınlanmış sürümü sabitleme

Lesson kimliği kalıcıdır; LessonVersion ve alt aşamalar içerik snapshot'ını oluşturur. Taslak → inceleme → yayın akışı backend'de doğrulanır. Yayındaki sürüm ve alt içerik değişmez; düzeltme yeni sürüm gerektirir. Öğrenci ilerlemesi, aşama ve sınav denemeleri kullandıkları sürüm/snapshot'a bağlı kalır.

Aktif aşama ağırlıkları yayında tam 100 olmalıdır. Eksik aşama puanı sıfırdır. Zorunlu aşamaların tamamlanması ve minimum puanları, toplam puandan bağımsız geçiş koşuludur. En iyi veya son deneme seçimi sürümün politikasına bağlıdır. SQL ve uygulama kontrolleri birlikte kullanılır.
