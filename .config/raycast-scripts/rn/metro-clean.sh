#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Clean Metro + Watchman caches
# @raycast.mode fullOutput
# @raycast.icon 🧽
# @raycast.packageName RN

set -euo pipefail

echo "→ watchman watch-del-all"
watchman watch-del-all 2>&1 | head -5 || echo "(watchman not running)"

echo "→ rm -rf \$TMPDIR/metro-* \$TMPDIR/haste-map-*"
rm -rf "${TMPDIR}"metro-* "${TMPDIR}"haste-map-* 2>/dev/null || true

echo "→ rm -rf \$TMPDIR/react-native-packager-cache-*"
rm -rf "${TMPDIR}"react-native-packager-cache-* 2>/dev/null || true

echo "Done. Restart Metro: yarn start --reset-cache"
