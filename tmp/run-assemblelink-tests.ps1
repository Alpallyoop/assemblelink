# run-assemblelink-tests.ps1
# Mirrors the test/audit steps of .github/workflows/prepare-signed-release.yml (minus signing and release).
# Run from a Windows PowerShell 5.1+ or pwsh prompt:
#   cd C:\dev\assemblelink
#   powershell -ExecutionPolicy Bypass -File .\run-assemblelink-tests.ps1
# Read-only with respect to source: it runs tests/audits and writes only to a log under %TEMP%.
# Add -Live to also probe every catalog Winget identity against the live winget source (needs network).
param(
    [string]$RepoRoot = (Get-Location).Path,
    [switch]$Live,
    [switch]$SkipRust
)

$ErrorActionPreference = 'Continue'
$results = New-Object System.Collections.Generic.List[object]
$log = Join-Path $env:TEMP ("assemblelink-tests-{0}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
Start-Transcript -Path $log | Out-Null

function Step([string]$Name, [scriptblock]$Body, [switch]$Native) {
    Write-Host "`n=== $Name ===" -ForegroundColor Cyan
    $global:LASTEXITCODE = 0
    $ok = $true
    try {
        & $Body
        if (-not $?) { $ok = $false }
        # Only native tools (npm/cargo) are judged by exit code. PowerShell tests intentionally run
        # negative cases that leave a nonzero $LASTEXITCODE (CI resets it the same way).
        if ($Native -and $LASTEXITCODE -ne 0) { $ok = $false }
    } catch {
        Write-Host $_ -ForegroundColor Red
        $ok = $false
    }
    $global:LASTEXITCODE = 0
    $results.Add([pscustomobject]@{ Step = $Name; Result = $(if ($ok) { 'PASS' } else { 'FAIL' }) })
}

Set-Location $RepoRoot

Step 'UI: npm ci'            { Push-Location ui; try { npm ci } finally { Pop-Location } } -Native
Step 'UI: npm test'          { Push-Location ui; try { npm test } finally { Pop-Location } } -Native
Step 'UI: npm audit (high)'  { Push-Location ui; try { npm audit --audit-level=high } finally { Pop-Location } } -Native
Step 'UI: npm run build'     { Push-Location ui; try { npm run build } finally { Pop-Location } } -Native

if (-not $SkipRust) {
    Step 'Rust: cargo test --locked' { Push-Location ui/src-tauri; try { cargo test --locked } finally { Pop-Location } } -Native
    Step 'Rust: cargo fmt --check'   { Push-Location ui/src-tauri; try { cargo fmt --all -- --check } finally { Pop-Location } } -Native
    Step 'Rust: cargo clippy'        { Push-Location ui/src-tauri; try { cargo clippy --locked --all-targets -- -D warnings } finally { Pop-Location } } -Native
}

Get-ChildItem tests -Filter 'test_*.ps1' -File | Sort-Object Name | ForEach-Object {
    $t = $_
    Step ("PS test: {0}" -f $t.Name) { & $t.FullName -RepoRoot $RepoRoot }
}

Step 'Validate manifests' { & scripts/commands/al_validate_manifests_v1.ps1 -RepoRoot $RepoRoot }

$skipAudits = @('al_capability_status_audit_v1.ps1','al_mission_console_audit_v1.ps1','al_runtime_smoke_v1.ps1','al_workstation_proof_v1.ps1')
Get-ChildItem scripts/audit -Filter '*.ps1' -File | Where-Object { $_.Name -notin $skipAudits } | Sort-Object Name | ForEach-Object {
    $a = $_
    Step ("Audit: {0}" -f $a.Name) { & $a.FullName -RepoRoot $RepoRoot }
}

if ($Live) {
    Step 'Catalog verification (live Winget)' { & scripts/audit/al_catalog_verification_v1.ps1 -RepoRoot $RepoRoot -Live }
}

Write-Host "`n================ SUMMARY ================" -ForegroundColor Yellow
$results | Format-Table -AutoSize
$failed = @($results | Where-Object { $_.Result -eq 'FAIL' })
Write-Host ("{0} passed, {1} failed. Full log: {2}" -f ($results.Count - $failed.Count), $failed.Count, $log)
Stop-Transcript | Out-Null
if ($failed.Count -gt 0) { exit 1 } else { exit 0 }
