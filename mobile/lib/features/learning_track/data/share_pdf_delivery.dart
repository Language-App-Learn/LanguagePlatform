import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/pdf_delivery.dart';

/// Hands a downloaded reading PDF to the operating system share sheet
/// (open in a viewer, save to Files / Drive, print, send).
///
/// Privacy rules:
/// * the file is written ONLY to the app-private cache directory, never to
///   shared or public storage;
/// * the name is derived by the app (`safePdfFileName`), never taken from the
///   server;
/// * files from earlier shares are purged before each new one and on demand
///   ([purgeStale]) - not deleted right after the share call, because the
///   receiving app may still be reading it;
/// * the bytes and their location are never logged.
class SharePdfDelivery implements PdfDelivery {
  SharePdfDelivery({
    Future<Directory> Function()? cacheDirectory,
    Future<ShareResult> Function(ShareParams params)? share,
  }) : _cacheDirectory = cacheDirectory ?? getTemporaryDirectory,
       _share = share ?? SharePlus.instance.share;

  final Future<Directory> Function() _cacheDirectory;
  final Future<ShareResult> Function(ShareParams params) _share;

  static const _folder = 'shared_reading_pdfs';

  Future<Directory> _folderDir() async {
    final base = await _cacheDirectory();
    return Directory('${base.path}${Platform.pathSeparator}$_folder');
  }

  /// Removes PDFs left by earlier shares.
  Future<void> purgeStale() async {
    final dir = await _folderDir();
    if (await dir.exists()) {
      try {
        await dir.delete(recursive: true);
      } on FileSystemException {
        // Best effort: the OS also clears the cache directory.
      }
    }
  }

  @override
  Future<PdfDeliveryOutcome> deliver(
    Uint8List bytes, {
    required String fileName,
  }) async {
    await purgeStale();
    final dir = await _folderDir();
    await dir.create(recursive: true);
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    final result = await _share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        fileNameOverrides: [fileName],
      ),
    );
    return result.status == ShareResultStatus.unavailable
        ? PdfDeliveryOutcome.unavailable
        : PdfDeliveryOutcome.delivered;
  }
}
