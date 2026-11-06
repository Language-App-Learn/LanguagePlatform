# ADR 0001 — Modüler monolit

Durum: kabul edildi. Tek ASP.NET Core process ve PostgreSQL veritabanı korunur. Modüller veri sahipliği, Application use case'leri ve namespace'lerle ayrılır. AI/medya işleri ileride worker olabilir; bu görevde queue veya mikroservis zorunlu değildir.

Bir modülün tablosuna diğer modül denetimsiz yazmaz. Ders yayınlama ve outbox kaydı; sınav tamamlama ve sonuç kaydı aynı yerel transaction sınırındadır. Dış çağrılar transaction dışında yürütülür. Outbox teslimatı en az bir kez olacağı için tüketici idempotency şarttır.
