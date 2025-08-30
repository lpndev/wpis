# Check if Winget is available
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error 'Winget is not installed. Please install Winget before running this script.'
  exit 1
}

# Load apps.txt from GitHub
$AppsUrl = 'https://lpndev.github.io/wpis/scripts/apps.txt'
try {
  $Apps = (Invoke-RestMethod -Uri $AppsUrl) -split '\r?\n'
}
catch {
  Write-Error "Failed to fetch apps.txt from $AppsUrl"
  exit 1
}

# Ask user about Visual C++ Redistributable
$InstallVcRedist = Read-Host 'Do you want to download and install Visual C++ Redistributable? (Y/n)'

if ([string]::IsNullOrEmpty($InstallVcRedist) -or $InstallVcRedist.ToLower() -eq 'y') {
  $TempPath = [System.IO.Path]::GetTempPath()
  $VcRedistUrl = 'https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe'
  $VcRedistInstaller = Join-Path $TempPath 'VisualCppRedist_AIO_x86_x64.exe'

  try {
    Write-Output 'Downloading Visual C++ Redistributable...'
    Invoke-WebRequest -Uri $VcRedistUrl -OutFile $VcRedistInstaller -ErrorAction Stop

    Write-Output 'Installing Visual C++ Redistributable...'
    Start-Process -FilePath $VcRedistInstaller -ArgumentList '/ai /gm2' -Wait

    Remove-Item -Path $VcRedistInstaller -Force
    Write-Output 'Visual C++ Redistributable installation completed.'
  }
  catch {
    Write-Warning 'Failed to install Visual C++ Redistributable.'
  }
}
else {
  Write-Output 'Skipping Visual C++ Redistributable installation.'
}

# Install each app with progress tracking
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

Write-Output 'Packages installation completed successfully.'
