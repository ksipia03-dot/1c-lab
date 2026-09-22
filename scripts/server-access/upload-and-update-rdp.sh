#!/usr/bin/env bash
# Upload bootstrap-all-in-one.ps1 to temporary HTTPS hosting and patch Desktop RDP file.
# Re-run whenever bootstrap-all-in-one.ps1 changes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_PS1="${SCRIPT_DIR}/bootstrap-all-in-one.ps1"
URL_FILE="${SCRIPT_DIR}/bootstrap-url.txt"
RDP_FILE="${RDP_FILE:-${HOME}/Desktop/ERP-Uchebny.rdp}"
HOST="${SERVER_HOST:-201.34.129.230}"
USER="${SERVER_USER:-Administrator}"

if [[ ! -f "$BOOTSTRAP_PS1" ]]; then
  echo "Missing $BOOTSTRAP_PS1" >&2
  exit 1
fi

upload_bootstrap() {
  local url="" body="" tmp
  tmp="$(mktemp)"

  # litterbox.catbox.moe — raw file URL, 72h retention
  if url="$(curl -fsS --connect-timeout 20 --max-time 120 \
    -F "reqtype=fileupload" -F "time=72h" \
    -F "fileToUpload=@${BOOTSTRAP_PS1}" \
    https://litterbox.catbox.moe/resources/internals/api.php 2>"$tmp")"; then
    url="$(echo "$url" | tr -d '\r' | head -1)"
    if [[ "$url" =~ ^https?:// ]]; then
      echo "$url"
      rm -f "$tmp"
      return 0
    fi
  fi

  # tmpfiles.org — API upload; use /dl/ URL for raw download
  if body="$(curl -fsS --connect-timeout 20 --max-time 120 -F "file=@${BOOTSTRAP_PS1}" https://tmpfiles.org/api/v1/upload 2>"$tmp")"; then
    url="$(python3 -c "import json,sys,re; d=json.load(sys.stdin); u=d.get('data',{}).get('url',''); m=re.search(r'tmpfiles.org/([^/]+)/', u); print(f'https://tmpfiles.org/dl/{m.group(1)}/bootstrap-all-in-one.ps1' if m else u)" <<<"$body" 2>/dev/null || true)"
    if [[ "$url" =~ ^https?:// ]]; then
      echo "$url"
      rm -f "$tmp"
      return 0
    fi
  fi

  # 0x0.st — returns URL on stdout
  if body="$(curl -fsS --connect-timeout 20 --max-time 120 -F "file=@${BOOTSTRAP_PS1}" https://0x0.st 2>"$tmp")"; then
    url="$(echo "$body" | tr -d '\r' | head -1)"
    if [[ "$url" =~ ^https?:// ]]; then
      echo "$url"
      rm -f "$tmp"
      return 0
    fi
  fi

  # transfer.sh fallback
  if url="$(curl -fsS --connect-timeout 20 --max-time 120 --upload-file "$BOOTSTRAP_PS1" "https://transfer.sh/bootstrap-all-in-one.ps1" 2>"$tmp")"; then
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

build_alternate_shell() {
  local url="$1"
  # Forward slashes avoid \1 \b escape corruption in .rdp / env passing.
  printf "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \"\$log='C:/1C-Lab/bootstrap.log'; New-Item -ItemType Directory -Force -Path 'C:/1C-Lab' | Out-Null; try { iex (iwr -UseBasicParsing '%s' ).Content } catch { \$_ | Out-File \$log -Append }; 'DONE' | Out-File \$log -Append\"" "$url"
}

patch_rdp_file() {
  local url="$1"
  local shell_line
  shell_line="$(build_alternate_shell "$url")"

  RDP_FILE="$RDP_FILE" HOST="$HOST" USER="$USER" SHELL_LINE="$shell_line" python3 - <<'PY'
import os
import pathlib

rdp = pathlib.Path(os.environ["RDP_FILE"])
host = os.environ["HOST"]
user = os.environ["USER"]
shell = os.environ["SHELL_LINE"]

entries = {
    "full address:s:": host,
    "username:s:": user,
    "alternate shell:s:": shell,
    "shell working directory:s:": r"C:\Windows",
    "redirectclipboard:i:": "1",
    "drivestoredirect:s:": "*",
    "screen mode id:i:": "2",
    "desktopwidth:i:": "1920",
    "desktopheight:i:": "1080",
    "authentication level:i:": "0",
    "prompt for credentials:i:": "0",
}

lines = []
if rdp.exists():
    lines = rdp.read_text(encoding="utf-8", errors="replace").splitlines()

out = []
seen = set()
for line in lines:
    matched = None
    for key in entries:
        if line.startswith(key):
            matched = key
            break
    if matched:
        if matched not in seen:
            out.append(f"{matched}{entries[matched]}")
            seen.add(matched)
        continue
    out.append(line)

for key, value in entries.items():
    if key not in seen:
        out.append(f"{key}{value}")

rdp.parent.mkdir(parents=True, exist_ok=True)
rdp.write_text("\n".join(out) + "\n", encoding="utf-8")
print(rdp)
PY
}

echo "=== Uploading bootstrap-all-in-one.ps1 ==="
URL="$(upload_bootstrap)"
echo "$URL" | tee "$URL_FILE"
echo "=== Saved URL to $URL_FILE ==="

echo "=== Patching RDP: $RDP_FILE ==="
patch_rdp_file "$URL"

echo ""
echo "Done."
echo "  Bootstrap URL: $URL"
echo "  RDP file:      $RDP_FILE"
echo "  Re-run this script after editing bootstrap-all-in-one.ps1"
