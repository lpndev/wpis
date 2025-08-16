# Check if Winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error 'Winget is not installed. Please install Winget before running this script.'
  exit 1
}

# Variables
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppsFile = Join-Path $ScriptDir 'apps.txt'
$Apps = Get-Content $AppsFile

# Ask user about Visual C++ Redistributable
$InstallVcRedist = Read-Host 'Do you want to download and install Visual C++ Redistributable? (Y/n)'

if ([string]::IsNullOrEmpty($InstallVcRedist) -or $InstallVcRedist.ToLower() -eq 'y') {
  $TempPath = [System.IO.Path]::GetTempPath()
  $VcRedistUrl = 'https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe'
  $VcRedistInstaller = Join-Path $TempPath 'VisualCppRedist_AIO_x86_x64.exe'

  # Download Visual C++ Redistributable
  Write-Output 'Downloading Visual C++ Redistributable...'
  Invoke-WebRequest -Uri $VcRedistUrl -OutFile $VcRedistInstaller

  # Install Visual C++ Redistributable
  Write-Output 'Installing Visual C++ Redistributable...'
  Start-Process -FilePath $VcRedistInstaller -ArgumentList '/ai /gm2' -Wait

  # Remove Visual C++ Redistributable installer
  Remove-Item -Path $VcRedistInstaller -Force
  Write-Output 'Visual C++ Redistributable installation completed.'
}
else {
  Write-Output 'Skipping Visual C++ Redistributable installation.'
}

# Install each app from the apps.txt list using Winget
foreach ($App in $Apps) {
  winget install $App --silent --accept-package-agreements --accept-source-agreements
}

Write-Output 'Packages installation completed successfully.'