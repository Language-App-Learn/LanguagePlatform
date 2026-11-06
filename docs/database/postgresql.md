# PostgreSQL 18 Development Guide

## Bağlantı

Beklenen geliştirme veritabanı adı `language_platform_dev`'dir. Repository parola içermez. API aşağıdaki sırada bağlantıyı çözer:

1. `ConnectionStrings:LanguagePlatform` configuration anahtarı (User Secrets önerilir),
2. Parola içermeyen yerel geliştirme varsayılanı: host `localhost`, port `5432`, database `language_platform_dev`, user `postgres`.

Gerçek parola gereken ortamlarda User Secrets kullanın:

```powershell
dotnet user-secrets set "ConnectionStrings:LanguagePlatform" "Host=localhost;Port=5432;Database=language_platform_dev;Username=<kullanici>;Password=<parola>;Include Error Detail=false" --project .\backend\src\LanguagePlatform.Api\LanguagePlatform.Api.csproj
```

## Migration

İlk migration: `InitialLearningCatalog`.

```powershell
cd backend
dotnet ef migrations list --project .\src\LanguagePlatform.Infrastructure\LanguagePlatform.Infrastructure.csproj --startup-project .\src\LanguagePlatform.Api\LanguagePlatform.Api.csproj
dotnet ef database update --project .\src\LanguagePlatform.Infrastructure\LanguagePlatform.Infrastructure.csproj --startup-project .\src\LanguagePlatform.Api\LanguagePlatform.Api.csproj
```

`EnsureCreated()` kullanılmaz. Production'da migration uygulama başlangıcında çalıştırılmaz; onaylı release adımı olmalıdır.

## Tablolar ve kısıtlar

- `languages`: PK `id`, unique `code`, required ad/yazı yönü/aktiflik.
- `learning_paths`: kaynak ve hedef FK'leri `RESTRICT`; yön unique; kaynak/hedef farklılığı check constraint.
- `learning_programs`: unique `code`; program türü string-backed value object.
- `courses`: dil yönü ve programa `RESTRICT` FK; unique `slug`; durum string olarak saklanır.

`RESTRICT`, katalog referansı varken dil/yön/program silerek geçmiş veriyi bozmaya izin vermez. İleride fiziksel silme yerine pasifleştirme tercih edilmelidir.

## Seed

Seed verileri:

- Diller: `tr`, `ar`, `en`
- Yönler: `tr → ar`, `en → ar`, `ar → tr`
- Programlar: Modern Language, YDT, YDS, YÖKDİL, Quran Reading

Seed iş servisi mevcut business key'leri kontrol eder ve tekrar çalıştırıldığında kayıtları çoğaltmaz. Henüz hazırlanmış kurs olmadığı için `courses` boş kalır.

Migration uygulanmış geliştirme veritabanında seed çalıştırmak için:

```powershell
cd backend
$env:Database__SeedOnStartup = "true"
dotnet run --project .\src\LanguagePlatform.Api\LanguagePlatform.Api.csproj
Remove-Item Env:Database__SeedOnStartup
```

İlk yerel kurulumda migration ile seed'i opt-in birlikte çalıştırmak mümkündür:

```powershell
$env:Database__ApplyMigrationsOnStartup = "true"
$env:Database__SeedOnStartup = "true"
dotnet run --project .\src\LanguagePlatform.Api\LanguagePlatform.Api.csproj
Remove-Item Env:Database__ApplyMigrationsOnStartup
Remove-Item Env:Database__SeedOnStartup
```

Bu migration seçeneği production ortamında kod tarafından reddedilir.

## Gerçek PostgreSQL integration testi

SQLite/InMemory kullanılmaz. Test, verilen PostgreSQL test database'i içinde benzersiz bir schema oluşturur, migration uygular, unique constraint ve seed idempotency davranışını doğrular, sonra yalnızca oluşturduğu schema'yı siler.

```powershell
$env:LANGUAGEPLATFORM_TEST_CONNECTION = "Host=localhost;Port=5432;Database=language_platform_test;Username=<kullanici>;Password=<parola>;Include Error Detail=false"
dotnet test .\backend\tests\LanguagePlatform.Api.IntegrationTests\LanguagePlatform.Api.IntegrationTests.csproj
Remove-Item Env:LANGUAGEPLATFORM_TEST_CONNECTION
```

Bu değişkeni hiçbir zaman production veritabanına yönlendirmeyin. Test kullanıcısının dedicated test database'inde schema oluşturma/silme yetkisi olmalıdır.
