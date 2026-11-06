# Başlangıç denetimi — Master Task

Başlangıç commit'i: `de86b9b`, dal `Musab`. Çalışma ağacı temizdi. Kullanıcının kalıcı dal talimatı nedeniyle bütün push işlemleri Musab'a yapılır; main ve Develop'a doğrudan push yapılmaz.

Mevcut çözüm dört kaynak ve üç test projesi içerir. Domain dış bağımlılıksız; Application → Domain; Infrastructure → Application + Domain; API → Application + Infrastructure. İlk migration `20261105101711_InitialLearningCatalog`, dört katalog tablosu public/search-path altında bulunur. Eski migration dosyaları değiştirilmeyecektir.

Başlangıç testleri: 7 Domain, 1 Application, 5 API testi ve bağlantı gerektiren 1 PostgreSQL testi. API testleri servis double'ı kullanır; bunlar gerçek veritabanı kanıtı değildir. Önceki sandbox named-pipe hataları nedeniyle yeni doğrulama gerektiğinde yetkili test süreciyle yapılır.

Tespitler: katalog sorgusu taslak kursları filtrelemiyor; tasarım zamanı bağlantı factory'si User Secrets okumuyor; seed eşzamanlı çalıştırma kilidi içermiyor; üretim hatalarında exception mesajlarının detay sızdırma ihtimali var; pagination, kimlik persistence ve diğer modül şemaları henüz yok.

Yerel PostgreSQL 18 servisi mevcut. Denetim anında proje/test bağlantı ayarları yoktu; kullanıcı bunları yerelde yapılandıracağını bildirdi. Flutter uygulaması ve platform dosyaları korunur. Yeni ana görev, eski yalnızca-mobil kapsamını yönetici panelinin mimari sözleşmesini de içerecek şekilde genişletir; öğrenci web uygulaması hâlâ kapsam dışıdır.
