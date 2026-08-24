#!/bin/sh
# Xcode Cloud post-clone hook.
#
# Xcode Cloud's VM has no Flutter SDK and never runs `flutter pub get` on its
# own, so the ephemeral files Flutter normally generates under
# ios/Flutter/ephemeral (Generated.xcconfig, flutter_export_environment.sh,
# and the FlutterGeneratedPluginSwiftPackage local Swift package) don't
# exist. Xcode Cloud resolves Swift Package dependencies before running any
# build phases, so the scheme's own "Run Prepare Flutter Framework Script"
# build phase runs too late to fix this. This script installs Flutter and
# generates that iOS config up front, before package resolution happens.
set -e
set -x

FLUTTER_VERSION="3.47.1"

if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" --depth 1 "$HOME/flutter"
fi
export PATH="$PATH:$HOME/flutter/bin"

flutter --version
flutter precache --ios

cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter pub get

# Generates ios/Flutter/Generated.xcconfig, flutter_export_environment.sh,
# and ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage
# without invoking xcodebuild ourselves.
flutter build ios --release --config-only --no-codesign
