import 'package:flutter/material.dart';

import '../../error/app_exceptions.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_tokens.dart';

/// Ortalanmış ikon + başlık + mesaj + isteğe bağlı eylem düzeni.
class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.page,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: AppSizes.iconXl,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: context.l10n.loadingLabel,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      icon: icon,
      title: title,
      message: message,
      action: actionLabel != null && onAction != null
          ? OutlinedButton(onPressed: onAction, child: Text(actionLabel!))
          : null,
    );
  }
}

/// Kaydırılan listelerin içinde kullanılan kompakt yükleme göstergesi.
class InlineLoading extends StatelessWidget {
  const InlineLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.all(AppSpacing.xl),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Kaydırılan listelerin içinde kullanılan kompakt hata kartı + tekrar dene.
class InlineErrorCard extends StatelessWidget {
  const InlineErrorCard({super.key, this.error, this.onRetry});

  final Object? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                error is NotFoundException
                    ? l10n.errorNotFound
                    : l10n.errorGeneric,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, this.error, this.onRetry});

  final Object? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notFound = error is NotFoundException;
    return _StateLayout(
      icon: notFound ? Icons.search_off : Icons.error_outline,
      title: notFound ? l10n.errorNotFound : l10n.errorGeneric,
      action: onRetry == null
          ? null
          : FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
    );
  }
}
