# Load configuration files into the IB via educational Designer (1cv8t.exe).
# Local: self-hosted runner on the old 1C server.
# Remote: from vdswin2k22, ssh REMOTE_SSH_HOST and run the same Designer command.
#
# Runner (repo root on the old server):
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\1c-remote\Import-Config.ps1

#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$SourcePath = '',
    [string]$Extension = '',
    [switch]$Remote,
    [string]$EnvFile = '',
    [string]$LogPath = ''
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'Designer-Common.ps1')

$repoRoot = Get-1cRemoteRepoRoot -ScriptDir $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($EnvFile)) {
    $EnvFile = Join-Path $repoRoot '.dev.env'
}

$envMap = Read-DevEnvFile -Path $EnvFile
$ctx = Get-DesignerContext -EnvMap $envMap -RepoRoot $repoRoot -LogPath $LogPath -DefaultLogName '1cv8-import.log'

$loadPath = Resolve-DesignerWorkPath -ExplicitPath $SourcePath -ExportPath $ctx.ExportPath `
    -RepoRoot $ctx.RepoRoot -Remote:$Remote `
    -RemoteRequiredMessage 'With -Remote specify -SourcePath or EXPORT_PATH as a path on the remote 1C host (not a vdswin2k22 path).'

if (-not $Remote -and -not (Test-Path -LiteralPath $loadPath)) {
    throw "Source path not found: $loadPath"
}

$designerArgs = New-Object System.Collections.Generic.List[string]
[void]$designerArgs.Add('DESIGNER')
[void]$designerArgs.Add($ctx.InfobaseFlag)
[void]$designerArgs.Add($ctx.InfobasePath)
foreach ($authArg in (Get-DesignerAuthArgs -Context $ctx)) {
    [void]$designerArgs.Add($authArg)
}
[void]$designerArgs.Add('/DisableStartupMessages')
[void]$designerArgs.Add('/LoadConfigFromFiles')
[void]$designerArgs.Add($loadPath)
if (-not [string]::IsNullOrWhiteSpace($Extension)) {
    [void]$designerArgs.Add('-Extension')
    [void]$designerArgs.Add($Extension)
}
[void]$designerArgs.Add('/UpdateDBCfg')
[void]$designerArgs.Add('/Out')
[void]$designerArgs.Add($ctx.LogPath)

$exitCode = Invoke-DesignerCommand -DesignerExe $ctx.DesignerExe -ArgumentList $designerArgs.ToArray() `
    -Remote:$Remote -SshHost $ctx.SshHost

if ($exitCode -ne 0) {
    Write-Host "Designer import failed with exit code $exitCode. See log: $($ctx.LogPath)"
    exit $exitCode
}

Write-Host "Designer import finished. Log: $($ctx.LogPath)"
exit 0
