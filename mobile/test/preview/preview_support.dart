// Shared helpers of the design-preview renderers (skipped in normal runs).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads real fonts so previews show the true glyphs: Segoe UI (covers
/// Turkish and Arabic) for text and the Material icon font.
Future<void> loadPreviewFonts() async {
  const files = ['segoeui.ttf', 'seguisb.ttf', 'segoeuib.ttf'];
  final loader = FontLoader('Roboto');
  for (final name in files) {
    final file = File('C:/Windows/Fonts/$name');
    if (file.existsSync()) {
      loader.addFont(file.readAsBytes().then((b) => ByteData.sublistView(b)));
    }
  }
  await loader.load();

  // Material icons (the test environment does not load them on its own).
  final root = Platform.environment['FLUTTER_ROOT'] ?? 'D:/flutter';
  final icons = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(icons.readAsBytes().then((b) => ByteData.sublistView(b)));
    await iconLoader.load();
  }
}

/// A 390 x 844 phone at 3x.
void usePreviewPhone(WidgetTester tester, {double height = 844}) {
  tester.view.physicalSize = Size(1170, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Real, blurred shadows like on a device. The test binding disables them at
/// the start of each test and checks that they are disabled again at the end,
/// so the flag is flipped only around the capture.
Future<void> withRealShadows(Future<void> Function() body) async {
  debugDisableShadows = false;
  try {
    await body();
  } finally {
    debugDisableShadows = true;
  }
}
