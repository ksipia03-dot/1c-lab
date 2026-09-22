# Owner once: SSH на старый сервер 1С

Коротко: откройте порт 22 только с этого сервера, затем **один раз** вставьте блок ниже в PowerShell **от имени администратора** на старом сервере.

| Поле | Значение |
|------|----------|
| Этот сервер (vdswin2k22) | `72.56.105.69` |
| Timeweb подсеть | `72.56.105.69/32` — **не** «для всех» |
| Старый сервер | `201.34.129.230` (Brave Smew) |
| RDP | как обычно, **plain**, без alternate shell |
| SSH-алиас на vdswin2k22 | `1c-erp` |

## 1. Timeweb (если ещё не открыли TCP 22)

1. Панель Timeweb → облачный сервер **Brave Smew** → файрвол.
2. Входящее правило: тип **Своё правило**, протокол **TCP**, порт **22**.
3. Адрес: подсеть `72.56.105.69/32` (не «для всех»).
4. Сохраните. В чат: «порт 22 открыла».

## 2. Один блок PowerShell на старом сервере

1. RDP на `201.34.129.230`.
2. PowerShell **от имени администратора**.
3. Вставьте блок целиком. Ничего не меняйте.

```powershell
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
Write-Host '=== 1C-ERP OpenSSH bootstrap (Administrator on 201.34.129.230) ==='

$cap = Get-WindowsCapability -Online | Where-Object { $_.Name -like 'OpenSSH.Server*' } | Select-Object -First 1
if (-not $cap) { throw 'OpenSSH.Server capability not found on this Windows image.' }
if ($cap.State -ne 'Installed') {
    Write-Host "Installing $($cap.Name) ..."
    Add-WindowsCapability -Online -Name $cap.Name | Out-Null
} else {
    Write-Host "OpenSSH.Server already installed ($($cap.Name))."
}

Set-Service -Name sshd -StartupType Automatic
if ((Get-Service -Name sshd).Status -ne 'Running') {
    Start-Service -Name sshd
}

Get-NetFirewallRule -ErrorAction SilentlyContinue |
    Where-Object { $_.Direction -eq 'Inbound' -and ($_.DisplayName -like '*OpenSSH*' -or $_.Name -like '*OpenSSH*') } |
    Enable-NetFirewallRule
if (-not (Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP-1c-erp' -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP-1c-erp' `
        -DisplayName 'OpenSSH SSH Server (sshd) 1c-erp' `
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -Profile Any | Out-Null
    Write-Host 'Firewall: inbound TCP 22 allow rule created.'
} else {
    Write-Host 'Firewall: inbound TCP 22 allow rule already present.'
}

$pub = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQXa4qhJyIrKng4Z2e7iPlpo1aGkumgS9c92nGHTr2n vdswin2k22-1c-erp'
$authKeys = 'C:\ProgramData\ssh\administrators_authorized_keys'
if (-not (Test-Path -LiteralPath 'C:\ProgramData\ssh')) {
    New-Item -ItemType Directory -Path 'C:\ProgramData\ssh' -Force | Out-Null
}
$blob = ''
if (Test-Path -LiteralPath $authKeys) {
    $blob = [System.IO.File]::ReadAllText($authKeys)
}
if ($blob -notlike '*AAAAC3NzaC1lZDI1NTE5AAAAICQXa4qhJyIrKng4Z2e7iPlpo1aGkumgS9c92nGHTr2n*') {
    $prefix = if ([string]::IsNullOrWhiteSpace($blob)) { '' } else { $blob.TrimEnd("`r", "`n") + "`n" }
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($authKeys, ($prefix + $pub + "`n"), $utf8NoBom)
    Write-Host 'Public key written to administrators_authorized_keys.'
} else {
    Write-Host 'Public key already present in administrators_authorized_keys.'
}

& icacls.exe $authKeys /inheritance:r | Out-Null
& icacls.exe $authKeys /grant 'SYSTEM:(F)' | Out-Null
& icacls.exe $authKeys /grant 'BUILTIN\Administrators:(F)' | Out-Null
Write-Host 'icacls: SYSTEM + Administrators, inheritance removed.'
& icacls.exe $authKeys

Restart-Service -Name sshd
Get-Service -Name sshd | Format-List Name, Status, StartType
Write-Host '=== Done. Reply in chat: блок на старом сервере выполнен ==='
```

4. В чат: «блок на старом сервере выполнен» и путь к базе (или «база как в .dev.env, ERP25_MCP»).

Приватный ключ в чат и в git **не копируйте**. В блоке только публичный ключ с vdswin2k22.
