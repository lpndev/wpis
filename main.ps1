<#
.SYNOPSIS
    Complete setup script for Windows environment.
.DESCRIPTION
    - Configures O&O ShutUp10++ with remote config
    - Installs Visual C++ Redistributable (optional)
    - Installs apps listed in remote apps.txt via Winget
    - Runs Chris Titus Tech WinUtil with remote configuration
    Fully web-based: no local scripts required. Admin privileges required.
#>

#Requires -RunAsAdministrator

# Variables
$TempPath = [System.IO.Path]::GetTempPath()
$OosuUrl = 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe'
$OosuConfigUrl = 'https://raw.githubusercontent.com/lpndev/wpis/main/config/ooshutup10.cfg'
$WinUtilConfigUrl = 'https://raw.githubusercontent.com/lpndev/wpis/main/config/winutil-config.json'
$AppsUrl = 'https://raw.githubusercontent.com/lpndev/wpis/main/config/apps.txt'
$VcRedistUrl = 'https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe'

# Functions
function Invoke-WindowsUpdate {
  try {
    Write-Output 'Initiating Windows Update scan/download/install...'
    Start-Process -FilePath 'UsoClient.exe' -ArgumentList 'StartScan' -WindowStyle Hidden -Wait
    Start-Process -FilePath 'UsoClient.exe' -ArgumentList 'StartDownload' -WindowStyle Hidden -Wait
    Start-Process -FilePath 'UsoClient.exe' -ArgumentList 'StartInstall' -WindowStyle Hidden -Wait
    Write-Output 'Windows Update initiated (you may be prompted to reboot).'
  }
  catch {
    Write-Warning "Failed to start Windows Update: $($_)"
  }
}

function Save-File {
  param(
    [string]$Url,
    [string]$OutFile
  )
  try {
    Write-Output "Downloading $Url ..."
    Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -ErrorAction Stop
  }
  catch {
    throw "Failed to download ${Url}: ${_}"
  }
}

function Install-VcRedist {
  param()

  $VcRedistExe = Join-Path $TempPath 'VisualCppRedist_AIO_x86_x64.exe'
  Save-File -Url $VcRedistUrl -OutFile $VcRedistExe
  Write-Output 'Installing Visual C++ Redistributable...'
  Start-Process -FilePath $VcRedistExe -ArgumentList '/ai /gm2' -Wait
  Remove-Item -Path $VcRedistExe -Force
  Write-Output 'Visual C++ Redistributable installed.'
}

function Set-OOSU10Config {
  param()

  $OosuExe = Join-Path $TempPath 'OOSU10.exe'
  $ConfigFile = Join-Path $TempPath 'ooshutup10.cfg'

  Save-File -Url $OosuUrl -OutFile $OosuExe
  Save-File -Url $OosuConfigUrl -OutFile $ConfigFile

  Write-Output 'Applying O&O ShutUp10++ configuration...'
  Start-Process -FilePath $OosuExe -ArgumentList "`"$ConfigFile`" /quiet" -Wait
  Remove-Item -Path $OosuExe -Force
  Write-Output 'O&O ShutUp10++ configuration completed.'
}

function Install-WingetApps {
  param([string[]]$Apps)

  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'Winget is not installed. Install Winget first.'
  }

  $i = 0
  foreach ($App in $Apps) {
    $i++
    Write-Progress -Activity 'Installing applications...' -Status $App -PercentComplete (($i / $Apps.Count) * 100)
    try {
      winget install $App --silent --accept-package-agreements --accept-source-agreements -e
    }
    catch {
      Write-Warning "Failed to install $App"
    }
  }
  Write-Progress -Activity 'Installing applications...' -Completed
  Write-Output 'All applications installed.'
}

function Invoke-WinUtil {
  param()

  $ConfigFile = Join-Path $TempPath 'winutil-config.json'
  Save-File -Url $WinUtilConfigUrl -OutFile $ConfigFile

  Write-Output 'Launching WinUtil with custom configuration...'
  try {
    $cmd = "& { `$(irm https://christitus.com/win) } -Config `"$ConfigFile`" -Run"
    Invoke-Expression $cmd
  }
  catch {
    Write-Warning "Failed to run WinUtil with config: $($_)"
  }
}

# Main Execution
try {
  # Check for Windows updates
  $runWU = Read-Host 'Do you want to check for Windows Updates now? [Y/n]'
  if ([string]::IsNullOrEmpty($runWU) -or $runWU.ToLower() -eq 'y') {
    Invoke-WindowsUpdate
  }

  # Install Visual C++ Redistributable
  $runVcRedist = Read-Host 'Do you want to install Visual C++ Redistributable? [Y/n]'
  if ([string]::IsNullOrEmpty($runVcRedist) -or $runVcRedist.ToLower() -eq 'y') {
    Install-VcRedist
  }
  
  # Configure O&O ShutUp10++
  $runOOSU = Read-Host 'Do you want to configure O&O ShutUp10++? [Y/n]'
  if ([string]::IsNullOrEmpty($runOOSU) -or $runOOSU.ToLower() -eq 'y') {
    Set-OOSU10Config
  }

  # Install apps from apps.txt
  $Apps = (Invoke-RestMethod -Uri $AppsUrl -UseBasicParsing) -split '\r?\n' |
  ForEach-Object { $_.Trim() } | Where-Object { $_ }
  $runApps = Read-Host 'Do you want to install all apps from the list? [Y/n]'
  if ([string]::IsNullOrEmpty($runApps) -or $runApps.ToLower() -eq 'y') {
    Install-WingetApps -Apps $Apps
  }

  # Run WinUtil
  $runWinUtil = Read-Host 'Do you want to run WinUtil with custom configuration? [Y/n]'
  if ([string]::IsNullOrEmpty($runWinUtil) -or $runWinUtil.ToLower() -eq 'y') {
    Invoke-WinUtil
  }

  Write-Output 'Main script execution completed successfully.'
}
catch {
  Write-Error "An unexpected error occurred: $($_)"
}
