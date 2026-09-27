// The keypad encodes a server-side fact: which characters a boarding code can
// contain. If the generator's alphabet ever changes and this does not, a driver
// gets a keypad that cannot type the code in front of them.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/Presentations/Boarding/widgets/boarding_keypad.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';

// Read the replacement generator, not the retired service's alphabet. If its
// declaration changes shape this fails rather than silently checking a copy.
final serverAlphabet = RegExp(r"const alphabet = '([^']+)';")
    .firstMatch(
      File('../../services/api-next/src/boarding/proofs.ts').readAsStringSync(),
    )!
    .group(1)!;

void main() {
  group('the key set', () {
    test('can type every code the server can issue', () {
      for (final char in serverAlphabet.split('')) {
        expect(
          boardingKeys,
          contains(char),
          reason: 'the server can issue $char and the keypad cannot type it',
        );
      }
    });

    test('offers exactly the replacement alphabet, including I L O U', () {
      expect(serverAlphabet.length, 32);
      expect(boardingKeys.toSet(), serverAlphabet.split('').toSet());
      expect(boardingKeys, containsAll(['I', 'L', 'O', 'U']));
    });

    test('has no duplicates', () {
      expect(boardingKeys.toSet().length, boardingKeys.length);
    });
  });

  group('the keypad widget', () {
    /// Pump a keypad and hand back what it reported.
    ///
    /// @param tester - the widget tester.
    /// @param canSubmit - whether four characters are entered.
    /// @param pressed - collects the keys tapped.
    /// @returns nothing; assertions run against [pressed].
    Future<void> pump(
      WidgetTester tester, {
      required bool canSubmit,
      required List<String> pressed,
      VoidCallback? onSubmit,
      VoidCallback? onClear,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: BoardingKeypad(
                onKey: pressed.add,
                onClear: onClear ?? () {},
                onSubmit: onSubmit ?? () {},
                canSubmit: canSubmit,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('reports the character that was pressed', (tester) async {
      final pressed = <String>[];
      await pump(tester, canSubmit: false, pressed: pressed);

      await tester.tap(find.widgetWithText(InkWell, 'K').first);
      await tester.tap(find.widgetWithText(InkWell, '7').first);

      expect(pressed, ['K', '7']);
    });

    testWidgets(
      'every issued character is rendered and tappable, including final row',
      (tester) async {
        final pressed = <String>[];
        await pump(tester, canSubmit: false, pressed: pressed);
        for (final char in serverAlphabet.split('')) {
          final key = find.widgetWithText(InkWell, char).first;
          await tester.ensureVisible(key);
          await tester.tap(key);
        }
        expect(pressed.join(), serverAlphabet);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('will not board until four characters are in', (tester) async {
      var boarded = false;
      await pump(
        tester,
        canSubmit: false,
        pressed: [],
        onSubmit: () => boarded = true,
      );

      await tester.tap(find.text('BOARD'));
      expect(boarded, isFalse);
    });

    testWidgets('boards once four characters are in', (tester) async {
      var boarded = false;
      await pump(
        tester,
        canSubmit: true,
        pressed: [],
        onSubmit: () => boarded = true,
      );

      await tester.tap(find.text('BOARD'));
      expect(boarded, isTrue);
    });

    testWidgets('clears whatever has been keyed', (tester) async {
      var cleared = false;
      await pump(
        tester,
        canSubmit: false,
        pressed: [],
        onClear: () => cleared = true,
      );

      await tester.tap(find.text('CLEAR'));
      expect(cleared, isTrue);
    });

    testWidgets('goes dead while a boarding is in flight', (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: BoardingKeypad(
                onKey: pressed.add,
                onClear: () {},
                onSubmit: () {},
                canSubmit: true,
                enabled: false,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(InkWell, 'B').first);
      // A second tap while the first is still going would board twice.
      expect(pressed, isEmpty);
    });
  });

  group('the entry display', () {
    /// Pump a display over a code.
    ///
    /// @param tester - the widget tester.
    /// @param code - what has been keyed.
    Future<void> pumpDisplay(WidgetTester tester, String code) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: BoardingCodeDisplay(code: code)),
        ),
      );
    }

    testWidgets('shows four dots before anything is keyed', (tester) async {
      await pumpDisplay(tester, '');
      expect(find.text('•   •   •   •'), findsOneWidget);
    });

    testWidgets('fills in as the driver keys, the file’s "B 7 • •"', (
      tester,
    ) async {
      await pumpDisplay(tester, 'B7');
      expect(find.text('B   7   •   •'), findsOneWidget);
    });

    testWidgets('shows all four when the code is complete', (tester) async {
      await pumpDisplay(tester, 'B7K9');
      expect(find.text('B   7   K   9'), findsOneWidget);
    });
  });
}
