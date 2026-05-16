#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Claude Status Bar"
BUNDLE_ID="com.robbertvancaem.claude-status-bar"
APP_DIR="/Applications/${APP_NAME}.app"

echo "Building..."
cd "$SCRIPT_DIR"
swift build -c release 2>&1

BINARY="$(swift build -c release --show-bin-path)/ClaudeStatusBar"

if [ ! -d "$APP_DIR" ]; then
    echo "Creating app bundle..."
    mkdir -p "$APP_DIR/Contents/MacOS"
    mkdir -p "$APP_DIR/Contents/Resources"

    cat > "$APP_DIR/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ClaudeStatusBar</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST
fi

cp "$BINARY" "$APP_DIR/Contents/MacOS/ClaudeStatusBar"

echo "Re-signing bundle..."
codesign --force --sign - "$APP_DIR"

echo "Done! App at: $APP_DIR"
echo "Run: open '$APP_DIR'"
