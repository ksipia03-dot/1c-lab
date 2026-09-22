#!/usr/bin/env bash
# Zero-touch bootstrap: probe Windows admin channels, loop until SSH works, auto-fallback to FreeRDP.
# Credentials: SERVER_PASSWORD or CREDS_FILE (never commit passwords).
#
# Usage:
#   ./remote-probe-and-bootstrap.sh           # loop until SSH OK or max attempts
#   ./remote-probe-and-bootstrap.sh --once    # single probe, exit
#   INTERVAL=30 MAX_ATTEMPTS=120 ./remote-probe-and-bootstrap.sh
set -euo pipefail

HOST="${SERVER_HOST:-201.34.129.230}"
USER="${SERVER_USER:-Administrator}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREDS_FILE="${CREDS_FILE:-$SCRIPT_DIR/../../.cursor/workspace/active/orch-2026-08-21-11-34-1c-erp-setup/server-credentials.local.json}"
SSHPASS_BIN="${SSHPASS_BIN:-/tmp/sshpass-1.10/sshpass}"
REPORT="${REPORT:-$SCRIPT_DIR/last-remote-probe.txt}"
INTERVAL="${INTERVAL:-60}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-60}"
FREERDP_TRIED="${FREERDP_TRIED:-0}"

ONCE=0
for arg in "$@"; do
  case "$arg" in
    --once) ONCE=1 ;;
    --help|-h)
      echo "Usage: $0 [--once]"
      echo "  Env: SERVER_HOST SERVER_USER SERVER_PASSWORD CREDS_FILE INTERVAL MAX_ATTEMPTS"
      exit 0
      ;;
  esac
done

if [[ -z "${SERVER_PASSWORD:-}" && -f "$CREDS_FILE" ]]; then
  SERVER_PASSWORD="$(python3 -c "import json; print(json.load(open('$CREDS_FILE'))['server']['password'])")"
fi
if [[ -z "${SERVER_PASSWORD:-}" ]]; then
  echo "Set SERVER_PASSWORD or CREDS_FILE" >&2
  exit 1
fi

log() { echo "[$(date -Iseconds)] $*" | tee -a "$REPORT"; }

ensure_sshpass() {
  if [[ -x "$SSHPASS_BIN" ]]; then
    return 0
  fi
  log "Building sshpass at $SSHPASS_BIN..."
  local dir
  dir="$(dirname "$SSHPASS_BIN")"
  mkdir -p "$dir"
  (cd /tmp && curl -fsSL -o sshpass-1.10.tar.gz \
    https://sourceforge.net/projects/sshpass/files/sshpass/1.10/sshpass-1.10.tar.gz/download \
    && tar xzf sshpass-1.10.tar.gz && cd sshpass-1.10 && ./configure && make)
  SSHPASS_BIN="/tmp/sshpass-1.10/sshpass"
}

tcp_open() {
  nc -z -G 3 -w 3 "$HOST" "$1" 2>/dev/null
}

probe_rdp() {
  python3 - <<PY
import socket
host="$HOST"
pdu=bytes.fromhex('030000130ed000001234000300080001000000')
s=socket.create_connection((host,3389),10)
s.sendall(pdu)
s.settimeout(5)
try:
    d=s.recv(64)
    print('OK' if len(d)>=11 and d[0]==3 else 'BAD')
except Exception:
    print('TIMEOUT')
s.close()
PY
}

probe_ssh_banner() {
  python3 - <<PY
import socket
s=socket.create_connection(("$HOST",22),10)
s.settimeout(8)
try:
    b=s.recv(256)
    print('OK' if b.startswith(b'SSH-') else 'BAD')
except Exception as e:
    print('NO_BANNER')
s.close()
PY
}

probe_http_port() {
  local port=$1 path=${2:-/}
  python3 - <<PY
import socket
host,port,path="$HOST",$port,"$path"
req=f"GET {path} HTTP/1.1\r\nHost: {host}\r\nConnection: close\r\n\r\n".encode()
s=socket.create_connection((host,port),8)
s.sendall(req)
s.settimeout(8)
try:
    d=s.recv(512)
    print('OK' if len(d) > 0 else 'EMPTY')
except Exception:
    print('TIMEOUT')
s.close()
PY
}

