#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Erase booted iOS Simulator
# @raycast.mode fullOutput
# @raycast.icon 🧹
# @raycast.packageName RN

set -euo pipefail

booted_udid=$(xcrun simctl list devices booted --json \
  | jq -r '[.devices[][] | select(.state=="Booted")] | .[0].udid // empty')

if [ -z "$booted_udid" ]; then
  echo "No booted simulator. Boot one first."
  exit 1
fi

name=$(xcrun simctl list devices --json \
  | jq -r --arg u "$booted_udid" '[.devices[][] | select(.udid==$u)] | .[0].name')

xcrun simctl shutdown "$booted_udid"
xcrun simctl erase "$booted_udid"
xcrun simctl boot "$booted_udid"

echo "Erased and re-booted: $name ($booted_udid)"
