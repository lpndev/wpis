function Install-Packages {
  $packageCategories = @("compatibility", "drivers", "utilities", "development", "design-video", "communication-multimedia", "productivity", "gaming")
  $packages = @{
    "compatibility"            = @(
      "EclipseAdoptium.Temurin.17.JRE",
      "EclipseAdoptium.Temurin.21.JRE",
      "EclipseAdoptium.Temurin.8.JRE",
      "Git.Git",
      "Microsoft.DirectX",
      "Microsoft.PowerShell",
      "Microsoft.XNARedist",
      "OpenAL.OpenAL"
    )
    "drivers"                  = @(
      "Logitech.GHUB",
      "seerge.g-helper",
      "Wagnardsoft.DisplayDriverUninstaller"
    )
    "utilities"                = @(
      "7zip.7zip",
      "9P7KNL5RWT25", # SysInternals Suite
      "Bitwarden.Bitwarden",
      "BleachBit.BleachBit",
      "IDRIX.VeraCrypt",
      "LocalSend.LocalSend",
      "MHNexus.HxD",
      "Microsoft.PowerToys",
      "Proton.ProtonVPN",
      "PuTTY.PuTTY",
      "RevoUninstaller.RevoUninstaller",
      "Safing.Portmaster",
      "voidtools.Everything",
      "winaero.tweaker",
      "WinDirStat.WinDirStat",
      "WinSCP.WinSCP",
      "yt-dlp.yt-dlp"
    )
    "development"              = @(
      "Docker.DockerDesktop",
      "Google.AndroidStudio",
      "Microsoft.VisualStudioCode"
    )
    "design-video"             = @(
      "dotPDN.PaintDotNet",
      "Figma.Figma",
      "OBSProject.OBSStudio"
    )
    "communication-multimedia" = @(
      "9NKSQGP7F2NH", # WhatsApp
      "Audacity.Audacity",
      "Discord.Discord",
      "Spotify.Spotify"
    )
    "productivity"             = @(
      "Anki.Anki",
      "AnyAssociation.Anytype"
    )
    "gaming"                   = @(
      "HeroicGamesLauncher.HeroicGamesLauncher",
      "LizardByte.Sunshine",
      "PrismLauncher.PrismLauncher",
      "Valve.Steam"
    )
  }

  $failedPackages = @()

  # Download and install Visual C++ Redistributable AIO package
  $vcRedistUrl = "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe"
  $vcRedistPath = Join-Path $env:TEMP "VisualCppRedist_AIO_x86_x64.exe"

  $confirmVCRedist = Read-Host "Do you want to install Visual C++ Redistributable AIO package? (Y/N)"
  if ($confirmVCRedist -eq 'Y') {
    Write-Host "Downloading Visual C++ Redistributable AIO package..." -ForegroundColor Cyan
    try {
      Invoke-WebRequest -Uri $vcRedistUrl -OutFile $vcRedistPath
      Write-Host "Download completed." -ForegroundColor Green

      Write-Host "Installing Visual C++ Redistributable AIO package..." -ForegroundColor Cyan
      Start-Process -FilePath $vcRedistPath -ArgumentList "/ai /gm2" -Wait -NoNewWindow
      Write-Host "Installation completed." -ForegroundColor Green

      # Clean up the downloaded file
      Remove-Item -Path $vcRedistPath -Force
    }
    catch {
      Write-Host "Error downloading or installing Visual C++ Redistributable AIO package." -ForegroundColor Red
      Write-Host $_.Exception.Message
    }
  }
  else {
    Write-Host "Skipping Visual C++ Redistributable AIO package installation." -ForegroundColor Yellow
  }

  $totalPackages = 0
  $progress = 0

  function Install-Package($package) {
    try {
      $listOutput = winget list --id $package --accept-source-agreements 2>&1
      $installed = $listOutput | Select-String -Pattern "^$package"
      
      if ($installed) {
        # Check if an upgrade is available
        $upgradeOutput = winget upgrade --id $package --accept-source-agreements 2>&1
        if ($upgradeOutput -match "No available upgrade found.") {
          Write-Host "Package already installed and up to date: $package" -ForegroundColor Green
        }
        else {
          Write-Host "Upgrading package: $package" -ForegroundColor Cyan
          winget upgrade --id $package --silent --accept-source-agreements --accept-package-agreements
          Write-Host "Successfully upgraded: $package" -ForegroundColor Green
        }
        return $true
      }
      else {
        Write-Host "Installing package: $package" -ForegroundColor Cyan
        $installOutput = winget install --id $package --silent --accept-package-agreements --accept-source-agreements 2>&1
        if ($LASTEXITCODE -eq 0) {
          Write-Host "Successfully installed: $package" -ForegroundColor Green
          return $true
        }
        else {
          Write-Host "Failed to install: $package" -ForegroundColor Red
          Write-Host $installOutput
          return $false
        }
      }
    }
    catch {
      Write-Host "Error processing package: $package" -ForegroundColor Red
      Write-Host $_.Exception.Message
      return $false
    }
  }

  # Install winget packages
  foreach ($category in $packageCategories) {
    $confirmCategory = Read-Host "Do you want to install $category packages? (Y/N)"
    if ($confirmCategory -eq 'Y') {
      $totalPackages += $packages[$category].Count
      Write-Host "Processing $category packages..." -ForegroundColor Cyan
      foreach ($package in $packages[$category]) {
        $progress++
        $status = "Processing package: $package"
        $percentComplete = [math]::Min(($progress / $totalPackages) * 100, 100)
        Write-Progress -Activity "Processing Packages" -Status $status -PercentComplete $percentComplete

        if (-not (Install-Package $package)) {
          $failedPackages += $package
        }
      }
    }
    else {
      Write-Host "Skipping $category packages." -ForegroundColor Yellow
    }
  }

  Write-Progress -Activity "Processing Packages" -Completed

  # Report on failed packages
  if ($failedPackages.Count -gt 0) {
    Write-Host "The following packages failed to install:" -ForegroundColor Red
    foreach ($package in $failedPackages) {
      Write-Host "  - $package" -ForegroundColor Red
    }
  }
  else {
    Write-Host "All packages were processed successfully." -ForegroundColor Green
  }
}