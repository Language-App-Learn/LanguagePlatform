import 'dart:typed_data';

enum PdfDeliveryOutcome {
  /// Handed to the operating system (saved, opened or shared).
  delivered,

  /// This build has no way to save/open/share files.
  unavailable,
}

/// Hands a downloaded PDF to the operating system (open / save / share).
///
/// STATUS: needs a platform component (e.g. `path_provider` + `open_filex` /
/// `share_plus`) that is not installed - new dependencies require approval
/// (CLAUDE.md). Until then [UnavailablePdfDelivery] is used and the UI says
/// so honestly. The bytes live in memory only and are never written to a
/// shared/public location by the app.
abstract interface class PdfDelivery {
  Future<PdfDeliveryOutcome> deliver(
    Uint8List bytes, {
    required String fileName,
  });
}

class UnavailablePdfDelivery implements PdfDelivery {
  const UnavailablePdfDelivery();

  @override
  Future<PdfDeliveryOutcome> deliver(
    Uint8List bytes, {
    required String fileName,
  }) async => PdfDeliveryOutcome.unavailable;
}

/// Safe file name for a lesson PDF: only `[a-z0-9-]`, never derived from
/// server-provided names (no path separators, no traversal).
String safePdfFileName(String lessonId) {
  final cleaned = lessonId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  final stem = cleaned.isEmpty
      ? 'reading'
      : cleaned.substring(0, cleaned.length < 12 ? cleaned.length : 12);
  return 'lesson-$stem.pdf';
}
