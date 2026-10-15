# Diagnoses test_software_intelligence.ps1 under the current PowerShell host.
# Run once with Windows PowerShell 5.1 (powershell) and once with pwsh, from C:\dev\assemblelink.
param([string]$RepoRoot = (Get-Location).Path)
$ErrorActionPreference = 'Stop'
Write-Host ("Host: PowerShell {0} ({1})" -f $PSVersionTable.PSVersion, $PSVersionTable.PSEdition)
$testRoot = Join-Path $env:TEMP ('al-diag-' + [guid]::NewGuid().ToString('n'))
New-Item -ItemType Directory -Force (Join-Path $testRoot 'catalog') | Out-Null
Copy-Item (Join-Path $RepoRoot 'catalog\approved_software_sources.v1.json') (Join-Path $testRoot 'catalog\')
try {
    $path = & (Join-Path $RepoRoot 'scripts\engine\al_software_intelligence_v1.ps1') -RepoRoot $testRoot `
        -InventoryFixturePath (Join-Path $RepoRoot 'tests\fixtures\inventory.software-intelligence.json') `
        -ProviderFixturePath (Join-Path $RepoRoot 'tests\fixtures\providers.software-intelligence.json') | Select-Object -Last 1
    $r = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    $r.items | Where-Object { $_.catalog_id -in 'git','vscode','nodejs-lts','ghidra','7zip' } |
        Format-Table catalog_id, installed, installed_version, available_version, update_status, provider_status -AutoSize
} finally { Remove-Item $testRoot -Recurse -Force -ErrorAction SilentlyContinue }
