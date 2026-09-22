# Dump configuration files from the IB via educational Designer (1cv8t.exe).
# Local: self-hosted runner on the old 1C server.
# Remote: from vdswin2k22, ssh REMOTE_SSH_HOST and run the same Designer command.

#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$OutputPath = '',
    [string]$Extension = '',
    [string]$ListFile = '',
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
$ctx = Get-DesignerContext -EnvMap $envMap -RepoRoot $repoRoot -LogPath $LogPath -DefaultLogName '1cv8-export.log'

$dumpPath = Resolve-DesignerWorkPath -ExplicitPath $OutputPath -ExportPath $ctx.ExportPath `
    -RepoRoot $ctx.RepoRoot -Remote:$Remote `
    -RemoteRequiredMessage 'With -Remote specify -OutputPath or EXPORT_PATH as a path on the remote 1C host (not a vdswin2k22 path).'

if (-not $Remote) {
    if (-not (Test-Path -LiteralPath $dumpPath)) {
        New-Item -ItemType Directory -Path $dumpPath -Force | Out-Null
    }
}

$listArg = $ListFile
if (-not [string]::IsNullOrWhiteSpace($listArg) -and -not [System.IO.Path]::IsPathRooted($listArg)) {
    $listArg = Join-Path $ctx.RepoRoot $listArg
}
if (-not $Remote -and -not [string]::IsNullOrWhiteSpace($listArg) -and -not (Test-Path -LiteralPath $listArg)) {
    throw "List file not found: $listArg"
}

$designerArgs = New-Object System.Collections.Generic.List[string]
[void]$designerArgs.Add('DESIGNER')
[void]$designerArgs.Add($ctx.InfobaseFlag)
[void]$designerArgs.Add($ctx.InfobasePath)
foreach ($authArg in (Get-DesignerAuthArgs -Context $ctx)) {
    [void]$designerArgs.Add($authArg)
}
[void]$designerArgs.Add('/DisableStartupMessages')
[void]$designerArgs.Add('/DumpConfigToFiles')
[void]$designerArgs.Add($dumpPath)
if (-not [string]::IsNullOrWhiteSpace($listArg)) {
    [void]$designerArgs.Add('-listFile')
    [void]$designerArgs.Add($listArg)
}
if (-not [string]::IsNullOrWhiteSpace($Extension)) {
    [void]$designerArgs.Add('-Extension')
    [void]$designerArgs.Add($Extension)
}
[void]$designerArgs.Add('/Out')
[void]$designerArgs.Add($ctx.LogPath)

$exitCode = Invoke-DesignerCommand -DesignerExe $ctx.DesignerExe -ArgumentList $designerArgs.ToArray() `
    -Remote:$Remote -SshHost $ctx.SshHost

if ($exitCode -ne 0) {
    Write-Host "Designer export failed with exit code $exitCode. See log: $($ctx.LogPath)"
    exit $exitCode
}

Write-Host "Designer export finished. Log: $($ctx.LogPath)"
exit 0
