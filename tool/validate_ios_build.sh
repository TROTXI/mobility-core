#!/bin/sh
set -eu
export MOBILE_BUILD_RECEIPT="$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/trotxi_build.json"
export MOBILE_BUILD_NUMBER="$FLUTTER_BUILD_NUMBER"
export MOBILE_BUILD_NAME="$FLUTTER_BUILD_NAME"
"$FLUTTER_ROOT/bin/cache/dart-sdk/bin/dart" "$SRCROOT/../../../tool/validate_mobile_build.dart" "$SRCROOT/.." "$CONFIGURATION"
/bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" build
