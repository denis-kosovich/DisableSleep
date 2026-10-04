#!/bin/bash
set -e
cd "$(dirname "$0")"

swift build -c release

APP="build/DisableSleep.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/DisableSleep "$APP/Contents/MacOS/DisableSleep"
chmod +x "$APP/Contents/MacOS/DisableSleep"

echo "Built $APP"
