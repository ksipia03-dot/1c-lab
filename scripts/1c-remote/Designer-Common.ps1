# Shared helpers for Import-Config.ps1 / Export-Config.ps1.
# Educational platform only: 1cv8t.exe (not 1cv8.exe). Do not Write-Host passwords.

#Requires -Version 5.1

function Get-1cRemoteRepoRoot {
    param([Parameter(Mandatory = $true)][string]$ScriptDir)
    return (Resolve-Path -LiteralPath (Join-Path $ScriptDir '..\..')).Path
}

function Read-DevEnvFile {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Env file not found: $Path"
    }

    $map = @{}
    $lines = Get-Content -LiteralPath $Path -Encoding UTF8
    foreach ($raw in $lines) {
        $line = $raw.Trim()
        if ($line -eq '' -or $line.StartsWith('#')) {
            continue
        }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) {
            continue
        }
        $key = $line.Substring(0, $eq).Trim()
        $val = $line.Substring($eq + 1)
        if ($val.Length -ge 2) {
            $first = $val[0]
            $last = $val[$val.Length - 1]
            if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
                $val = $val.Substring(1, $val.Length - 2)
            }
        }
        $map[$key] = $val
    }
    return $map
}

function Get-DevEnvValue {
    param(
        [Parameter(Mandatory = $true)][hashtable]$Map,
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Default = ''
    )
    if ($Map.ContainsKey($Name) -and -not [string]::IsNullOrWhiteSpace([string]$Map[$Name])) {
        return [string]$Map[$Name]
    }
    return $Default
}

function ConvertTo-SingleQuotedPsLiteral {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value)
    return "'" + ($Value -replace "'", "''") + "'"
}

function Get-RedactedDesignerArgs {
    param([Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$ArgumentList)

    $safe = New-Object System.Collections.Generic.List[string]
    $hideNext = $false
    foreach ($arg in $ArgumentList) {
        if ($hideNext) {
            [void]$safe.Add('***')
            $hideNext = $false
            continue
        }
        if ($arg -eq '/P') {
            $hideNext = $true
        }
        [void]$safe.Add($arg)
    }
    return ($safe -join ' ')
}

function Get-DesignerContext {
    param(
        [Parameter(Mandatory = $true)][hashtable]$EnvMap,
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [string]$LogPath = '',
        [string]$DefaultLogName = '1cv8.log'
    )

    $platformPath = Get-DevEnvValue -Map $EnvMap -Name 'PLATFORM_PATH'
    $infobasePath = Get-DevEnvValue -Map $EnvMap -Name 'INFOBASE_PATH'
    if ([string]::IsNullOrWhiteSpace($platformPath)) {
        throw 'PLATFORM_PATH is empty in .dev.env. It must be the educational platform directory on the old 1C server.'
    }
    if ([string]::IsNullOrWhiteSpace($infobasePath)) {
        throw 'INFOBASE_PATH is empty in .dev.env. Do not invent an IB path — set the path on the old 1C server.'
    }

    $kind = (Get-DevEnvValue -Map $EnvMap -Name 'INFOBASE_KIND' -Default 'file').Trim().ToLowerInvariant()
    if ($kind -ne 'file' -and $kind -ne 'server') {
        throw "INFOBASE_KIND must be 'file' or 'server' (got '$kind')."
    }

    $ibFlag = '/F'
    if ($kind -eq 'server') {
        $ibFlag = '/S'
    }

    $designerExe = Join-Path $platformPath 'bin\1cv8t.exe'
    $exportPath = Get-DevEnvValue -Map $EnvMap -Name 'EXPORT_PATH'
    $sshHost = Get-DevEnvValue -Map $EnvMap -Name 'REMOTE_SSH_HOST'
    $ibUser = Get-DevEnvValue -Map $EnvMap -Name 'IB_USER'
    $ibPassword = Get-DevEnvValue -Map $EnvMap -Name 'IB_PASSWORD'

    $resolvedLog = $LogPath
    if ([string]::IsNullOrWhiteSpace($resolvedLog)) {
        $fromEnv = Get-DevEnvValue -Map $EnvMap -Name 'LOG_PATH'
        if (-not [string]::IsNullOrWhiteSpace($fromEnv)) {
            $resolvedLog = $fromEnv
        }
        else {
            $resolvedLog = Join-Path $env:TEMP $DefaultLogName
        }
    }

    return [pscustomobject]@{
        DesignerExe  = $designerExe
        InfobaseFlag = $ibFlag
        InfobasePath = $infobasePath
        IbUser       = $ibUser
        IbPassword   = $ibPassword
        ExportPath   = $exportPath
        SshHost      = $sshHost
        LogPath      = $resolvedLog
        RepoRoot     = $RepoRoot
    }
}

function Get-DesignerAuthArgs {
    param([Parameter(Mandatory = $true)]$Context)

    $args = New-Object System.Collections.Generic.List[string]
    if (-not [string]::IsNullOrWhiteSpace($Context.IbUser)) {
        [void]$args.Add('/N')
        [void]$args.Add($Context.IbUser)
    }
    if (-not [string]::IsNullOrWhiteSpace($Context.IbPassword)) {
        [void]$args.Add('/P')
        [void]$args.Add($Context.IbPassword)
    }
    return $args
}

function Resolve-DesignerWorkPath {
    param(
        [string]$ExplicitPath,
        [string]$ExportPath,
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [switch]$Remote,
        [Parameter(Mandatory = $true)][string]$RemoteRequiredMessage
    )

    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        return $ExplicitPath
    }
    if (-not [string]::IsNullOrWhiteSpace($ExportPath)) {
        return $ExportPath
    }
    if ($Remote) {
        throw $RemoteRequiredMessage
    }
    return $RepoRoot
}

function Invoke-DesignerCommand {
    param(
        [Parameter(Mandatory = $true)][string]$DesignerExe,
        [Parameter(Mandatory = $true)][string[]]$ArgumentList,
        [switch]$Remote,
        [string]$SshHost = ''
    )

    $display = Get-RedactedDesignerArgs -ArgumentList $ArgumentList

    if (-not $Remote) {
        if (-not (Test-Path -LiteralPath $DesignerExe)) {
            throw "1cv8t.exe not found: $DesignerExe. This machine has no educational platform. On vdswin2k22 pass -Remote (ssh), or run the script on the self-hosted runner (old 1C server)."
        }
        Write-Host "Designer (local): $DesignerExe"
        Write-Host "Args: $display"
        & $DesignerExe @ArgumentList
        return $LASTEXITCODE
    }

    if ([string]::IsNullOrWhiteSpace($SshHost)) {
        throw 'REMOTE_SSH_HOST is empty. Set it in .dev.env (alias 1c-erp) or run without -Remote on the runner.'
    }

    $sshCmd = Get-Command ssh.exe -ErrorAction SilentlyContinue
    if ($null -eq $sshCmd) {
        throw 'ssh.exe not found. Install OpenSSH Client, or run without -Remote on the self-hosted runner.'
    }

    $exeLit = ConvertTo-SingleQuotedPsLiteral -Value $DesignerExe
    $argLits = foreach ($a in $ArgumentList) { ConvertTo-SingleQuotedPsLiteral -Value $a }
    $remoteCmd = "& $exeLit $($argLits -join ' '); exit `$LASTEXITCODE"
    $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($remoteCmd))

    Write-Host "Designer (ssh $SshHost): $DesignerExe"
    Write-Host "Args: $display"
    & $sshCmd.Source -o BatchMode=yes $SshHost -- "powershell.exe -NoProfile -EncodedCommand $encoded"
    return $LASTEXITCODE
}
