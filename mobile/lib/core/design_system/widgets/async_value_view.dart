import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state_views.dart';

/// `AsyncValue` için tutarlı loading / error(+retry) / empty / data görünümü.
///
/// [compact] `true` ise kaydırılan listelerin içinde güvenle kullanılır
/// (sınırsız yükseklikte kendi kaydırıcısını açmaz).
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.isEmpty,
    this.emptyBuilder,
    this.compact = false,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  /// Veri boşsa [emptyBuilder] gösterilir.
  final bool Function(T data)? isEmpty;
  final WidgetBuilder? emptyBuilder;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: true,
      loading: () => compact ? const InlineLoading() : const LoadingView(),
      error: (error, _) => compact
          ? InlineErrorCard(error: error, onRetry: onRetry)
          : ErrorStateView(error: error, onRetry: onRetry),
      data: (value) {
        if (emptyBuilder != null && (isEmpty?.call(value) ?? false)) {
          return emptyBuilder!(context);
        }
        return data(value);
      },
    );
  }
}
