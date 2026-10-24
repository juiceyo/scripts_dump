## Full restart of the Zigbee chain: usbipd attach -> WSL ser2net -> ready for Z2M restart
## Run as Administrator whenever things are misbehaving


## Param setup
$HWID = "10c4:ea60"

Write-Host ""
Write-Host "Zigbee Full Chain Restart" -ForegroundColor Cyan
Write-Host ""

## Check running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERROR] This script must be run as Administrator." -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'." -ForegroundColor Yellow
    exit 1
}

## Detach the dongle first for a clean slate
Write-Host "[1/7] Detaching dongle..." -ForegroundColor Yellow
try {
    usbipd detach --busid (usbipd list | Select-String $HWID | ForEach-Object { ($_ -split '\s+')[0] }) 2>&1 | Out-Null
} catch {}
Write-Host "      Done." -ForegroundColor Green

## Shut down WSL entirely so the network stack is rebuilt
Write-Host "[2/7] Shutting down WSL..." -ForegroundColor Yellow
wsl --shutdown
Start-Sleep -Seconds 5
Write-Host "      Done." -ForegroundColor Green

## WSL needs to be up before usbipd can attach to it
Write-Host "[3/7] Booting WSL back up..." -ForegroundColor Yellow
wsl -e true | Out-Null
Start-Sleep -Seconds 3
Write-Host "      Done." -ForegroundColor Green

Write-Host "[4/7] Re-attaching Zigbee dongle to WSL..." -ForegroundColor Yellow
try {
    $result = usbipd attach --wsl --hardware-id $HWID 2>&1
    Write-Host "      $result" -ForegroundColor Gray
} catch {
    Write-Host "[WARNING] usbipd attach failed: $_" -ForegroundColor Red
}
Start-Sleep -Seconds 2
Write-Host "      Done." -ForegroundColor Green

Write-Host "[5/7] Confirming dongle is visible inside WSL..." -ForegroundColor Yellow
$check = wsl -e bash -c "ls /dev/ttyUSB0 2>/dev/null"
if ($check) {
    Write-Host "      Dongle visible at $check" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Dongle not yet visible, waiting a few more seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
}

## Passwordless sudo is assumed, otherwise it prompts once
Write-Host "[6/7] Starting ser2net in WSL..." -ForegroundColor Yellow
wsl -e bash -c "sudo pkill ser2net 2>/dev/null; sleep 1; sudo -n ser2net -c /etc/ser2net.yaml || sudo ser2net -c /etc/ser2net.yaml" 2>&1 | Out-Null
Start-Sleep -Seconds 3
Write-Host "      Done." -ForegroundColor Green

Write-Host "[7/7] Verifying port 7638 and dongle presence..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
$listening = wsl -e bash -c "ss -tlnp 2>/dev/null | grep 7638"
$device = wsl -e bash -c "ls -la /dev/ttyUSB0 2>/dev/null"

if ($listening) {
    Write-Host "      Port 7638 is listening." -ForegroundColor Green
} else {
    Write-Host "[WARNING] Port 7638 not detected." -ForegroundColor Red
}

if ($device) {
    Write-Host "      Dongle present: $device" -ForegroundColor Green
} else {
    Write-Host "[WARNING] /dev/ttyUSB0 not found. Check dongle is plugged in." -ForegroundColor Red
}

Write-Host ""
Write-Host "Chain rebuilt. Now restart the Zigbee2MQTT add-on in HA." -ForegroundColor Green
Write-Host ""
