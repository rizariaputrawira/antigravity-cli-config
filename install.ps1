<#
.SYNOPSIS
    Antigravity Configuration Installer for Windows (PowerShell)
.DESCRIPTION
    Supports both:
    1. Local execution inside cloned repository: .\install.ps1
    2. Remote one-liner: irm https://raw.githubusercontent.com/<user>/<repo>/main/install.ps1 | iex
#>

[CmdletBinding()]
param (
    [string]$Workspace = "$HOME\workspaces",
    [string]$Repo = "rizariaputrawira/antigravity-cli-config",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "⚡ Antigravity Portable Configuration Installer (Windows)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Workspace Root: $Workspace"
Write-Host "Dry Run Mode:   $DryRun"
Write-Host ""

# 1. Determine Source Directory (Local repo vs Remote pipe)
$SrcDir = ""
$TempDir = ""

if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "config\AGENTS.md"))) {
    $SrcDir = $PSScriptRoot
    Write-Host "📦 Source: Local repository at $SrcDir" -ForegroundColor Green
} elseif (Test-Path ".\config\AGENTS.md") {
    $SrcDir = (Get-Location).Path
    Write-Host "📦 Source: Local working directory at $SrcDir" -ForegroundColor Green
} else {
    Write-Host "🌐 Source: Remote execution detected. Fetching repository from GitHub ($Repo)..." -ForegroundColor Yellow
    $TempDir = Join-Path $env:TEMP ("antigravity-config-" + [System.Guid]::NewGuid().ToString("N"))
    $ZipPath = Join-Path $env:TEMP "antigravity-config.zip"
    $ZipUrl = "https://github.com/$Repo/archive/refs/heads/main.zip"
    
    Invoke-RestMethod -Uri $ZipUrl -OutFile $ZipPath
    Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force
    Remove-Item -Path $ZipPath -Force -ErrorAction SilentlyContinue
    
    # Locate unpacked folder
    $ExtractedFolder = Get-ChildItem -Path $TempDir -Directory | Select-Object -First 1
    $SrcDir = $ExtractedFolder.FullName
}

# 2. Pre-flight Environment Checks
Write-Host "🔍 Running pre-flight environment checks..." -ForegroundColor Cyan

if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "  ✅ Node.js detected: $(node -v)" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ Warning: 'node' is not found in PATH. MCP servers and hooks require Node.js." -ForegroundColor Yellow
}

if (Get-Command npx -ErrorAction SilentlyContinue) {
    Write-Host "  ✅ npx detected" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ Warning: 'npx' is not found in PATH. Context7, GitHub, and LSP MCP servers require npx." -ForegroundColor Yellow
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "  ✅ git detected: $(git --version)" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ Warning: 'git' is not found in PATH." -ForegroundColor Yellow
}

if ($env:GITHUB_TOKEN) {
    Write-Host "  ✅ GITHUB_TOKEN is present in environment." -ForegroundColor Green
} else {
    Write-Host "  💡 Notice: GITHUB_TOKEN is not currently set in environment." -ForegroundColor Gray
}

# 3. Target Directories & Non-Destructive Backup
$GeminiDir = Join-Path $HOME ".gemini"
$ConfigDir = Join-Path $GeminiDir "config"
$CliDir = Join-Path $GeminiDir "antigravity-cli"

# Normalize workspace path for JSON formatting (forward slashes prevent JSON escaping issues)
$NormalizedWorkspace = $Workspace.Replace("\", "/")

if ($DryRun) {
    Write-Host ""
    Write-Host "🔎 [DRY RUN] Target directories:" -ForegroundColor Yellow
    Write-Host "   - $ConfigDir"
    Write-Host "   - $CliDir"
    Write-Host "   - $Workspace"
    
    if (Test-Path $ConfigDir) {
        Write-Host "🔎 [DRY RUN] Would backup existing configuration to $HOME\.gemini.bak.<timestamp>" -ForegroundColor Yellow
    }
    
    $DetectedHostname = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } elseif ($env:HOSTNAME) { $env:HOSTNAME } else { "localhost" }
    Write-Host "🔎 [DRY RUN] Would render templates:" -ForegroundColor Yellow
    Write-Host "   - config.json.template -> $ConfigDir\config.json (hostname: $DetectedHostname)"
    Write-Host "   - mcp_config.json.template -> $ConfigDir\mcp_config.json (workspace: $NormalizedWorkspace)"
    Write-Host "   - settings.json.template -> $CliDir\settings.json (if missing)"
    Write-Host "🔎 [DRY RUN] Would copy skills, hooks, and AGENTS.md." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "✅ Dry run completed successfully. Zero changes were made." -ForegroundColor Green
    
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    return
}

