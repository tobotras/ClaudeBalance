#!/bin/bash
set -euo pipefail

APP_NAME="ClaudeBalance"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

cd "$(dirname "$0")"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"

# Build universal binary (Intel + Apple Silicon)
swiftc -O -target arm64-apple-macosx12.0 -o "/tmp/${APP_NAME}_arm64" Sources/main.swift -framework Cocoa -framework WebKit
swiftc -O -target x86_64-apple-macosx12.0 -o "/tmp/${APP_NAME}_x86" Sources/main.swift -framework Cocoa -framework WebKit
lipo -create "/tmp/${APP_NAME}_arm64" "/tmp/${APP_NAME}_x86" -output "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
rm "/tmp/${APP_NAME}_arm64" "/tmp/${APP_NAME}_x86"
cp Info.plist "$APP_BUNDLE/Contents/Info.plist"

echo "✔ Built $APP_BUNDLE"
echo "  Run with:  open $APP_BUNDLE"
