<#
.SYNOPSIS
    Main script to set up user environment and install packages.
.DESCRIPTION
    This script creates folders, pins them to Quick Access, and installs packages using winget.
    It must be run as an administrator.
#>

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "This script needs to be run as an Administrator. Attempting to restart..." -ForegroundColor Yellow
  Start-Sleep -Seconds 1
  try {
    Start-Process pwsh.exe -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
  }
  catch {
    Write-Host "Failed to restart as Administrator. Please run this script as an Administrator." -ForegroundColor Red
    Start-Sleep -Seconds 5
  }
  exit
}

# Source the function scripts
. "scripts\New-Folders.ps1"
. "scripts\Add-ToQuickAccess.ps1"
. "scripts\Install-Packages.ps1"

# Run the functions
New-Folders
Add-ToQuickAccess
Install-Packages

# Run Chris Titus Tech script
Write-Host "Running Chris Titus Tech script..." -ForegroundColor Cyan
Invoke-RestMethod "https://christitus.com/win" | Invoke-Expression