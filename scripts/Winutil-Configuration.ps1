# Variables
$TempPath = [System.IO.Path]::GetTempPath()
$ConfigUrl = 'https://lpndev.github.io/wpis/config/winutil-config.json'
$ConfigFile = Join-Path $TempPath 'winutil-config.json'

# Download configuration
Write-Output 'Downloading WinUtil config...'
Invoke-WebRequest -Uri $ConfigUrl -OutFile $ConfigFile -UseBasicParsing

# Launch WinUtil from Chris Titus Tech
Write-Output 'Launching WinUtil...'
Invoke-RestMethod 'https://christitus.com/win' | Invoke-Expression

# Wait for WinUtil script to be available
$WinUtilPath = "$env:LOCALAPPDATA\Temp\WinUtil\winutil.ps1"
$MaxWait = 60  # allow up to 60 seconds for extraction
$Elapsed = 0
while (-not (Test-Path $WinUtilPath) -and $Elapsed -lt $MaxWait) {
  Start-Sleep -Seconds 1
  $Elapsed++
}

# Run WinUtil with our downloaded config
if (Test-Path $WinUtilPath) {
  Write-Output 'Running WinUtil with custom configuration...'
  & $WinUtilPath -Config $ConfigFile
}
else {
  Write-Warning "WinUtil script not found after $MaxWait seconds. Cannot apply configuration."
}
