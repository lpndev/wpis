<#
.SYNOPSIS
  Web-based main script to set up user environment and install packages.
.DESCRIPTION
  Fetches and executes setup scripts directly from GitHub Pages:
  - Configure Quick Access, O&O ShutUp10++, privacy tweaks, etc.
  - Installs essential software packages via Winget
  - Optionally runs Chris Titus Tech WinUtil with custom config
  Nothing is required locally except PowerShell + Winget.
  It must be run as an administrator.
#>

#Requires -RunAsAdministrator

$BaseUrl = 'https://lpndev.github.io/wpis/scripts'

function Invoke-RemoteScript {
  param ([string]$Name)

  $Url = "$BaseUrl/$Name"
  try {
    Write-Output "Fetching and executing $Name..."
    $ScriptContent = (Invoke-WebRequest -Uri $Url -UseBasicParsing).Content
    Invoke-Expression $ScriptContent
  }
  catch {
    Write-Warning "Failed to execute $Name from $Url. Check your internet connection and try again."
  }
}

# List of scripts to run (in order)
$Scripts = @(
  'Install-Packages.ps1',
  'Configure-OOSU10.ps1',
  'Winutil-Configuration.ps1'
)

foreach ($Script in $Scripts) {
  $Response = Read-Host "Do you want to run $Script? [Y/n]"
  if ([string]::IsNullOrEmpty($Response) -or $Response.ToLower() -eq 'y') {
    Invoke-RemoteScript -Name $Script
  }
}

Write-Output 'Main script execution completed successfully.'
