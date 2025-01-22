# Get system temp path
$TempPath = [System.IO.Path]::GetTempPath()
# Set URL for OOSU10 executable
$OosuUrl = "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe"
# Set path for downloaded OOSU10 executable
$OosuExe = Join-Path $TempPath "OOSU10.exe"
# Set path for OOSU10 configuration file
$ConfigPath = Join-Path (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)) "config\ooshutup10.cfg"

# Download OOSU10
Invoke-WebRequest -Uri $OosuUrl -OutFile $OosuExe
# Run OOSU10 with configuration file
Start-Process -FilePath $OosuExe -ArgumentList "`"$ConfigPath`" /quiet" -Wait
# Remove OOSU10 executable
Remove-Item -Path $OosuExe -Force

Write-Output "OOSU10 configuration completed successfully."
