function Add-ToQuickAccess {
  $shell = New-Object -ComObject Shell.Application
  $quickAccess = $shell.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items()

  $itemsToPin = @(
    @{Name = "Games"; Path = Join-Path $env:USERPROFILE "Games" },
    @{Name = "Portable"; Path = Join-Path $env:USERPROFILE "Portable" },
    @{Name = "Virtual-Machines"; Path = Join-Path $env:USERPROFILE "Virtual-Machines" },
    @{Name = "Recycle Bin"; Path = "shell:RecycleBinFolder" }  # Updated path for Recycle Bin
  )

  $confirm = Read-Host "Do you want to pin items to Quick Access? (Y/N)"
  if ($confirm -ne 'Y') {
    Write-Host "Skipping pinning items to Quick Access." -ForegroundColor Yellow
    return
  }

  function Set-PinItem($name, $path) {
    $status = "Pinning item: $name"
    Write-Progress -Activity "Pinning to Quick Access" -Status $status

    if ($quickAccess | Where-Object { $_.Name -eq $name }) {
      Write-Host "Item already pinned: $name" -ForegroundColor Yellow
      return
    }

    try {
      if ($name -eq "Recycle Bin") {
        $folder = $shell.Namespace($path)
        $folder.Self.InvokeVerb("pintohome")
      }
      else {
        if (Test-Path $path) {
          $item = $shell.Namespace($path).Self
          $item.InvokeVerb("pintohome")
        }
        else {
          Write-Host "Item not found: $path" -ForegroundColor Red
          return
        }
      }
      Write-Host "Pinned item to Quick Access: $name" -ForegroundColor Green
    }
    catch {
      Write-Host "Error pinning item to Quick Access: $name" -ForegroundColor Red
      Write-Host $_.Exception.Message
    }
  }

  $totalItems = $itemsToPin.Count
  for ($i = 0; $i -lt $totalItems; $i++) {
    $item = $itemsToPin[$i]
    Set-PinItem $item.Name $item.Path
    Write-Progress -Activity "Pinning to Quick Access" -Status "Processing items" -PercentComplete (($i + 1) / $totalItems * 100)
  }

  Write-Progress -Activity "Pinning to Quick Access" -Completed
}