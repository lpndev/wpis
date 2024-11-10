function Install-Packages {
  $packages = @{
    "compatibility" = @(
      "EclipseAdoptium.Temurin.17.JRE",
      "EclipseAdoptium.Temurin.21.JRE",
      "EclipseAdoptium.Temurin.8.JRE",
      "Microsoft.DirectX",
      "Microsoft.DotNet.DesktopRuntime.7",
      "Microsoft.DotNet.DesktopRuntime.8",
      "Microsoft.PowerShell",
      "Microsoft.PowerToys",
      "Microsoft.WindowsTerminal",
      "Microsoft.XNARedist",
      "OpenAL.OpenAL"
    )
    "tools"         = @(
      "7zip.7zip",
      "9P7KNL5RWT25", # SysInternals Suite
      "BleachBit.BleachBit",
      "Git.Git",
      "IDRIX.VeraCrypt",
      "LocalSend.LocalSend",
      "MHNexus.HxD",
      "PuTTY.PuTTY",
      "Safing.Portmaster",
      "TechPowerUp.NVCleanstall",
      "voidtools.Everything",
      "Wagnardsoft.DisplayDriverUninstaller",
      "winaero.tweaker",
      "WinDirStat.WinDirStat",
      "WinSCP.WinSCP",
      "yt-dlp.yt-dlp"
    )
    "apps"          = @(
      "9NKSQGP7F2NH", # WhatsApp
      "Anki.Anki",
      "AnyAssociation.Anytype",
      "Audacity.Audacity",
      "Bitwarden.Bitwarden",
      "Discord.Discord",
      "Docker.DockerDesktop",
      "dotPDN.PaintDotNet",
      "Figma.Figma",
      "Google.AndroidStudio",
      "HeroicGamesLauncher.HeroicGamesLauncher",
      "LibreWolf.LibreWolf",
      "Logitech.GHUB",
      "Microsoft.VisualStudioCode",
      "OBSProject.OBSStudio",
      "Proton.ProtonVPN",
      "RevoUninstaller.RevoUninstaller",
      "seerge.g-helper",
      "Spotify.Spotify",
      "Valve.Steam"
    )
  }

  $confirm = Read-Host "Do you want to install packages? (Y/N)"
  if ($confirm -ne 'Y') {
    Write-Host "Skipping package installation." -ForegroundColor Yellow
    return
  }

  # Download and install Visual C++ Redistributable AIO package
  $vcRedistUrl = "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe"
  $vcRedistPath = Join-Path $env:TEMP "VisualCppRedist_AIO_x86_x64.exe"

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

  $totalPackages = ($packages.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
  $progress = 0

  # Install winget packages
  foreach ($category in $packages.Keys | Sort-Object) {
    Write-Host "Installing $category packages..." -ForegroundColor Cyan
    foreach ($package in $packages[$category]) {
      $progress++
      $status = "Installing package: $package"
      $percentComplete = [math]::Min(($progress / $totalPackages) * 100, 100)
      Write-Progress -Activity "Installing Packages" -Status $status -PercentComplete $percentComplete

      try {
        $installed = winget list --id $package --accept-source-agreements | Select-String -Pattern "^$package"
        if ($installed) {
          Write-Host "Package already installed: $package" -ForegroundColor Yellow
        }
        else {
          winget install --id $package --accept-package-agreements --accept-source-agreements
          if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully installed: $package" -ForegroundColor Green
          }
          else {
            Write-Host "Failed to install: $package" -ForegroundColor Red
          }
        }
      }
      catch {
        Write-Host "Error installing package: $package" -ForegroundColor Red
        Write-Host $_.Exception.Message
      }
    }
  }

  Write-Progress -Activity "Installing Packages" -Completed
}