# Obsidian AI Starter — Windows setup

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [Parameter(Mandatory = $false)]
    [string]$GitHubUrl,

    [Parameter(Mandatory = $false)]
    [switch]$PushToGitHub
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$PiVersion = "0.82.1"
$VaultPackageVersion = "0.2.3"
$PluginRef = "3ccd701160009d256528ee7794e80ee95b380a74"
$PluginRepository = "https://github.com/sigilmakes/obsidian-pi-plugin.git"
$MinNodeVersion = [version]"22.19.0"
$RootDir = Split-Path -Parent $PSScriptRoot
$PatchFile = Join-Path $RootDir "patches\obsidian-pi-plugin-cross-platform.patch"

function Log([string]$Message) {
    Write-Host "  $Message" -ForegroundColor Cyan
}

function Ok([string]$Message) {
    Write-Host "  OK  $Message" -ForegroundColor Green
}

function Fail([string]$Message) {
    throw $Message
}

function Invoke-Native {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $false)]
        [string[]]$Arguments = @()
    )

    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$FilePath failed with exit code $LASTEXITCODE."
    }
}

function Get-NativeOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $false)]
        [string[]]$Arguments = @()
    )

    $Output = & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$FilePath failed with exit code $LASTEXITCODE."
    }
    return $Output
}

function Require-Command([string]$Name) {
    $Command = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $Command) {
        Fail "$Name is not installed or not available on PATH."
    }
    return $Command.Source
}

function Set-PluginData {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DataPath,

        [Parameter(Mandatory = $true)]
        [string]$PiBinaryPath
    )

    if (Test-Path $DataPath) {
        try {
            $Data = Get-Content $DataPath -Raw | ConvertFrom-Json
        }
        catch {
            Fail "Cannot parse existing plugin settings at ${DataPath}: $($_.Exception.Message)"
        }
    }
    else {
        $Data = New-Object PSObject
    }

    $Defaults = [ordered]@{
        piBinaryPath     = $PiBinaryPath
        workingDirectory = ""
        defaultProvider  = ""
        defaultModel     = ""
        sessionSaveDir   = "Pi-Sessions"
        persistSessions  = $true
        thinkingLevel    = "medium"
    }

    foreach ($Entry in $Defaults.GetEnumerator()) {
        if ($Entry.Key -eq "piBinaryPath" -or -not ($Data.PSObject.Properties.Name -contains $Entry.Key)) {
            $Data | Add-Member -NotePropertyName $Entry.Key -NotePropertyValue $Entry.Value -Force
        }
    }

    $Data | ConvertTo-Json -Depth 20 | Set-Content $DataPath -Encoding UTF8
}

