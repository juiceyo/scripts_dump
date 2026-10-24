# Home Assistant Zigbee Scripts

PowerShell scripts for running a USB Zigbee dongle on a Windows box and passing it through to Zigbee2MQTT in Home Assistant. The dongle is attached to WSL with usbipd, then exposed over the network with ser2net.

## What It Does

- `setup-zigbee-autostart.ps1` creates two scheduled tasks that attach the dongle and start ser2net on every login
- `restart-zigbee-chain.ps1` tears the whole chain down and rebuilds it when things stop working

## Usage

Both need an elevated PowerShell.

**First time setup:**
```powershell
.\setup-zigbee-autostart.ps1
```

**When Zigbee stops responding:**
```powershell
.\restart-zigbee-chain.ps1
```

Restart the Zigbee2MQTT add-on in Home Assistant afterwards.

## Requirements

- [usbipd-win](https://github.com/dorssel/usbipd-win/releases) installed
- WSL with `ser2net` installed and configured at `/etc/ser2net.yaml`, listening on port 7638
- Passwordless sudo in WSL (otherwise `restart-zigbee-chain.ps1` prompts once)
- Dongle hardware ID set in `$HWID` at the top of each script (`10c4:ea60` is a common Silicon Labs CP210x)

## Notes

- Uses the hardware ID rather than the bus ID, so it still works if the dongle moves to another USB port
- The dongle must be shared once with `usbipd bind --hardware-id <id>` before attaching
