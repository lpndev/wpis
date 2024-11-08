function New-Folders {
  $folders = @(
    "Games",
    "Portable",
    "Virtual-Machines\Hyper-V",
    "Virtual-Machines\Shared",
    "Virtual-Machines\VirtualBox",
    "Virtual-Machines\VMWare",
    "Virtual-Machines\WSL"
  )

  $confirm = Read-Host "Do you want to create folders? (Y/N)"
  if ($confirm -ne 'Y') {
    Write-Host "Skipping folder creation." -ForegroundColor Yellow
    return
  }

  $progress = 0
  $totalFolders = $folders.Count

  foreach ($folder in $folders) {
    $progress++
    $status = "Creating folder: $folder"
    Write-Progress -Activity "Creating Folders" -Status $status -PercentComplete (($progress / $totalFolders) * 100)

    $path = Join-Path $env:USERPROFILE $folder
    if (Test-Path $path) {
      Write-Host "Folder already exists: $path" -ForegroundColor Yellow
    }
    else {
      try {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
        Write-Host "Created folder: $path" -ForegroundColor Green
      }
      catch {
        Write-Host "Error creating folder: $path" -ForegroundColor Red
      }
    }
  }

  Write-Progress -Activity "Creating Folders" -Completed
}