function Write-GitIgnoreIfMissing {
    $GitIgnorePath = Join-Path $VaultPath ".gitignore"
    if (Test-Path $GitIgnorePath) {
        Ok "Existing .gitignore preserved"
        return
    }

    @"
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/plugins/*/data.json
.trash/
.DS_Store
"@ | Set-Content $GitIgnorePath -Encoding UTF8
    Ok "Created a conservative Obsidian .gitignore"
}

function Push-PrivateBackup {
    if (-not $PushToGitHub) {
        return
    }
    if ([string]::IsNullOrWhiteSpace($GitHubUrl)) {
        Fail "-PushToGitHub requires -GitHubUrl."
    }

    Write-Host ""
    Log "Preparing an optional GitHub backup."
    Log "Use an empty PRIVATE repository. This script cannot verify repository visibility."

    if (-not (Test-Path (Join-Path $VaultPath ".git"))) {
        Invoke-Native -FilePath $GitPath -Arguments @("-C", $VaultPath, "init")
        Invoke-Native -FilePath $GitPath -Arguments @("-C", $VaultPath, "branch", "-M", "main")
        Ok "Initialized Git in the vault"
    }

    Invoke-Native -FilePath $GitPath -Arguments @("-C", $VaultPath, "diff", "--cached", "--quiet")
    Write-GitIgnoreIfMissing

    $ExistingOrigin = & $GitPath -C $VaultPath remote get-url origin 2>$null
    $OriginExitCode = $LASTEXITCODE
    if ($OriginExitCode -eq 0 -and $ExistingOrigin -ne $GitHubUrl) {
        Fail "Existing origin does not match -GitHubUrl. Refusing to push to an unexpected repository."
    }
    if ($OriginExitCode -ne 0) {
        Invoke-Native -FilePath $GitPath -Arguments @("-C", $VaultPath, "remote", "add", "origin", $GitHubUrl)
    }

    $RemoteRefs = Get-NativeOutput -FilePath $GitPath -Arguments @("-C", $VaultPath, "ls-remote", "origin")
    if ($RemoteRefs) {
        Fail "The GitHub repository is not empty. Refusing to overwrite or merge automatically."
    }

    Invoke-Native -FilePath $GitPath -Arguments @("-C", $VaultPath, "add", ".")
    Write-Host ""
    Write-Host "Files staged for the initial backup:"
    Invoke-Native -FilePath $GitPath -Arguments @("-C", $VaultPath, "status", "--short")
    Write-Host ""
    $Confirmation = Read-Host "Push these files to $GitHubUrl? Type 'push' to continue"

    if ($Confirmation -ne "push") {
        Invoke-Native -FilePath $GitPath -Arguments @("-C", $VaultPath, "reset", "--quiet")
        Fail "GitHub backup cancelled. No files were pushed."
    }

    & $GitPath -C $VaultPath diff --cached --quiet
    if ($LASTEXITCODE -eq 0) {
        Ok "No new vault files to commit"
    }
    elseif ($LASTEXITCODE -eq 1) {
        Invoke-Native -FilePath $GitPath -Arguments @(
            "-C", $VaultPath, "commit", "-m", "Initial private Obsidian vault backup"
        )
    }
    else {
        Fail "git diff failed with exit code $LASTEXITCODE."
    }

    Invoke-Native -FilePath $GitPath -Arguments @("-C", $VaultPath, "branch", "-M", "main")
    Invoke-Native -FilePath $GitPath -Arguments @("-C", $VaultPath, "push", "-u", "origin", "main")
    Ok "Vault pushed to GitHub"
}

Write-Host ""
Write-Host "Obsidian AI Starter — Windows setup" -ForegroundColor Magenta
Write-Host ""

if ($PSVersionTable.PSEdition -eq "Core" -and -not $IsWindows) {
    Fail "This script supports Windows only. Use scripts/setup.sh on macOS."
}

if (-not (Test-Path $VaultPath -PathType Container)) {
    Fail "Vault path not found: $VaultPath"
}
$VaultPath = (Resolve-Path $VaultPath).Path
if (-not (Test-Path (Join-Path $VaultPath ".obsidian") -PathType Container)) {
    Fail "The selected folder is not an Obsidian vault: .obsidian is missing."
}
Ok "Vault verified: $VaultPath"

$NodePath = Require-Command "node"
$NpmPath = Require-Command "npm.cmd"
$GitPath = Require-Command "git.exe"

$Bash = Get-Command "bash.exe" -ErrorAction SilentlyContinue
if (-not $Bash) {
    $GitBash = Join-Path $env:ProgramFiles "Git\bin\bash.exe"
    if (-not (Test-Path $GitBash)) {
        Fail "Pi requires bash on Windows. Install Git for Windows, then run this script again."
    }
}
Ok "Git Bash available"

$NodeVersionText = (Get-NativeOutput -FilePath $NodePath -Arguments @("-p", "process.versions.node") | Out-String).Trim()
$NodeVersion = [version]$NodeVersionText
if ($NodeVersion -lt $MinNodeVersion) {
    Fail "Node.js $MinNodeVersion or newer is required. Found $NodeVersion."
}
Ok "Node.js $NodeVersion"

Log "Installing Pi $PiVersion..."
Invoke-Native -FilePath $NpmPath -Arguments @(
    "install", "-g", "--ignore-scripts", "@earendil-works/pi-coding-agent@$PiVersion"
)
$PiCommand = Get-Command "pi.cmd" -ErrorAction SilentlyContinue
if (-not $PiCommand) {
    Fail "Pi installed but pi.cmd was not found on PATH."
}
$PiPath = $PiCommand.Source
Ok "Pi installed at $PiPath"

Log "Installing pi-obsidian-vault $VaultPackageVersion..."
Invoke-Native -FilePath $PiPath -Arguments @("install", "npm:pi-obsidian-vault@$VaultPackageVersion")
Ok "Vault tools installed"

if (-not (Test-Path $PatchFile -PathType Leaf)) {
    Fail "Required patch not found: $PatchFile"
}

$BuildRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("obsidian-ai-starter-" + [guid]::NewGuid())
$PluginDir = Join-Path $BuildRoot "obsidian-pi-plugin"
New-Item -ItemType Directory -Force $PluginDir | Out-Null

try {
    Log "Fetching the pinned Obsidian Pi plugin..."
    Invoke-Native -FilePath $GitPath -Arguments @("init", $PluginDir)
    Invoke-Native -FilePath $GitPath -Arguments @("-C", $PluginDir, "remote", "add", "origin", $PluginRepository)
    Invoke-Native -FilePath $GitPath -Arguments @("-C", $PluginDir, "fetch", "--depth", "1", "origin", $PluginRef)
    Invoke-Native -FilePath $GitPath -Arguments @("-C", $PluginDir, "checkout", "--detach", "FETCH_HEAD")
    Invoke-Native -FilePath $GitPath -Arguments @("-C", $PluginDir, "apply", $PatchFile)
    Ok "Plugin source prepared"

    Log "Building the Obsidian plugin..."
    Invoke-Native -FilePath $NpmPath -Arguments @("--prefix", $PluginDir, "ci", "--ignore-scripts")
    Invoke-Native -FilePath $NpmPath -Arguments @("--prefix", $PluginDir, "run", "build")
    Ok "Plugin built"

    $DestDir = Join-Path $VaultPath ".obsidian\plugins\pi-plugin"
    New-Item -ItemType Directory -Force $DestDir | Out-Null
    Copy-Item (Join-Path $PluginDir "main.js") (Join-Path $DestDir "main.js") -Force
    Copy-Item (Join-Path $PluginDir "styles.css") (Join-Path $DestDir "styles.css") -Force
    Copy-Item (Join-Path $PluginDir "manifest.json") (Join-Path $DestDir "manifest.json") -Force
    Set-PluginData -DataPath (Join-Path $DestDir "data.json") -PiBinaryPath $PiPath
    Ok "Plugin installed in the vault"
}
finally {
    if (Test-Path $BuildRoot) {
        Remove-Item $BuildRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Push-PrivateBackup

Write-Host ""
Write-Host "Setup complete." -ForegroundColor Green
Write-Host "Next: open README.md or README.zh-CN.md and finish the steps under 'Finish in Obsidian'."