try_ssh_exec() {
  ensure_sshpass
  "$SSHPASS_BIN" -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -o ConnectTimeout=15 -o PreferredAuthentications=password -o PubkeyAuthentication=no \
    "$USER@$HOST" "hostname" >>"$REPORT" 2>&1
}

try_winrm_exec() {
  python3 -c "import winrm" 2>/dev/null || return 1
  python3 - <<PY >>"$REPORT" 2>&1
import winrm
s=winrm.Session('http://$HOST:5985/wsman', auth=('$USER', """$SERVER_PASSWORD"""), transport='ntlm', read_timeout_sec=20, operation_timeout_sec=15)
r=s.run_cmd('hostname')
print('WinRM status', r.status_code, r.std_out, r.std_err)
raise SystemExit(0 if r.status_code == 0 else 1)
PY
}

run_probe_cycle() {
  if [[ "$attempt" -eq 1 ]]; then
    : > "$REPORT"
  fi
  log "=== Remote probe: $USER@$HOST (attempt $attempt) ==="

  for p in 22 80 443 445 3389 5985 5986 8080; do
    if tcp_open "$p"; then log "TCP $p: open"; else log "TCP $p: closed"; fi
  done

  log "RDP protocol: $(probe_rdp)"
  log "SSH banner: $(probe_ssh_banner)"
  log "HTTP:5985/wsman: $(probe_http_port 5985 /wsman)"
  log "HTTP:80/: $(probe_http_port 80 /)"

  if try_ssh_exec; then
    log "SSH exec: SUCCESS — running mac-setup.sh"
    exec "$SCRIPT_DIR/mac-setup.sh"
  fi
  log "SSH exec: not ready"

  if try_winrm_exec; then
    log "WinRM exec: SUCCESS — upload via winrm (manual follow-up) or wait for userdata"
    return 0
  fi
  log "WinRM exec: not ready"

  return 1
}

try_freerdp_bootstrap() {
  local freerdp="${FREERDP:-$HOME/.homebrew/bin/sdl-freerdp}"
  if [[ ! -x "$freerdp" && -x /opt/homebrew/bin/sdl-freerdp ]]; then
    freerdp=/opt/homebrew/bin/sdl-freerdp
  fi
  if [[ ! -x "$freerdp" ]]; then
    log "FreeRDP: not installed (brew install freerdp) — skip headless bootstrap"
    return 1
  fi
  if [[ "$FREERDP_TRIED" == "1" ]]; then
    log "FreeRDP: already tried this session"
    return 1
  fi
  FREERDP_TRIED=1
  log "FreeRDP: attempting headless bootstrap via RDP drive redirect..."
  FREERDP="$freerdp" "$SCRIPT_DIR/freerdp-bootstrap.sh" && return 0
  log "FreeRDP bootstrap failed — see freerdp-bootstrap.log"
  return 1
}

attempt=1
while true; do
  log "--- Attempt $attempt/$MAX_ATTEMPTS (interval ${INTERVAL}s) ---"

  if run_probe_cycle; then
    exit 0
  fi

  # After first failed cycle: try FreeRDP once if RDP port responds
  if [[ "$FREERDP_TRIED" == "0" ]] && tcp_open 3389; then
    try_freerdp_bootstrap || true
    # Re-probe SSH immediately after RDP bootstrap
    if try_ssh_exec; then
      log "SSH exec after FreeRDP: SUCCESS — running mac-setup.sh"
      exec "$SCRIPT_DIR/mac-setup.sh"
    fi
  fi

  if [[ "$ONCE" == "1" || "$attempt" -ge "$MAX_ATTEMPTS" ]]; then
    log "=== No working remote exec channel ==="
    log "Tier A: paste provider-userdata.ps1 in hosting panel User data"
    log "Tier B: ensure RDP works; agent will retry FreeRDP bootstrap"
    log "Report: $REPORT"
    exit 2
  fi

  log "Waiting ${INTERVAL}s before retry..."
  sleep "$INTERVAL"
  attempt=$((attempt + 1))
done
