import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:language_platform/core/design_system/widgets/async_value_view.dart';
import 'package:language_platform/core/design_system/widgets/choice_group.dart';
import 'package:language_platform/core/design_system/widgets/state_views.dart';
import 'package:language_platform/core/errors/app_exceptions.dart';
import 'package:language_platform/core/l10n/l10n.dart';

Widget _host(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLanguage.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

void main() {
  group('AsyncValueView', () {
    testWidgets('loading: yükleniyor göstergesi', (tester) async {
      await tester.pumpWidget(
        _host(
          AsyncValueView<int>(
            value: const AsyncLoading(),
            data: (d) => Text('$d'),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('error: genel mesaj ve çalışan tekrar dene', (tester) async {
      var retried = 0;
      await tester.pumpWidget(
        _host(
          AsyncValueView<int>(
            value: AsyncError(Exception('x'), StackTrace.empty),
            data: (d) => Text('$d'),
            onRetry: () => retried++,
          ),
        ),
      );
      expect(find.text('Something went wrong. Please try again.'), findsOne);
      await tester.tap(find.text('Try again'));
      expect(retried, 1);
    });

    testWidgets('error: NotFound için ayrı mesaj', (tester) async {
      await tester.pumpWidget(
        _host(
          AsyncValueView<int>(
            value: AsyncError(const NotFoundException('x'), StackTrace.empty),
            data: (d) => Text('$d'),
          ),
        ),
      );
      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.textContaining("couldn't find"), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('empty: boş veri için emptyBuilder', (tester) async {
      await tester.pumpWidget(
        _host(
          AsyncValueView<List<int>>(
            value: const AsyncData([]),
            isEmpty: (d) => d.isEmpty,
            emptyBuilder: (_) => const Text('boş'),
            data: (d) => Text('${d.length}'),
          ),
        ),
      );
      expect(find.text('boş'), findsOneWidget);
    });

    testWidgets('data: veriyi çizer', (tester) async {
      await tester.pumpWidget(
        _host(
          AsyncValueView<int>(
            value: const AsyncData(7),
            data: (d) => Text('$d'),
          ),
        ),
      );
      expect(find.text('7'), findsOneWidget);
    });
  });

  group('ChoiceGroup', () {
    for (final layout in ChoiceGroupLayout.values) {
      testWidgets('$layout: seçili görünür, devre dışı seçilemez', (
        tester,
      ) async {
        String? picked;
        await tester.pumpWidget(
          _host(
            ChoiceGroup<String>(
              groupId: 'g',
              layout: layout,
              selected: 'a',
              options: const [
                ChoiceOption(id: 'a', value: 'a', label: 'A'),
                ChoiceOption(id: 'b', value: 'b', label: 'B'),
                ChoiceOption(id: 'c', value: 'c', label: 'C', enabled: false),
              ],
              onSelected: (v) => picked = v,
            ),
          ),
        );
        await tester.tap(find.byKey(const ValueKey('g:b')));
        expect(picked, 'b');
        picked = null;
        await tester.tap(find.byKey(const ValueKey('g:c')));
        expect(picked, isNull);
      });
    }
  });
}
