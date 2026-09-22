# R1C-001 probe-connectivity — offline findings checks.
# Reads the worker markdown only. Does not call Test-NetConnection,
# TcpClient, curl, gh, or any other live network probe.
#
# Run from repo root:
#   Invoke-Pester -Path .\scripts\1c-remote\tests\r1c-001-probe.Tests.ps1
# Pester 3 (inbox on some Windows Server images):
#   Invoke-Pester -Script .\scripts\1c-remote\tests\r1c-001-probe.Tests.ps1

#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

function Get-R1c001ProbePath {
    $repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..\..')).Path
    Join-Path $repoRoot '.cursor\workspace\active\orch-2026-09-11-1c-remote-deploy\r1c-001-probe.md'
}

function Assert-R1c001Contains {
    param(
        [Parameter(Mandatory = $true)][AllowNull()][string]$Text,
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $true)][string]$Because
    )
    if ([string]::IsNullOrEmpty($Text) -or $Text -notmatch $Pattern) {
        throw $Because
    }
}

Describe 'R1C-001 probe-connectivity findings' {
    BeforeAll {
        $script:ProbePath = Get-R1c001ProbePath
        if (Test-Path -LiteralPath $script:ProbePath) {
            $script:ProbeText = Get-Content -LiteralPath $script:ProbePath -Raw -Encoding UTF8
        }
        else {
            $script:ProbeText = $null
        }
    }

    It 'probe markdown exists' {
        if (-not (Test-Path -LiteralPath $script:ProbePath)) {
            throw "Missing probe markdown: $($script:ProbePath)"
        }
    }

    It 'records this host public IPv4 72.56.105.69' {
        Assert-R1c001Contains -Text $script:ProbeText -Pattern '72\.56\.105\.69' `
            -Because 'probe markdown must record public IPv4 72.56.105.69'
    }

    It 'records gh user ksipia03-dot' {
        Assert-R1c001Contains -Text $script:ProbeText -Pattern 'ksipia03-dot' `
            -Because 'probe markdown must record gh account ksipia03-dot'
    }

    It 'records TCP 22 result' {
        Assert-R1c001Contains -Text $script:ProbeText -Pattern '(?m)\|\s*22\s*\|[^\r\n]*\*\*open\*\*' `
            -Because 'probe markdown must record TCP 22 as open (file assertion only; no live scan)'
    }

    It 'records TCP 3389 result' {
        Assert-R1c001Contains -Text $script:ProbeText -Pattern '(?m)\|\s*3389\s*\|[^\r\n]*\*\*open\*\*' `
            -Because 'probe markdown must record TCP 3389 as open (file assertion only; no live scan)'
    }
}
