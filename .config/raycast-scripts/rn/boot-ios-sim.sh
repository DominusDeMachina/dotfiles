#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Boot iOS Simulator
# @raycast.mode silent
# @raycast.icon 📱
# @raycast.packageName RN
# @raycast.argument1 { "type": "text", "placeholder": "Simulator name (e.g. iPhone 15 Pro)" }

set -euo pipefail
name="$1"

udid=$(xcrun simctl list devices available --json \
  | jq -r --arg name "$name" '
      [.devices[][] | select(.name==$name)] | .[0].udid // empty
    ')

if [ -z "$udid" ]; then
  echo "No simulator named \"$name\" found" >&2
  exit 1
fi

xcrun simctl boot "$udid" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$udid"
echo "Booted $name ($udid)"
