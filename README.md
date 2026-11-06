# LanguagePlatform

LanguagePlatform, birden fazla kaynak/hedef dil yönünü ve farklı öğrenme programlarını desteklemek üzere tasarlanmış bir öğrenme platformudur. İlk sürüm yalnızca Android ve iOS mobil uygulaması olarak sunulacaktır. Repository, Flutter + Dart istemcisini (`mobile/`) ve ASP.NET Core 10 modüler monolit backend temelini (`backend/`) içerir. Clean Architecture ile geliştirilen backend API, PostgreSQL 18 kullanarak iki mobil platformun ortak sunucusu olacaktır.

Bu aşamada çalışan backend kapsamı yalnızca **Backend Foundation + Learning Catalog** modülüdür. Ders motoru, kimlik, ödeme, yapay zekâ, sözlük, medya ve yönetim özellikleri henüz uygulanmamıştır.

## İlk sürüm kapsamı ve öncelikler

- Mobil istemci mevcut `mobile/` Flutter + Dart projesi üzerinden Android ve iOS için geliştirilecektir; proje korunacaktır.
- Öğrenciye yönelik web frontend veya Next.js, React, Angular projesi oluşturulmayacaktır.
- Ayrı web yönetici paneli bu aşamada geliştirilmeyecektir. Ders, içerik, sınav ve öğrenci yönetimi iş akışları gelecekte bir yönetici arayüzünün yetkilendirilmiş API üzerinden kullanabileceği şekilde backend katmanlarında tasarlanacaktır.
- Çok dilli eğitim, kurs, ders ve puanlama altyapısı planlandığı şekilde devam edecektir.
- Flutter projesindeki mevcut web/masaüstü platform dosyaları korunur; bunların bulunması ilk sürüm için web veya masaüstü yayın hedefi anlamına gelmez.

Geliştirme sırası: **Backend katmanları → PostgreSQL → Eğitim kataloğu → Ders motoru → Flutter entegrasyonu**.

Backend katmanları ve katalog temeli oluşturulmuştur. Bir sonraki adım PostgreSQL 18 bağlantısının güvenli yapılandırılması, migration ve seed'in uygulanması ve gerçek veritabanı testlerinin tamamlanmasıdır. Ardından katalog API'si PostgreSQL üzerinde uçtan uca doğrulanacak; ders motoru ve Flutter entegrasyonu ayrı görevlerde geliştirilecektir. TASK 001 kapsam güncellemesi bu sonraki modüllerin uygulamasını başlatmaz.

## Backend yapısı

```text
backend/
├── LanguagePlatform.slnx
├── src/
│   ├── LanguagePlatform.Api/
│   ├── LanguagePlatform.Application/
│   ├── LanguagePlatform.Domain/
│   └── LanguagePlatform.Infrastructure/
└── tests/
    ├── LanguagePlatform.Domain.Tests/
    ├── LanguagePlatform.Application.Tests/
    └── LanguagePlatform.Api.IntegrationTests/
```

- `Domain`: Entity, value object, enum, invariant ve domain exception'ları; dış katman bağımlılığı yoktur.
- `Application`: Learning Catalog use case'i, DTO'lar ve persistence portu; yalnızca Domain'e bağlıdır.
- `Infrastructure`: EF Core, Npgsql, entity configuration, migration, idempotent seed ve persistence adaptörü.
- `Api`: `/api/v1` HTTP sözleşmesi, DI, OpenAPI, health check ve merkezi ProblemDetails hata yönetimi.

Ayrıntılı kararlar için [backend mimarisi](docs/architecture/backend-foundation.md) ve [PostgreSQL geliştirme rehberi](docs/database/postgresql.md) belgelerine bakın.

## Gereksinimler

- .NET SDK 10
- PostgreSQL 18
- EF Core CLI 10 (`dotnet tool update --global dotnet-ef --version 10.*`)

## Derleme ve test

```powershell
cd backend
dotnet restore .\LanguagePlatform.slnx
dotnet build .\LanguagePlatform.slnx -m:1 --no-restore
dotnet test .\tests\LanguagePlatform.Domain.Tests\LanguagePlatform.Domain.Tests.csproj --no-restore
dotnet test .\tests\LanguagePlatform.Application.Tests\LanguagePlatform.Application.Tests.csproj --no-restore
dotnet test .\tests\LanguagePlatform.Api.IntegrationTests\LanguagePlatform.Api.IntegrationTests.csproj --no-restore
```

PostgreSQL constraint testi yalnızca `LANGUAGEPLATFORM_TEST_CONNECTION` tanımlandığında çalışır. Bağlantı yoksa test raporunda açıkça `Skipped` görünür; API ve birim testleri çalışmaya devam eder.

## Veritabanını hazırlama

Parolayı repository'ye yazmayın. Geliştirme bağlantısını User Secrets ile ayarlayın:

```powershell
dotnet user-secrets set "ConnectionStrings:LanguagePlatform" "Host=localhost;Port=5432;Database=language_platform_dev;Username=<kullanici>;Password=<parola>;Include Error Detail=false" --project .\backend\src\LanguagePlatform.Api\LanguagePlatform.Api.csproj
```

Migration'ı açıkça uygulayın:

```powershell
cd backend
dotnet ef database update --project .\src\LanguagePlatform.Infrastructure\LanguagePlatform.Infrastructure.csproj --startup-project .\src\LanguagePlatform.Api\LanguagePlatform.Api.csproj
```

İlk geliştirme seed'i için tek seferlik çalıştırma:

```powershell
$env:Database__SeedOnStartup = "true"
dotnet run --project .\src\LanguagePlatform.Api\LanguagePlatform.Api.csproj
Remove-Item Env:Database__SeedOnStartup
```

Seed işlemi tekrar çalıştırılabilir; dil, yön ve program kayıtlarını çoğaltmaz. Hazır bir kurs bulunmadığı için seed kurs yayınlamaz.

## API'yi çalıştırma

```powershell
cd backend
dotnet run --project .\src\LanguagePlatform.Api\LanguagePlatform.Api.csproj --launch-profile http
```

Geliştirme adresleri:

- `GET http://localhost:5150/health`
- `GET http://localhost:5150/api/v1/catalog/languages`
- `GET http://localhost:5150/api/v1/catalog/learning-paths`
- `GET http://localhost:5150/api/v1/catalog/programs`
- `GET http://localhost:5150/api/v1/catalog/courses`
- `GET http://localhost:5150/openapi/v1.json` (yalnızca Development)

Katalog endpoint'leri veritabanı migration ve seed işlemleri tamamlandıktan sonra veri döndürür.
