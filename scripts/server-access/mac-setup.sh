#!/usr/bin/env bash
# Mac-side server-access automation (run after SSH banner exchange works)
set -euo pipefail

HOST="201.34.129.230"
USER="Administrator"
KEY="$HOME/.ssh/id_ed25519_1clab"
CREDS_FILE="${CREDS_FILE:-$(dirname "$0")/../../.cursor/workspace/active/orch-2026-08-21-11-34-1c-erp-setup/server-credentials.local.json}"
SSHPASS_BIN="${SSHPASS_BIN:-/tmp/sshpass-1.10/sshpass}"

if [[ ! -f "$KEY" ]]; then
  echo "Missing SSH key: $KEY — run: ssh-keygen -t ed25519 -f $KEY -N ''"
  exit 1
fi

if [[ ! -x "$SSHPASS_BIN" ]]; then
  echo "Building sshpass..."
  (cd /tmp && curl -sL -o sshpass-1.10.tar.gz https://sourceforge.net/projects/sshpass/files/sshpass/1.10/sshpass-1.10.tar.gz/download \
    && tar xzf sshpass-1.10.tar.gz && cd sshpass-1.10 && ./configure && make)
  SSHPASS_BIN="/tmp/sshpass-1.10/sshpass"
fi

if [[ -f "$CREDS_FILE" ]]; then
  PASS=$(python3 -c "import json; print(json.load(open('$CREDS_FILE'))['server']['password'])")
else
  echo "Set PASS env or CREDS_FILE"
  exit 1
fi

SSH_OPTS=(-o StrictHostKeyChecking=accept-new -o ConnectTimeout=20 -i "$KEY" -o IdentitiesOnly=yes)

run_ssh() {
  SSHPASS="$PASS" "$SSHPASS_BIN" -e ssh "${SSH_OPTS[@]}" -o PreferredAuthentications=password -o PubkeyAuthentication=no "$USER@$HOST" "$@"
}

echo "==> Testing SSH..."
if ! run_ssh "hostname"; then
  echo "SSH failed — use RDP + setup-server.ps1 manually"
  exit 1
fi

echo "==> Uploading setup script and public key..."
scp "${SSH_OPTS[@]}" -o PreferredAuthentications=password \
  "$(dirname "$0")/setup-server.ps1" \
  "$KEY.pub" \
  "$USER@$HOST:/C:/1C-Lab/scripts/" 2>/dev/null || \
run_ssh "powershell -NoProfile -Command \"New-Item -Force -ItemType Directory C:\\1C-Lab\\scripts | Out-Null\""

SSHPASS="$PASS" "$SSHPASS_BIN" -e scp -o StrictHostKeyChecking=accept-new -o ConnectTimeout=20 \
  "$(dirname "$0")/setup-server.ps1" "$USER@$HOST:C:/1C-Lab/scripts/setup-server.ps1"
SSHPASS="$PASS" "$SSHPASS_BIN" -e scp -o StrictHostKeyChecking=accept-new \
  "$KEY.pub" "$USER@$HOST:C:/1C-Lab/scripts/authorized_key.pub"

echo "==> Running server setup..."
run_ssh "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\1C-Lab\\scripts\\setup-server.ps1"

echo "==> Deploying SSH key (passwordless)..."
run_ssh "powershell -NoProfile -Command \"
  \$k = Get-Content C:\\1C-Lab\\scripts\\authorized_key.pub -Raw;
  Set-Content C:\\ProgramData\\ssh\\administrators_authorized_keys -Value \$k.Trim() -Encoding ascii
\""

echo "==> Verifying key auth..."
ssh "${SSH_OPTS[@]}" "$USER@$HOST" "echo SSH_KEY_OK && dir C:\\1C-Lab"

echo "Done. Add to ~/.ssh/config:"
echo "Host 1c-erp"
echo "  HostName $HOST"
echo "  User $USER"
echo "  IdentityFile $KEY"
echo "  IdentitiesOnly yes"
