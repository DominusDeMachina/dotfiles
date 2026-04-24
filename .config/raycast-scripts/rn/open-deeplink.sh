#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Open Deeplink in booted iOS Simulator
# @raycast.mode silent
# @raycast.icon 🔗
# @raycast.packageName RN
# @raycast.argument1 { "type": "text", "placeholder": "URL (e.g. myapp://path)" }

set -euo pipefail
url="$1"

if ! xcrun simctl list devices booted --json | jq -e '[.devices[][] | select(.state=="Booted")] | length > 0' >/dev/null; then
  echo "No booted simulator. Boot one first." >&2
  exit 1
fi

xcrun simctl openurl booted "$url"
echo "Opened $url"
