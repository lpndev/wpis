function Add-ToQuickAccess {
  $shell = New-Object -ComObject Shell.Application
  $quickAccess = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items()

  $foldersToPin = @(
    "Games",
    "Portable",
    "Virtual-Machines"
  )

  $confirm = Read-Host "Do you want to pin folders to Quick Access? (Y/N)"
  if ($confirm -ne 'Y') {
    Write-Host "Skipping pinning folders to Quick Access." -ForegroundColor Yellow
    return
  }

  $progress = 0
  $totalItems = $foldersToPin.Count + 1  # +1 for Recycle Bin

  foreach ($folder in $foldersToPin) {
    $progress++
    $status = "Pinning folder: $folder"
    Write-Progress -Activity "Pinning to Quick Access" -Status $status -PercentComplete (($progress / $totalItems) * 100)

    $path = Join-Path $env:USERPROFILE $folder
    if (Test-Path $path) {
      $item = $shell.Namespace($path).Self
      if ($quickAccess | Where-Object { $_.Path -eq $item.Path }) {
        Write-Host "Folder already pinned: $path" -ForegroundColor Yellow
      }
      else {
        try {
          $item.InvokeVerb("pintohome")
          Write-Host "Pinned folder to Quick Access: $path" -ForegroundColor Green
        }
        catch {
          Write-Host "Error pinning folder to Quick Access: $path" -ForegroundColor Red
        }
      }
    }
    else {
      Write-Host "Folder not found: $path" -ForegroundColor Red
    }
  }

  # Pin Recycle Bin
  $progress++
  $status = "Pinning Recycle Bin"
  Write-Progress -Activity "Pinning to Quick Access" -Status $status -PercentComplete (($progress / $totalItems) * 100)

  $recycleBin = $shell.Namespace(0xA).Items() | Where-Object { $_.Name -eq "Recycle Bin" }
  if ($quickAccess | Where-Object { $_.Name -eq "Recycle Bin" }) {
    Write-Host "Recycle Bin already pinned" -ForegroundColor Yellow
  }
  else {
    try {
      $recycleBin.InvokeVerb("pintohome")
      Write-Host "Pinned Recycle Bin to Quick Access" -ForegroundColor Green
    }
    catch {
      Write-Host "Error pinning Recycle Bin to Quick Access" -ForegroundColor Red
    }
  }

  Write-Progress -Activity "Pinning to Quick Access" -Completed
}