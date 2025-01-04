# Get system temp path
$TempPath = [System.IO.Path]::GetTempPath()
# Set URL for Visual C++ Redistributable
$VcRedistUrl = "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe"
# Set path for downloaded Visual C++ Redistributable installer
$VcRedistInstaller = Join-Path $TempPath "VisualCppRedist_AIO_x86_x64.exe"

# Download Visual C++ Redistributable
Invoke-WebRequest -Uri $VcRedistUrl -OutFile $VcRedistInstaller
# Install Visual C++ Redistributable
Start-Process -FilePath $VcRedistInstaller -ArgumentList "/ai /gm2" -Wait
# Remove Visual C++ Redistributable installer
Remove-Item -Path $VcRedistInstaller -Force

# Get path of the current script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# Set path for apps.txt file
$AppsFile = Join-Path $ScriptDir "apps.txt"
# Read content of apps.txt
$Apps = Get-Content $AppsFile

# Install each app using winget
foreach ($App in $Apps) {
  winget install $App --silent --accept-package-agreements --accept-source-agreements
}

Write-Output "Package installation completed successfully."
