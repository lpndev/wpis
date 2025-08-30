# Windows Post Install Scripts

WPIS (Windows Post Install Scripts) is a PowerShell-based setup tool designed to streamline and optimize a fresh Windows installation.

It helps users debloat unnecessary apps, automatically configure privacy and security settings, apply recommended tweaks with **O&O ShutUp10++**, and install essential software packages via **Winget**. For additional customization, it can also run the [Chris Titus Tech Windows Utility](https://christitus.com/win).

In short, WPIS reduces the time and effort needed after a clean Windows install by automating repetitive setup tasks.

## 🚀 Getting Started

### Prerequisites

- Windows 10 or Windows 11
- Run PowerShell as **Administrator**
- Winget (test with `winget -v` to confirm it is installed)
- Internet connection (for downloading scripts and packages)

### Launch Command

```powershell
irm "https://lpndev.github.io/wpis/main.ps1" | iex
```

## License

Licensed under the [MIT](https://github.com/lpndev/wpis/blob/main/LICENSE) license.
