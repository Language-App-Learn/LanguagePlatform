import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/features/learning_track/data/share_pdf_delivery.dart';
import 'package:language_platform/features/learning_track/domain/pdf_delivery.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  late Directory cache;
  late List<ShareParams> shared;
  late ShareResultStatus status;

  setUp(() async {
    cache = await Directory.systemTemp.createTemp('lp_pdf_test_');
    shared = [];
    status = ShareResultStatus.success;
  });

  tearDown(() async {
    if (await cache.exists()) await cache.delete(recursive: true);
  });

  SharePdfDelivery delivery() => SharePdfDelivery(
    cacheDirectory: () async => cache,
    share: (p) async {
      shared.add(p);
      return ShareResult('test', status);
    },
  );

  final pdf = Uint8List.fromList('%PDF-1.4 test'.codeUnits);

  test(
    'writes to the private cache and shares it as application/pdf',
    () async {
      final outcome = await delivery().deliver(pdf, fileName: 'lesson-abc.pdf');
      expect(outcome, PdfDeliveryOutcome.delivered);
      final p = shared.single;
      expect(p.files, hasLength(1));
      final path = p.files!.single.path;
      expect(path, startsWith(cache.path)); // never outside the cache
      expect(path, endsWith('lesson-abc.pdf'));
      expect(p.files!.single.mimeType, 'application/pdf');
      expect(p.fileNameOverrides, ['lesson-abc.pdf']);
      expect(await File(path).readAsBytes(), pdf);
      // Only the file: no text/uri that could carry the lesson content.
      expect(p.text, isNull);
      expect(p.uri, isNull);
    },
  );

  test('a platform without a share sheet reports unavailable', () async {
    status = ShareResultStatus.unavailable;
    expect(
      await delivery().deliver(pdf, fileName: 'lesson-abc.pdf'),
      PdfDeliveryOutcome.unavailable,
    );
  });

  test('a dismissed share sheet is still a normal outcome', () async {
    status = ShareResultStatus.dismissed;
    expect(
      await delivery().deliver(pdf, fileName: 'lesson-abc.pdf'),
      PdfDeliveryOutcome.delivered,
    );
  });

  test('earlier PDFs are purged before the next share', () async {
    final d = delivery();
    await d.deliver(pdf, fileName: 'lesson-one.pdf');
    final first = shared.single.files!.single.path;
    await d.deliver(pdf, fileName: 'lesson-two.pdf');
    expect(await File(first).exists(), isFalse);
    expect(await File(shared.last.files!.single.path).exists(), isTrue);
  });

  test(
    'purgeStale removes everything the app shared (e.g. on logout)',
    () async {
      final d = delivery();
      await d.deliver(pdf, fileName: 'lesson-one.pdf');
      await d.purgeStale();
      expect(await File(shared.single.files!.single.path).exists(), isFalse);
      await d.purgeStale(); // idempotent
    },
  );

  test('a failing share surfaces to the caller', () async {
    final d = SharePdfDelivery(
      cacheDirectory: () async => cache,
      share: (_) async => throw StateError('no handler'),
    );
    await expectLater(
      d.deliver(pdf, fileName: 'lesson-abc.pdf'),
      throwsStateError,
    );
  });
}
