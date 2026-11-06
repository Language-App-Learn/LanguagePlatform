import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Uygulama başlatma: binding, hata yakalama, Riverpod kapsamı.
///
/// Hata ayrıntıları yalnızca debug'da konsola yazılır; üretimde kullanıcı
/// verisi veya hassas içerik loglanmaz. Crash raporlama entegrasyonu
/// (varsa) buraya bağlanacak.
void bootstrap(Widget app) {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) debugPrint('FlutterError: ${details.exceptionAsString()}');
  };
  runApp(
    ProviderScope(
      // Riverpod 3 başarısız provider'ı varsayılan olarak yeniden dener.
      // Hata durumunu kullanıcıya gösterip "Tekrar dene" ile elle
      // tetiklemek istediğimiz için otomatik yeniden deneme kapalı.
      retry: (retryCount, error) => null,
      child: app,
    ),
  );
}
