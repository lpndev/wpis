## Documentation

For detailed documentation, visit the [**Wiki**](https://github.com/lpndev/wpis/wiki) tab.

## Getting Started

### Download

1. From **[releases page](https://github.com/lpndev/wpis/releases)**

2. Or remotely:

```powershell
iwr -Uri 'https://github.com/lpndev/wpis/releases/latest/download/wpis.zip' -OutFile "$env:USERPROFILE\Downloads\wpis.zip"; Expand-Archive "$env:USERPROFILE\Downloads\wpis.zip" -DestinationPath "$env:USERPROFILE\Downloads" -Force; powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Downloads\wpis\main.ps1"
```

## License

Licensed under the [MIT](https://github.com/lpndev/emu-starter/blob/main/LICENSE) license.
