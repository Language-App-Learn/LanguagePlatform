# ADR 0005 — Yayınlanmış sürümü sabitleme

Lesson kimliği kalıcıdır; LessonVersion ve alt aşamalar içerik snapshot'ını oluşturur. Taslak → inceleme → yayın akışı backend'de doğrulanır. Yayındaki sürüm ve alt içerik değişmez; düzeltme yeni sürüm gerektirir. Öğrenci ilerlemesi, aşama ve sınav denemeleri kullandıkları sürüm/snapshot'a bağlı kalır.

Aktif aşama ağırlıkları yayında tam 100 olmalıdır. Eski sürümlerde eksik aşama sıfır puan olarak işlenir ve tanımlanmış aşama minimumları uygulanır. Beş aşamalı Türkçe → Arapça sürümünde her aşama puanlanana kadar nihai sonuç boş kalır. Sürümde onaylanan ağırlıklar ve 60/100 ders eşiği uygulanır. En iyi veya son deneme seçimi sürümün politikasına bağlıdır. SQL ve uygulama kontrolleri birlikte kullanılır.

Beş aşamalı ders yayınında değerlendirmeler, denetim ve outbox tek veritabanı işleminde kaydedilir. Öğretmen PDF yüklemesi ve onaylı satırlar ders sürümüne bağlıdır. Taslağa yükleme veya onay yapıldığında sürümün `xmin` değeri ilerler. Ders incelemeye geçtiğinde bu içerik sabitlenir.

Etkileşimli okumada referans sesi onaylanmış satırla birlikte sürümlenir. Öğrencinin satır ilerlemesi aynı sürümdeki satıra bağlıdır ve ders puanına ayrı bir katkı yapmaz. Bir öğrenci ve satır için aynı anda yalnızca bir bekleyen ya da onaylanmış deneme bulunabilir. Yerel konuşma servisi çağrısı veritabanı işlemi dışında çalışır. Satırı açan karar ASP.NET Core tarafında kaydedilir. Otomatik onay üretim verisiyle kalibrasyon yapılana kadar varsayılan olarak kapalıdır.
