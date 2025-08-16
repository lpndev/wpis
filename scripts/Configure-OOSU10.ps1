# Variables
$TempPath = [System.IO.Path]::GetTempPath()
$OosuUrl = 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe'
$OosuExe = Join-Path $TempPath 'OOSU10.exe'
$ConfigPath = Join-Path (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)) 'config\ooshutup10.cfg'

# Download O&O ShutUp10++
Write-Output 'Downloading O&O ShutUp10++...'
Invoke-WebRequest -Uri $OosuUrl -OutFile $OosuExe

# Run O&O ShutUp10++ with configuration file
Write-Output 'Importing O&O ShutUp10++ configuration...'
Start-Process -FilePath $OosuExe -ArgumentList "`"$ConfigPath`" /quiet" -Wait

# Remove O&O ShutUp10++ executable
Remove-Item -Path $OosuExe -Force
Write-Output 'OOSU10 configuration completed successfully.'
