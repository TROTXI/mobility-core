// The keypad encodes a server-side fact: which characters a boarding code can
// contain. If the generator's alphabet ever changes and this does not, a driver
// gets a keypad that cannot type the code in front of them.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_driver/Presentations/Boarding/widgets/boarding_keypad.dart';
import 'package:trotxi_driver/core/config/theme/app_theme.dart';

/// The server's `CODE_ALPHABET` from `services/api/src/modules/reservations/pin.ts`.
const serverAlphabet = '23456789ABCDEFGHJKMNPQRSTVWXYZ';

/// The characters the generator dropped because they are misread aloud or
/// mistyped off a screen.
const excluded = ['I', 'L', 'O', 'U'];

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

    test('keeps 0 and 1 for codes issued before the alphanumeric switch', () {
      // The generator stopped issuing these, but a rider holding an older
      // four-digit code still has to be able to board, and the verify endpoints
      // still accept them.
      expect(boardingKeys, containsAll(['0', '1']));
    });

    test('omits the characters people misread', () {
      for (final char in excluded) {
        expect(
          boardingKeys,
          isNot(contains(char)),
          reason: '$char is excluded from the alphabet and should not be a key',
        );
      }
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
