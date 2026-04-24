$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Src      = Join-Path $HOME '.claude'
$Dst      = Join-Path $RepoRoot 'claude'

New-Item -ItemType Directory -Force -Path (Join-Path $Dst 'agents') | Out-Null

Copy-Item -Force (Join-Path $Src 'agents\tech-researcher.md') (Join-Path $Dst 'agents\tech-researcher.md')
Copy-Item -Force (Join-Path $Src 'CLAUDE.md')                 (Join-Path $Dst 'CLAUDE.md')

Write-Host "[sync] copied from ~/.claude/ to $Dst"
Write-Host "[sync] next: git add -A; git commit -m 'sync: update from local ~/.claude/'; git push"
