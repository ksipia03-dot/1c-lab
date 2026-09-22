#!/usr/bin/env bash
# Pack server-access files into a zip for ONEC_LAB_SETUP_URL (Tier A hosting bundle).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${1:-$SCRIPT_DIR/1c-lab-setup-bundle.zip}"

cd "$SCRIPT_DIR"
rm -f "$OUT"
zip -j "$OUT" \
  setup-server.ps1 \
  bootstrap-auto.bat \
  authorized_key.pub \
  RUN-ME-FIRST.bat

echo "Created: $OUT"
echo "Upload to HTTPS (GitHub release, S3, etc.) and set ONEC_LAB_SETUP_URL to the raw URL."
