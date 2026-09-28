import 'package:flutter_test/flutter_test.dart';
import 'package:trotxi_commuter/core/config/theme/app_theme.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

void main() {
  test('both themes render all Material text roles in bundled Poppins', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      expect(theme.useMaterial3, isTrue);
      for (final text in [theme.textTheme, theme.primaryTextTheme]) {
        for (final style in [
          text.displayLarge,
          text.displayMedium,
          text.displaySmall,
          text.headlineLarge,
          text.headlineMedium,
          text.headlineSmall,
          text.titleLarge,
          text.titleMedium,
          text.titleSmall,
          text.bodyLarge,
          text.bodyMedium,
          text.bodySmall,
          text.labelLarge,
          text.labelMedium,
          text.labelSmall,
        ]) {
          expect(style?.fontFamily, 'Poppins');
        }
      }
      expect(
        theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.fontFamily,
        'Poppins',
      );
      final colors = theme.extension<AppSemanticColors>()!;
      expect(theme.dialogTheme.backgroundColor, colors.surfaceElevated);
      expect(theme.bottomSheetTheme.backgroundColor, colors.surfaceElevated);
      expect(
        theme.listTileTheme.subtitleTextStyle?.color,
        colors.textSecondary,
      );
      expect(
        theme.textButtonTheme.style?.textStyle?.resolve({})?.fontFamily,
        'Poppins',
      );
    }
  });
}
