#!/usr/bin/env bash
# Bootstrap Windows via FreeRDP alternate shell + HTTPS bootstrap script (Mac, headless-friendly).
# Requires: brew install freerdp; run upload-and-update-rdp.sh first to publish bootstrap URL.
set -euo pipefail

HOST="${SERVER_HOST:-201.34.129.230}"
USER="${SERVER_USER:-Administrator}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDS_FILE="${CREDS_FILE:-$SCRIPT_DIR/../../.cursor/workspace/active/orch-2026-08-21-11-34-1c-erp-setup/server-credentials.local.json}"
URL_FILE="${URL_FILE:-$SCRIPT_DIR/bootstrap-url.txt}"
ARGS_FILE="${TMPDIR:-/tmp}/freerdp-bootstrap-args.txt"
LOG="${LOG:-$SCRIPT_DIR/freerdp-bootstrap.log}"
TIMEOUT_SEC="${FREERDP_TIMEOUT_SEC:-180}"

pick_freerdp() {
  if [[ -n "${FREERDP:-}" && -x "${FREERDP}" ]]; then
    echo "${FREERDP}"
    return
  fi
  local brew_bin="${HOME}/.homebrew/bin"
  for candidate in "${brew_bin}/sfreerdp" "${brew_bin}/wfreerdp" "${brew_bin}/sdl-freerdp" "${brew_bin}/xfreerdp"; do
    if [[ -x "${candidate}" ]]; then
      if [[ "${candidate##*/}" == "xfreerdp" && -z "${DISPLAY:-}" ]]; then
        continue
      fi
      echo "${candidate}"
      return
    fi
  done
  if [[ -x /opt/homebrew/bin/sfreerdp ]]; then
    echo /opt/homebrew/bin/sfreerdp
    return
  fi
  return 1
}

FREERDP="$(pick_freerdp)" || {
  echo "Install FreeRDP: ~/.homebrew then brew install freerdp" >&2
  exit 1
}

if [[ -z "${BOOTSTRAP_URL:-}" && -f "$URL_FILE" ]]; then
  BOOTSTRAP_URL="$(tr -d '\r\n' < "$URL_FILE")"
fi
if [[ -z "${BOOTSTRAP_URL:-}" ]]; then
  echo "Run upload-and-update-rdp.sh first (or set BOOTSTRAP_URL)" >&2
  exit 1
fi

if [[ -z "${SERVER_PASSWORD:-}" && -f "$CREDS_FILE" ]]; then
  SERVER_PASSWORD="$(python3 -c "import json; print(json.load(open('$CREDS_FILE'))['server']['password'])")"
fi
if [[ -z "${SERVER_PASSWORD:-}" ]]; then
  echo "Set SERVER_PASSWORD or CREDS_FILE" >&2
  exit 1
fi

SHELL_CMD="powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \"\$log='C:/1C-Lab/bootstrap.log'; New-Item -ItemType Directory -Force -Path 'C:/1C-Lab' | Out-Null; try { iex (iwr -UseBasicParsing '${BOOTSTRAP_URL}' ).Content } catch { \$_ | Out-File \$log -Append }; 'DONE' | Out-File \$log -Append\""

cat > "$ARGS_FILE" <<EOF
/v:${HOST}
/u:${USER}
/p:${SERVER_PASSWORD}
/cert:ignore
/timeout:120000
/shell:${SHELL_CMD}
EOF

echo "=== $(date -Iseconds) freerdp bootstrap (${FREERDP##*/}) -> ${USER}@${HOST} timeout=${TIMEOUT_SEC}s ===" | tee -a "$LOG"
echo "=== bootstrap URL: ${BOOTSTRAP_URL} ===" | tee -a "$LOG"
set +e
perl -e 'alarm shift; exec @ARGV' "$TIMEOUT_SEC" "$FREERDP" /args-from:file:"$ARGS_FILE" 2>&1 | tee -a "$LOG"
EC=${PIPESTATUS[0]}
set -e
if [[ "$EC" -eq 142 ]]; then
  echo "=== timed out after ${TIMEOUT_SEC}s (SIGALRM) $(date -Iseconds) ===" | tee -a "$LOG"
  EC=124
fi
echo "=== exit=${EC} $(date -Iseconds) ===" | tee -a "$LOG"
exit "$EC"
