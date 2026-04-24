#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Tail Android logcat (filtered by package)
# @raycast.mode fullOutput
# @raycast.icon 🤖
# @raycast.packageName RN
# @raycast.argument1 { "type": "text", "placeholder": "Android package (e.g. com.flexinvest)" }

set -euo pipefail
pkg="$1"

if ! adb get-state >/dev/null 2>&1; then
  echo "No Android device/emulator. Start one first." >&2
  exit 1
fi

pid=$(adb shell pidof "$pkg" 2>/dev/null | tr -d '\r' | head -c 20 || true)

if [ -z "$pid" ]; then
  echo "Package $pkg not running. Tailing logcat filtered by tag only."
  adb logcat "$pkg:V" "*:S"
else
  echo "Tailing logcat for $pkg (pid $pid). Ctrl-C to stop."
  adb logcat --pid="$pid"
fi
