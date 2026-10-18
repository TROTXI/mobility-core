# Trotxi app icons

Regenerate from the repository artwork, without Flutter or an app build:

```sh
cd tools/app_icons
dart pub get
dart run generate.dart
```

The commuter uses the green/white T-arrow from
`apps/ops/public/email/trotxi-logo-white.png` on navy. This export is larger than
the commuter's small light wordmark. The driver uses the blue/navy T-arrow from
`apps/trotxi_driver/assets/brand/trotxi-wordmark-light.png` on white.
The extraction excludes adjacent lettering without changing either brand mark.
Source dimensions are checked so a replacement wordmark requires a deliberate
review of the extraction coordinates.

Outputs are committed, so normal builds require no icon-generation step:

- Every size named in each iOS AppIcon catalog, including the opaque 1024px store icon.
- Android legacy launcher images at all five densities.
- Android adaptive foregrounds with the mark inside the central safe circle.
- Android 13 themed-icon masks derived from the mark's alpha channel.
- Web favicons, regular PWA icons and maskable icons.

The generator decodes every output to check its dimensions and checks that
opaque outputs have no alpha channel. Inspect the generated icons after any
artwork change, particularly at small sizes and under launcher masks. The source
art is raster, so a future vector brand master would improve store-size edges.

No source logo, splash screen, runtime theme or app identifier is changed.
Rebuild and reinstall the apps to see the icons on a device; launchers can cache
old icons across hot reloads.
