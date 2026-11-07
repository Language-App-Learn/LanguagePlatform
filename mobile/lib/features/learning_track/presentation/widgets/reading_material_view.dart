import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/widgets/app_card.dart';
import '../../../../core/design_system/widgets/async_value_view.dart';
import '../../../../core/design_system/widgets/content_text.dart';
import '../../../../core/design_system/widgets/notice_banner.dart';
import '../../../../core/design_system/widgets/state_views.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/bidi.dart';
import '../../application/track_providers.dart';
import '../../domain/pdf_delivery.dart';
import '../../domain/remote_models.dart';

/// Teacher-approved Arabic lines of the reading stage, plus the original PDF
/// download. Lines keep the server's order, ids and every diacritic; nothing
/// is re-split on the client. When the lesson was authored as plain text the
/// caller passes that [fallbackText].
class ReadingMaterialView extends ConsumerWidget {
  const ReadingMaterialView({
    super.key,
    required this.courseId,
    required this.lessonId,
    this.fallbackText,
  });

  final String courseId;
  final String lessonId;

  /// Published Arabic stage text, used when there are no approved lines.
  final String? fallbackText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final material = ref.watch(readingMaterialProvider(lessonId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.readingMaterialTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AsyncValueView<ReadingMaterial?>(
          value: material,
          compact: true,
          onRetry: () => ref.invalidate(readingMaterialProvider(lessonId)),
          data: (m) {
            final lines = m?.lines ?? const <ReadingLine>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (lines.isNotEmpty)
                  AppCard(
                    key: const ValueKey('reading-lines'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, line) in lines.indexed)
                          Semantics(
                            label: l10n.readingLineLabel(i + 1),
                            child: Padding(
                              key: ValueKey('reading-line:${line.id}'),
                              padding: const EdgeInsetsDirectional.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: ContentText(
                                line.text,
                                languageCode: 'ar',
                                style: theme.textTheme.headlineSmall,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else if (fallbackText != null)
                  AppCard(
                    key: const ValueKey('reading-fallback'),
                    child: ContentText(
                      fallbackText!,
                      languageCode: 'ar',
                      style: theme.textTheme.headlineSmall,
                    ),
                  )
                else
                  NoticeBanner(message: l10n.readingMaterialEmpty),
                if (m?.hasOriginalPdf ?? false) ...[
                  const SizedBox(height: AppSpacing.md),
                  _PdfDownload(courseId: courseId, lessonId: lessonId),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

enum _PdfPhase { idle, downloading, delivered, unavailable }

class _PdfDownload extends ConsumerStatefulWidget {
  const _PdfDownload({required this.courseId, required this.lessonId});

  final String courseId;
  final String lessonId;

  @override
  ConsumerState<_PdfDownload> createState() => _PdfDownloadState();
}

class _PdfDownloadState extends ConsumerState<_PdfDownload> {
  _PdfPhase _phase = _PdfPhase.idle;
  Object? _error;
  int _size = 0;
  CancelToken? _token;

  @override
  void dispose() {
    _token?.cancel(); // leaving the screen abandons the download
    super.dispose();
  }

  Future<void> _download() async {
    final token = CancelToken();
    _token = token;
    setState(() {
      _phase = _PdfPhase.downloading;
      _error = null;
    });
    try {
      final bytes = await ref
          .read(fiveStageRepositoryProvider)
          .downloadReadingPdf(
            widget.courseId,
            widget.lessonId,
            cancelToken: token,
          );
      final outcome = await ref
          .read(pdfDeliveryProvider)
          .deliver(bytes, fileName: safePdfFileName(widget.lessonId));
      if (!mounted) return;
      setState(() {
        _size = bytes.length;
        _phase = outcome == PdfDeliveryOutcome.delivered
            ? _PdfPhase.delivered
            : _PdfPhase.unavailable;
      });
    } on Object catch (error) {
      if (!mounted || failureOf(error) is CancelledFailure) return;
      setState(() {
        _error = error;
        _phase = _PdfPhase.idle;
      });
    }
  }

  static String _sizeText(int bytes) => bytes < 1024 * 1024
      ? '${(bytes / 1024).ceil()} KB'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final busy = _phase == _PdfPhase.downloading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            child: NoticeBanner(
              key: const ValueKey('pdf-error'),
              message: failureOf(_error).message(l10n),
            ),
          ),
        OutlinedButton.icon(
          key: const ValueKey('pdf-download'),
          onPressed: busy ? null : _download,
          icon: busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
          label: Text(
            busy ? l10n.readingPdfDownloading : l10n.readingPdfDownload,
          ),
        ),
        if (_phase == _PdfPhase.delivered || _phase == _PdfPhase.unavailable)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
            child: NoticeBanner(
              key: const ValueKey('pdf-status'),
              message: _phase == _PdfPhase.unavailable
                  ? '${l10n.readingPdfReady(_sizeText(_size).isolateLtr)} '
                        '${l10n.readingPdfHandoffUnavailable}'
                  : l10n.readingPdfReady(_sizeText(_size).isolateLtr),
            ),
          ),
      ],
    );
  }
}
