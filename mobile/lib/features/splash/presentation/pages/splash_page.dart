import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/widgets/brand_mark.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../application/startup_route.dart';

/// Marka alanı + başlangıç yönlendirmesi. Yapay bekleme yok: yönlendirme
/// kararı hazır olur olmaz geçilir.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(startupRouteProvider);
    final route = startup.asData?.value;
    if (route != null) {
      // Build sırasında gezinme yapılamaz; kare sonrasına bırak.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(route);
      });
    }
    return Scaffold(
      body: startup.hasError
          ? ErrorStateView(
              error: startup.error,
              onRetry: () => ref.invalidate(startupRouteProvider),
            )
          : const Center(child: BrandMark()),
    );
  }
}
