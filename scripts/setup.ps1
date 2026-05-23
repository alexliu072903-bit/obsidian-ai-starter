# Obsidian AI Starter — Setup Script
# Usage: .\setup.ps1 -VaultPath "D:\ob\Obsidian Vault" -GitHubUrl "https://github.com/username/repo.git"

param(
    [Parameter(Mandatory=$true)]
    [string]$VaultPath,

    [Parameter(Mandatory=$false)]
    [string]$GitHubUrl
)

$ErrorActionPreference = "Stop"

function Log($msg) { Write-Host "  $msg" -ForegroundColor Cyan }
function Ok($msg)  { Write-Host "  OK  $msg" -ForegroundColor Green }
function Err($msg) { Write-Host "  ERR $msg" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "Obsidian AI Starter — Setup" -ForegroundColor Magenta
Write-Host ""

# --- Validate vault path ---
if (-not (Test-Path $VaultPath)) {
    Err "Vault path not found: $VaultPath"
}
Ok "Vault found: $VaultPath"

# --- Check prerequisites ---
Log "Checking prerequisites..."
foreach ($cmd in @("node", "npm", "git")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Err "$cmd is not installed. Install it and try again."
    }
}
Ok "node, npm, git all present"

# --- Install Pi CLI ---
Log "Installing Pi CLI (@mariozechner/pi-coding-agent)..."
$piExists = Get-Command pi -ErrorAction SilentlyContinue
if ($piExists) {
    Ok "Pi already installed: $(pi --version 2>$null)"
} else {
    npm install -g @mariozechner/pi-coding-agent
    Ok "Pi installed"
}

# --- Install pi-obsidian-vault ---
Log "Installing pi-obsidian-vault..."
pi install npm:pi-obsidian-vault
Ok "pi-obsidian-vault installed"

# --- Clone and build obsidian-pi-plugin ---
Log "Cloning obsidian-pi-plugin..."
$pluginDir = Join-Path $env:TEMP "obsidian-pi-plugin-build"
if (Test-Path $pluginDir) {
    Remove-Item $pluginDir -Recurse -Force
}
git clone https://github.com/sigilmakes/obsidian-pi-plugin $pluginDir
Ok "Cloned"

Log "Installing plugin dependencies..."
Push-Location $pluginDir
npm install
Ok "Dependencies installed"

# --- Apply Windows compatibility patch ---
Log "Applying Windows spawn compatibility patch..."
$rpcPath = Join-Path $pluginDir "src\rpc.ts"
$content = Get-Content $rpcPath -Raw
$old = 'env: { ...process.env },'
$new = 'env: { ...process.env },' + "`r`n            shell: process.platform === `"win32`","
if ($content -notmatch 'shell: process\.platform') {
    $content = $content.Replace($old, $new)
    Set-Content $rpcPath $content -NoNewline
    Ok "Windows patch applied"
} else {
    Ok "Patch already present, skipping"
}

# --- Build plugin ---
Log "Building plugin..."
npm run build
Ok "Build complete"
Pop-Location

# --- Copy plugin files to vault ---
$destDir = Join-Path $VaultPath ".obsidian\plugins\pi-plugin"
Log "Copying plugin to $destDir ..."
New-Item -ItemType Directory -Force $destDir | Out-Null
Copy-Item (Join-Path $pluginDir "main.js") $destDir
Copy-Item (Join-Path $pluginDir "styles.css") $destDir
Copy-Item (Join-Path $pluginDir "manifest.json") $destDir
Ok "Plugin files copied"

# --- Git setup for vault ---
Log "Setting up git in vault..."
Push-Location $VaultPath

if (-not (Test-Path ".git")) {
    git init
    Ok "Git initialized"
} else {
    Ok "Git already initialized"
}

# Create .gitignore if missing
if (-not (Test-Path ".gitignore")) {
    @"
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/plugins/*/data.json
.trash/
.DS_Store
"@ | Set-Content ".gitignore" -Encoding UTF8
    Ok ".gitignore created"
}

if ($GitHubUrl) {
    $remoteExists = git remote get-url origin 2>$null
    if (-not $remoteExists) {
        git remote add origin $GitHubUrl
        Ok "GitHub remote added"
    } else {
        Ok "Remote already set: $remoteExists"
    }

    Log "Pushing vault to GitHub..."
    git add .
    git commit -m "Initial vault backup via obsidian-ai-starter" 2>$null
    git branch -M main
    git push -u origin main
    Ok "Vault pushed to GitHub"
} else {
    Ok "No GitHub URL provided — skipping git push"
}

Pop-Location

# --- Done ---
Write-Host ""
Write-Host "Automated setup complete." -ForegroundColor Green
Write-Host ""
Write-Host "Next: complete the 5 manual steps inside Obsidian." -ForegroundColor Yellow
Write-Host "See SETUP.md for details." -ForegroundColor Yellow
Write-Host ""
