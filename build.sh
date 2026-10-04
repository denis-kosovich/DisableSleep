#!/bin/bash
set -e
cd "$(dirname "$0")"

swift build -c release

APP="build/DisableSleep.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/DisableSleep "$APP/Contents/MacOS/DisableSleep"
chmod +x "$APP/Contents/MacOS/DisableSleep"
cp Resources/Info.plist "$APP/Contents/Info.plist"

echo "Built $APP"

INSTALL_DIR="$HOME/Applications"
INSTALLED_APP="$INSTALL_DIR/DisableSleep.app"

mkdir -p "$INSTALL_DIR"

pkill -f "DisableSleep.app/Contents/MacOS/DisableSleep" 2>/dev/null || true

rm -rf "$INSTALLED_APP"
cp -R "$APP" "$INSTALLED_APP"

echo "Installed $INSTALLED_APP"

LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.dkosovich.disablesleep.plist"
INSTALLED_PLIST="$LAUNCH_AGENTS_DIR/$PLIST_NAME"

mkdir -p "$LAUNCH_AGENTS_DIR"
cp "Resources/$PLIST_NAME" "$INSTALLED_PLIST"

launchctl unload "$INSTALLED_PLIST" 2>/dev/null || true
launchctl load "$INSTALLED_PLIST"

echo "Installed and loaded launch agent: $INSTALLED_PLIST"

open "$INSTALLED_APP"
echo "Launched $INSTALLED_APP"
