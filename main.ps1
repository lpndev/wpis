<#
.SYNOPSIS
    Main script to set up user environment and install packages.
.DESCRIPTION
    This script move all folders inside folders/ directory, pins them to Quick Access (including the Recycle Bin), configure O&O ShutUp10++ with recommended settings and installs essentials packages and some using Winget.
    It must be run as an administrator.
#>

#Requires -RunAsAdministrator

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path # Get the directory of the current script
$Scripts = Get-ChildItem -Path "$ScriptPath\scripts\*.ps1" | Sort-Object Name # Get all .ps1 files in the scripts folder and sort them alphabetically

# Loop through each script and ask user if they want to run it
foreach ($Script in $Scripts) {
  $Response = Read-Host "Run $($Script.Name)? (Y/n)"
  if ([string]::IsNullOrEmpty($Response) -or $Response.ToLower() -eq 'y') {
    . $Script.FullName
  }
}

# Ask if user wants to run Chris Titus Tech script
$Response = Read-Host 'Run Chris Titus Tech script? (Y/n)'
if ([string]::IsNullOrEmpty($Response) -or $Response.ToLower() -eq 'y') {
  Invoke-RestMethod 'https://christitus.com/win' | Invoke-Expression
}

Write-Output 'Main script execution completed successfully.'
