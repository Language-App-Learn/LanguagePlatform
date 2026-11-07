# ADR 0003 — Tek DbContext ve eklemeli migration

PostgreSQL 18, EF Core 10 ve Npgsql kullanılır. Tek LanguagePlatformDbContext, modül bazlı configuration sınıflarıyla genişletilir. Ortak transaction ve migration sırası için tek context seçildi; ayrı context'ler bu aşamada koordinasyon yükü getirir.

Mevcut dört katalog tablosunun konumu ve InitialLearningCatalog migration'ı korunur. Yeni UUID tablolar snake_case isimlerle aynı search-path altında eklenir. DateTime alanları UTC/timestamptz, para decimal/numeric, esnek ayarlar sürümlü jsonb'dir. İlişkiler varsayılan RESTRICT; geçmiş kayıtların ömrü ana veriden bağımsızdır. Yarışa açık aggregate'lerde PostgreSQL xmin kullanılır.

Migration production başlangıcında çalışmaz. İncelenebilir idempotent SQL deployment adımıdır. Testler ayrı language_platform_test içinde izole schema kullanır.
