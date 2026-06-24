#!/usr/bin/env bash
# Snapshot selected macOS preference domains to packages/macos/ for backup.
# Complements the curated macos-defaults.sh with a raw export of app prefs.
# Run: bash scripts/macos-export-domains.sh
set -euo pipefail
[[ "$(uname)" == "Darwin" ]] || { echo "macOS only"; exit 0; }

OUT="$(cd "$(dirname "$0")/.." && pwd)/packages/macos"
mkdir -p "$OUT"

# Add domains you care about. List all with: defaults domains | tr ',' '\n'
DOMAINS=(
  com.apple.finder
  com.apple.dock
  com.apple.screencapture
  com.apple.Terminal
  NSGlobalDomain
)

for d in "${DOMAINS[@]}"; do
  echo "==> exporting $d"
  defaults export "$d" "$OUT/${d}.plist" 2>/dev/null || echo "  (no prefs for $d)"
done

echo "Exported to $OUT"
echo "Restore a domain with: defaults import <domain> packages/macos/<domain>.plist"
