[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$liveRoot = Join-Path $env:USERPROFILE '.config\opencode'
$liveConfig = Join-Path $liveRoot 'opencode.jsonc'
$liveSkills = Join-Path $liveRoot 'skills'
$backupRoot = Join-Path $repositoryRoot 'opencode'
$backupSkills = Join-Path $backupRoot 'skills'

if (-not (Test-Path -LiteralPath $liveConfig -PathType Leaf)) {
    throw "Live OpenCode configuration not found: $liveConfig"
}

if (-not (Test-Path -LiteralPath $liveSkills -PathType Container)) {
    throw "Live OpenCode skills directory not found: $liveSkills"
}

New-Item -ItemType Directory -Path $backupSkills -Force | Out-Null
Copy-Item -LiteralPath $liveConfig -Destination (Join-Path $backupRoot 'opencode.jsonc') -Force

$skillFiles = @(Get-ChildItem -LiteralPath $liveSkills -File -Recurse -Force)
foreach ($skillFile in $skillFiles) {
    $relativePath = [System.IO.Path]::GetRelativePath($liveSkills, $skillFile.FullName)
    $destinationPath = Join-Path $backupSkills $relativePath
    $destinationDirectory = Split-Path -Parent $destinationPath

    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    Copy-Item -LiteralPath $skillFile.FullName -Destination $destinationPath -Force
}

Write-Output "Backed up OpenCode configuration and $($skillFiles.Count) skill file(s) to $backupRoot"
