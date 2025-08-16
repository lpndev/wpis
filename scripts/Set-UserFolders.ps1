# Variables
$UserProfile = $env:USERPROFILE
$SourcePath = Join-Path (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)) 'folders'
$Folders = @('Games', 'Portable', 'Virtual-Machines')

# Move each folder and pin to Quick Access
foreach ($Folder in $Folders) {
  $Source = Join-Path $SourcePath $Folder
  $Destination = Join-Path $UserProfile $Folder
  Move-Item -Path $Source -Destination $Destination -Force

  $QuickAccess = New-Object -ComObject Shell.Application
  $QuickAccess.Namespace($Destination).Self.InvokeVerb('PinToHome')
}

# Pin Recycle Bin to Quick Access
$RecycleBin = (New-Object -ComObject Shell.Application).Namespace(0xA)
$RecycleBin.Self.InvokeVerb('PinToHome')

# Remove source folders
Remove-Item -Path $SourcePath -Recurse -Force
Write-Output 'User folders setup completed successfully.'
