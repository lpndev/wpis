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

# Requires running as Administrator
#Requires -RunAsAdministrator

# --- Variables ---
$TempPath = [System.IO.Path]::GetTempPath()
$OosuUrl = 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe'
$OosuConfigUrl = 'https://raw.githubusercontent.com/lpndev/wpis/main/config/ooshutup10.cfg'
$WinUtilConfigUrl = 'https://raw.githubusercontent.com/lpndev/wpis/main/config/winutil-config.json'
$AppsUrl = 'https://raw.githubusercontent.com/lpndev/wpis/main/config/apps.txt'
$VcRedistUrl = 'https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe'

# --- Functions ---

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

function Invoke-WinUtil {
  param()

  $ConfigFile = Join-Path $TempPath 'winutil-config.json'
  Save-File -Url $WinUtilConfigUrl -OutFile $ConfigFile

  Write-Output 'Launching WinUtil...'
  try {
    Invoke-RestMethod 'https://christitus.com/win' | Invoke-Expression
  }
  catch {
    Write-Warning "Failed to launch WinUtil: $($_)"
    return
  }

  $WinUtilPath = "$env:LOCALAPPDATA\Temp\WinUtil\winutil.ps1"
  $MaxWait = 60
  $Elapsed = 0
  while (-not (Test-Path $WinUtilPath) -and $Elapsed -lt $MaxWait) {
    Start-Sleep -Seconds 1
    $Elapsed++
  }

  if (Test-Path $WinUtilPath) {
    Write-Output 'Running WinUtil with custom configuration...'
    & $WinUtilPath -Config $ConfigFile
  }
  else {
    Write-Warning "WinUtil script not found after $MaxWait seconds."
  }
}

# --- Main Execution ---

try {
  # 1. Configure O&O ShutUp10++
  $runOOSU = Read-Host 'Do you want to configure O&O ShutUp10++? [Y/n]'
  if ([string]::IsNullOrEmpty($runOOSU) -or $runOOSU.ToLower() -eq 'y') {
    Set-OOSU10Config
  }

  # 2. Install Visual C++ Redistributable
  $runVcRedist = Read-Host 'Do you want to install Visual C++ Redistributable? [Y/n]'
  if ([string]::IsNullOrEmpty($runVcRedist) -or $runVcRedist.ToLower() -eq 'y') {
    Install-VcRedist
  }

  # 3. Install apps from apps.txt
  $Apps = (Invoke-RestMethod -Uri $AppsUrl -UseBasicParsing) -split '\r?\n' | Where-Object { $_ -ne '' }
  $runApps = Read-Host 'Do you want to install all apps from the list? [Y/n]'
  if ([string]::IsNullOrEmpty($runApps) -or $runApps.ToLower() -eq 'y') {
    Install-WingetApps -Apps $Apps
  }

  # 4. Run WinUtil
  $runWinUtil = Read-Host 'Do you want to run WinUtil with custom configuration? [Y/n]'
  if ([string]::IsNullOrEmpty($runWinUtil) -or $runWinUtil.ToLower() -eq 'y') {
    Invoke-WinUtil
  }

  Write-Output 'Main script execution completed successfully.'

}
catch {
  Write-Error "An unexpected error occurred: $($_)"
}
