#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_DATA="$SCRIPT_DIR/gitea-data"
EXTERNAL_TARGET="/Volumes/Expansion/var/opt/gitea/data"

if [ ! -d "$LOCAL_DATA" ]; then
  echo "Error: Local Gitea data not found at $LOCAL_DATA"
  exit 1
fi

if [ ! -d "/Volumes/Expansion" ]; then
  echo "External disk not mounted at /Volumes/Expansion — skipping backup."
  exit 0
fi

mkdir -p "$EXTERNAL_TARGET"

echo "Syncing Gitea data to external disk..."
rsync -a --delete "$LOCAL_DATA/" "$EXTERNAL_TARGET/"
echo "Backup complete: $LOCAL_DATA -> $EXTERNAL_TARGET"
