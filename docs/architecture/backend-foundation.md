# Backend Foundation Architecture

## Mimari stil

Backend, Clean Architecture bağımlılık yönünü koruyan modüler monolittir. Tek deploy edilebilir API ve tek PostgreSQL veritabanı vardır; modüller süreç içinde net iş sınırlarıyla ayrılır. Erken mikroservis bölünmesi, dağıtık transaction ve operasyon maliyeti bu aşamada bilinçli olarak alınmamıştır.

Bağımlılık yönü:

```text
API ───────► Application ───────► Domain
 │                 ▲
 └──────► Infrastructure ───────┘
```

- **Domain** başka projeye veya framework paketine bağlı değildir. Invariant'lar nesne oluşturulurken uygulanır.
- **Application** use case orchestration, DTO ve ihtiyaca özel portları içerir. EF Core tipi içermez.
- **Infrastructure** Application portlarını EF Core/Npgsql ile uygular. Generic repository eklenmemiştir.
- **API** composition root'tur; HTTP, DI, ProblemDetails, OpenAPI, health ve sürüm rotalarını yönetir.

## Learning Catalog sınırı

İlk çalışan modül şu aggregate/entity'leri içerir:

- `Language`: BCP-47 tarzı normalize edilen kod, görünen adlar, yazı yönü ve aktiflik.
- `LearningPath`: yönlü kaynak/hedef dil çifti. Aynı kaynak/hedef Domain ve PostgreSQL check constraint ile engellenir; yön çifti unique index ile korunur.
- `LearningProgram`: iş kodu, ad ve genişletilebilir `ProgramType` value object'i. Program türü kapalı enum değildir; yeni branşlar schema değişikliği olmadan eklenebilir.
- `Course`: bir dil yönü ile programın kesişimidir. Varsayılan durum `Draft`tır.

Okuma use case'i `ILearningCatalogRepository` adlı modüle özel portu kullanır. Her entity için generic repository veya soyut Unit of Work oluşturulmamıştır; transaction sınırı gerektiğinde EF Core `DbContext` ile Infrastructure içinde yönetilecektir.

## Planlanan modül sınırları

Bu modüller yalnızca sınır olarak tanımlıdır; henüz kaynak kodla uygulanmamıştır:

- **Identity**: hesap, authentication, authorization, roller ve güvenlik olayları.
- **Learning Catalog**: diller, yönler, programlar ve kurs metadata'sı; bu aşamada çalışan tek modül.
- **Lesson Engine**: ünite, ders, içerik akışı ve tamamlama kuralları.
- **Assessment & Scoring**: soru, sınav oturumu, cevap ve puanlama.
- **Student Progress**: kayıt, ilerleme, streak ve mastery read modelleri.
- **Dictionary & Translation**: sözlük girdileri, anlamlar, örnekler ve çeviri sağlayıcı adaptörleri.
- **AI Speaking & Reading Evaluation**: ses oturumu, değerlendirme talebi/sonucu ve dış AI adaptörleri.
- **Subscription & Billing**: plan, entitlement, abonelik ve ödeme sağlayıcı webhook'ları.
- **Media Management**: yükleme metadata'sı, erişim politikası ve object storage adaptörü.
- **Administration**: diğer modüllerin application use case'lerini yetki kontrollü biçimde çağıran operasyon yüzeyi; domain sahibi değildir.

Modüller birbirlerinin tablolarına doğrudan yazmamalıdır. İlk aşamada modül içi Application çağrıları kullanılabilir; asenkron entegrasyon ihtiyacı doğarsa domain/integration event ve outbox ayrı bir kararla eklenmelidir.

## Dil kavramları ve yerelleştirme

Üç kavram ayrı tutulur:

1. **Arayüz dili**: kullanıcının navigasyon ve sistem mesajları için seçimi; ileride profil/istemci ayarıdır.
2. **Kaynak eğitim dili**: açıklamaların ve yönlendirmelerin sunulduğu `LearningPath.SourceLanguage`.
3. **Hedef eğitim dili**: öğrenilen `LearningPath.TargetLanguage`.

`Language.Name` ve `NativeName` katalog keşfi için temel metadata'dır; tam çeviri modeli değildir. Birden fazla dilde kurs açıklaması gerektiğinde `course_localizations` benzeri, `(course_id, locale)` unique anahtarlı ayrı bir tablo eklenmelidir. Ders içerikleri Lesson Engine içinde sürümlü ve locale-aware tutulmalıdır. UI çevirileri backend kurs içeriğiyle karıştırılmamalı; istemci resource bundle'larında veya ayrı localization kaynağında yönetilmelidir.

## API ve hata sözleşmesi

- Major sürüm URL segmentindedir: `/api/v1`.
- Kırılmayan alan eklemeleri v1 içinde yapılabilir; anlam/şekil kıran değişiklik yeni `/api/v2` rotası gerektirir.
- Domain entity'leri serileştirilmez; Application DTO'ları döner.
- Async çağrılar request `CancellationToken`'ını persistence'a taşır.
- Beklenen domain ihlalleri `400`, veri çakışmaları `409`, beklenmeyen hatalar detay sızdırmadan `500` ProblemDetails döner.
- OpenAPI Development ortamında `/openapi/v1.json` üzerinden sunulur.

## Güvenlik ve operasyon

- Connection string parolası User Secrets veya environment variable üzerinden sağlanır; source control'e yazılmaz.
- Sensitive data logging etkin değildir ve PostgreSQL error detail varsayılan olarak kapalıdır.
- CORS policy eklenmemiştir. Gerçek istemci origin'leri belirlenmeden wildcard açılmamalıdır.
- Authorization servisi composition root'ta hazırdır; sahte login veya yönetici endpoint'i eklenmemiştir. Identity modülünde gerçek scheme/policy tanımlanacaktır.
- `/health` şu an process/liveness bilgisidir. Database readiness ayrı `/health/ready` endpoint'i olarak, deployment ortamı belirlendiğinde eklenmelidir.
- Production başlangıcında otomatik migration yapılmaz. `Database:ApplyMigrationsOnStartup=true` production'da açıkça reddedilir; migration release adımıyla uygulanmalıdır.

## Ölçeklenebilirlik yönü

Catalog sorguları `AsNoTracking` kullanır ve salt-okuma DTO'larına dönüştürülür. Trafik büyüdüğünde önce ölçüm yapılarak response caching, dağıtık cache ve read replica değerlendirilebilir. Stateless API yatay çoğaltılabilir. Uzun süren AI/media işleri request sürecinde çalıştırılmamalı; dayanıklı queue/worker altyapısına taşınmalıdır.
