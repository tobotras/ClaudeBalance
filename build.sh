#!/bin/bash
set -euo pipefail

APP_NAME="ClaudeBalance"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

cd "$(dirname "$0")"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"

swiftc -O -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" Sources/main.swift -framework Cocoa
cp Info.plist "$APP_BUNDLE/Contents/Info.plist"

echo "✔ Built $APP_BUNDLE"
echo "  Run with:  open $APP_BUNDLE"
