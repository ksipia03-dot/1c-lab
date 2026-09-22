#!/usr/bin/env bash
# Upload install-1c-erp.ps1 to temporary HTTPS hosting and print the one-liner
# for PowerShell Admin on the Windows server.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PS1="${SCRIPT_DIR}/install-1c-erp.ps1"
URL_FILE="${SCRIPT_DIR}/install-url.txt"

if [[ ! -f "$INSTALL_PS1" ]]; then
  echo "Missing $INSTALL_PS1" >&2
  exit 1
fi

upload_install_script() {
  local url="" body="" tmp
  tmp="$(mktemp)"

  # litterbox.catbox.moe — raw file URL, 72h retention
  if url="$(curl -fsS --connect-timeout 20 --max-time 120 \
    -F "reqtype=fileupload" -F "time=72h" \
    -F "fileToUpload=@${INSTALL_PS1}" \
    https://litterbox.catbox.moe/resources/internals/api.php 2>"$tmp")"; then
    url="$(echo "$url" | tr -d '\r' | head -1)"
    if [[ "$url" =~ ^https?:// ]]; then
      echo "$url"
      rm -f "$tmp"
      return 0
    fi
  fi

  # tmpfiles.org
  if body="$(curl -fsS --connect-timeout 20 --max-time 120 -F "file=@${INSTALL_PS1}" https://tmpfiles.org/api/v1/upload 2>"$tmp")"; then
    url="$(python3 -c "import json,sys,re; d=json.load(sys.stdin); u=d.get('data',{}).get('url',''); m=re.search(r'tmpfiles.org/([^/]+)/', u); print(f'https://tmpfiles.org/dl/{m.group(1)}/install-1c-erp.ps1' if m else u)" <<<"$body" 2>/dev/null || true)"
    if [[ "$url" =~ ^https?:// ]]; then
      echo "$url"
      rm -f "$tmp"
      return 0
    fi
  fi

  # 0x0.st
  if body="$(curl -fsS --connect-timeout 20 --max-time 120 -F "file=@${INSTALL_PS1}" https://0x0.st 2>"$tmp")"; then
    url="$(echo "$body" | tr -d '\r' | head -1)"
    if [[ "$url" =~ ^https?:// ]]; then
      echo "$url"
      rm -f "$tmp"
      return 0
    fi
  fi

  # transfer.sh fallback
  if url="$(curl -fsS --connect-timeout 20 --max-time 120 --upload-file "$INSTALL_PS1" "https://transfer.sh/install-1c-erp.ps1" 2>"$tmp")"; then
    url="$(echo "$url" | tr -d '\r' | head -1)"
    if [[ "$url" =~ ^https?:// ]]; then
      echo "$url"
      rm -f "$tmp"
      return 0
    fi
  fi

  echo "Upload failed. Last curl stderr:" >&2
  cat "$tmp" >&2 || true
  rm -f "$tmp"
  return 1
}

echo "=== Uploading install-1c-erp.ps1 ==="
URL="$(upload_install_script)"
echo "$URL" | tee "$URL_FILE"
echo "=== Saved URL to $URL_FILE ==="
echo ""
echo "Run on Windows Server in PowerShell (Admin):"
echo ""
printf "Set-ExecutionPolicy Bypass -Scope Process -Force; iex (iwr -UseBasicParsing '%s').Content\n" "$URL"
echo ""
echo "Re-run this script after editing install-1c-erp.ps1"
