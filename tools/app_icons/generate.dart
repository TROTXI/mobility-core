import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

// Run from this directory: dart pub get && dart run generate.dart
// Existing brand artwork is the source of truth. Never redraw or recolour it.
final root = Directory.fromUri(Platform.script.resolve('../../')).path;

img.Image mark(String app) {
  final commuter = app == 'trotxi_commuter';
  final path = commuter
      ? 'apps/ops/public/email/trotxi-logo-white.png'
      : 'apps/$app/assets/brand/trotxi-wordmark-light.png';
  final source = img.decodePng(File('$root/$path').readAsBytesSync())!;
  if (source.width != (commuter ? 420 : 568) ||
      source.height != (commuter ? 171 : 208)) {
    throw StateError(
      'Brand asset changed: review the mark extraction for $path',
    );
  }
  final glyph = img.copyCrop(
    source,
    x: 0,
    y: 0,
    width: commuter ? 159 : 200,
    height: commuter ? 171 : 208,
  );
  // The wordmark's r starts below the arrow and beside the T stem. Exclude
  // that separate letter, retaining the complete existing T/arrow silhouette.
  for (final pixel in glyph) {
    if (pixel.x >= (commuter ? 112 : 138) && pixel.y >= (commuter ? 65 : 82)) {
      pixel.a = 0;
    }
  }
  return glyph;
}

img.Image icon(
  img.Image glyph,
  int size,
  double occupancy, {
  required img.Color background,
  bool transparent = false,
  bool monochrome = false,
}) {
  final output = img.Image(
    width: size,
    height: size,
    numChannels: transparent ? 4 : 3,
  );
  img.fill(
    output,
    color: transparent ? img.ColorRgba8(0, 0, 0, 0) : background,
  );
  final scale = size * occupancy / math.max(glyph.width, glyph.height);
  final resized = img.copyResize(
    glyph,
    width: (glyph.width * scale).round(),
    height: (glyph.height * scale).round(),
    interpolation: img.Interpolation.cubic,
  );
  if (monochrome) {
    for (final pixel in resized) {
      pixel.r = pixel.g = pixel.b = 255;
    }
  }
  img.compositeImage(
    output,
    resized,
    dstX: (size - resized.width) ~/ 2,
    dstY: (size - resized.height) ~/ 2,
  );
  return output;
}

int written = 0;
void save(String path, img.Image image, {bool opaque = false}) {
  final file = File('$root/$path');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(img.encodePng(image));
  final decoded = img.decodePng(file.readAsBytesSync())!;
  if (decoded.width != image.width ||
      decoded.height != image.height ||
      (opaque && decoded.hasAlpha)) {
    throw StateError('Invalid icon output: $path');
  }
  written++;
}

void main() {
  for (final app in ['trotxi_commuter', 'trotxi_driver']) {
    final glyph = mark(app);
    img.Image render(
      int size,
      double occupancy, {
      bool transparent = false,
      bool monochrome = false,
    }) => icon(
      glyph,
      size,
      occupancy,
      background: app == 'trotxi_commuter'
          ? img.ColorRgb8(0, 26, 48)
          : img.ColorRgb8(255, 255, 255),
      transparent: transparent,
      monochrome: monochrome,
    );
    final base = 'apps/$app';
    final ios = '$base/ios/Runner/Assets.xcassets/AppIcon.appiconset';
    final catalog =
        jsonDecode(File('$root/$ios/Contents.json').readAsStringSync()) as Map;
    for (final entry in catalog['images'] as List) {
      final size =
          (double.parse((entry['size'] as String).split('x').first) *
                  double.parse((entry['scale'] as String).replaceAll('x', '')))
              .round();
      save('$ios/${entry['filename']}', render(size, .62), opaque: true);
    }
    for (final density in {
      'mdpi': 1.0,
      'hdpi': 1.5,
      'xhdpi': 2.0,
      'xxhdpi': 3.0,
      'xxxhdpi': 4.0,
    }.entries) {
      final res = '$base/android/app/src/main/res/mipmap-${density.key}';
      save(
        '$res/ic_launcher.png',
        render((48 * density.value).round(), .62),
        opaque: true,
      );
      // 43% fits inside the central 66dp safe circle on a 108dp layer.
      save(
        '$res/ic_launcher_foreground.png',
        render((108 * density.value).round(), .43, transparent: true),
      );
      save(
        '$res/ic_launcher_monochrome.png',
        render(
          (108 * density.value).round(),
          .43,
          transparent: true,
          monochrome: true,
        ),
      );
    }
    for (final size in [192, 512]) {
      save('$base/web/icons/Icon-$size.png', render(size, .62), opaque: true);
      save(
        '$base/web/icons/Icon-maskable-$size.png',
        render(size, .54),
        opaque: true,
      );
    }
    save('$base/web/favicon.png', render(32, .72), opaque: true);
  }
  stdout.writeln('Generated and checked $written Trotxi icon assets.');
}
