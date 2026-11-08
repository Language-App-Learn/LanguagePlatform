import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/design_system/widgets/content_text.dart';

void main() {
  group('Arabic typography', () {
    testWidgets(
      'Arabic gets larger size and tall line height, text untouched',
      (tester) async {
        const word = 'مَرْحَبًا'; // test input only, never shown to users
        await tester.pumpWidget(
          const MaterialApp(
            home: Column(
              children: [
                ContentText(
                  word,
                  languageCode: 'ar',
                  style: TextStyle(fontSize: 20),
                ),
                ContentText(
                  'hello',
                  languageCode: 'en',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        );
        final ar = tester.widget<Text>(find.text(word));
        expect(ar.data, word); // diacritics preserved exactly
        expect(
          ar.style!.fontSize,
          closeTo(20 * ContentText.arabicScale, 0.001),
        );
        expect(ar.style!.height, ContentText.arabicLineHeight);
        expect(ar.textDirection, TextDirection.rtl);
        final en = tester.widget<Text>(find.text('hello'));
        expect(en.style!.fontSize, 20);
        expect(en.style!.height, isNull);
        expect(en.textDirection, TextDirection.ltr);
      },
    );
  });
}