Write-Host ""
Write-Host "🚀 Proceeding with installation..." -ForegroundColor Cyan

# Backup existing configuration if present
if (Test-Path $ConfigDir) {
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $BackupDir = Join-Path $HOME (".gemini.bak." + $Timestamp)
    Write-Host "💾 Creating backup of existing configuration to $BackupDir..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    Copy-Item -Path $ConfigDir -Destination (Join-Path $BackupDir "config") -Recurse -Force
    
    $ExistingSettings = Join-Path $CliDir "settings.json"
    if (Test-Path $ExistingSettings) {
        Copy-Item -Path $ExistingSettings -Destination $BackupDir -Force
    }
}

# Ensure destination directories exist
New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
New-Item -ItemType Directory -Path $CliDir -Force | Out-Null
New-Item -ItemType Directory -Path $Workspace -Force | Out-Null

# 4. Template Rendering
Write-Host "⚙️ Rendering configuration templates..." -ForegroundColor Cyan

# Render config.json
$ConfigTemplatePath = Join-Path $SrcDir "config\config.json.template"
$ConfigJsonContent = Get-Content -Raw -Path $ConfigTemplatePath
$DetectedHostname = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } elseif ($env:HOSTNAME) { $env:HOSTNAME } else { "localhost" }
$ConfigJsonContent = $ConfigJsonContent.Replace('${REMOTE_HOSTNAME}', $DetectedHostname)
Set-Content -Path (Join-Path $ConfigDir "config.json") -Value $ConfigJsonContent -Encoding utf8

# Render mcp_config.json
$McpTemplatePath = Join-Path $SrcDir "config\mcp_config.json.template"
$McpJsonContent = Get-Content -Raw -Path $McpTemplatePath
$McpJsonContent = $McpJsonContent.Replace('${WORKSPACE_ROOT}', $NormalizedWorkspace)
Set-Content -Path (Join-Path $ConfigDir "mcp_config.json") -Value $McpJsonContent -Encoding utf8

# Initialize settings.json if missing
$TargetSettingsPath = Join-Path $CliDir "settings.json"
if (-not (Test-Path $TargetSettingsPath)) {
    Write-Host "⚙️ Initializing $TargetSettingsPath..." -ForegroundColor Cyan
    $SettingsTemplatePath = Join-Path $SrcDir "settings\settings.json.template"
    $SettingsContent = Get-Content -Raw -Path $SettingsTemplatePath
    $SettingsContent = $SettingsContent.Replace('"trustedWorkspaces": []', "`"trustedWorkspaces`": [`"$NormalizedWorkspace`"]")
    Set-Content -Path $TargetSettingsPath -Value $SettingsContent -Encoding utf8
} else {
    Write-Host "ℹ️ Existing settings.json preserved at $TargetSettingsPath" -ForegroundColor Gray
}

# 5. Copy Assets
Write-Host "📦 Copying global rules, hooks, and skills..." -ForegroundColor Cyan

Copy-Item -Path (Join-Path $SrcDir "config\AGENTS.md") -Destination (Join-Path $ConfigDir "AGENTS.md") -Force
Copy-Item -Path (Join-Path $SrcDir "config\hooks.json") -Destination (Join-Path $ConfigDir "hooks.json") -Force

# Copy skills
$TargetSkillsDir = Join-Path $ConfigDir "skills"
New-Item -ItemType Directory -Path $TargetSkillsDir -Force | Out-Null
Copy-Item -Path (Join-Path $SrcDir "config\skills\*") -Destination $TargetSkillsDir -Recurse -Force

# Cleanup temp files if remote
if ($TempDir -and (Test-Path $TempDir)) {
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "🎉 Antigravity configuration successfully installed!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Global Config: $ConfigDir"
Write-Host ""
Write-Host "You can now run 'agy' or 'antigravity' in your terminal." -ForegroundColor Cyan
