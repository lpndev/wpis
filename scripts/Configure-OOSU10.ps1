# Variables
$TempPath = [System.IO.Path]::GetTempPath()
$OosuUrl = 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe'
$ConfigUrl = 'https://lpndev.github.io/wpis/config/ooshutup10.cfg'
$OosuExe = Join-Path $TempPath 'OOSU10.exe'
$ConfigFile = Join-Path $TempPath 'ooshutup10.cfg'

# Download O&O ShutUp10++
Write-Output 'Downloading O&O ShutUp10++...'
Invoke-WebRequest -Uri $OosuUrl -OutFile $OosuExe

# Download configuration file
Write-Output 'Downloading O&O ShutUp10++ config...'
Invoke-WebRequest -Uri $ConfigUrl -OutFile $ConfigFile

# Apply configuration
Write-Output 'Importing O&O ShutUp10++ configuration...'
Start-Process -FilePath $OosuExe -ArgumentList "`"$ConfigFile`" /quiet" -Wait
