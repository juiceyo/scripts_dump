## Sets up scheduled tasks to attach the Zigbee dongle (usbipd) and start ser2net in WSL on login
## Run once as Administrator


## Param setup
$HWID = "10c4:ea60"
$TASK_USBIPD = "USBIPDAttachZigbee"
$TASK_SER2NET = "WSLSer2net"

Write-Host ""
Write-Host "Zigbee Autostart Setup" -ForegroundColor Cyan
Write-Host ""

## Check running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERROR] This script must be run as Administrator." -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'." -ForegroundColor Yellow
    exit 1
}

## Remove old tasks so the script can be re-run safely
Write-Host "[1/6] Cleaning up any existing scheduled tasks..." -ForegroundColor Yellow
foreach ($task in @($TASK_USBIPD, $TASK_SER2NET)) {
    if (Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $task -Confirm:$false
        Write-Host "      Removed existing task: $task" -ForegroundColor Gray
    }
}

Write-Host "[2/6] Creating scheduled task: $TASK_USBIPD..." -ForegroundColor Yellow
$usbipdPath = (Get-Command usbipd -ErrorAction SilentlyContinue).Source
if (-not $usbipdPath) {
    Write-Host "[ERROR] usbipd not found. Is it installed?" -ForegroundColor Red
    Write-Host "Download from: https://github.com/dorssel/usbipd-win/releases" -ForegroundColor Yellow
    exit 1
}

$action1 = New-ScheduledTaskAction -Execute $usbipdPath -Argument "attach --wsl --hardware-id $HWID"
$trigger1 = New-ScheduledTaskTrigger -AtLogOn
$principal1 = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -RunLevel Highest
Register-ScheduledTask -TaskName $TASK_USBIPD -Action $action1 -Trigger $trigger1 -Principal $principal1 -Force | Out-Null
Write-Host "      Done." -ForegroundColor Green

Write-Host "[3/6] Creating scheduled task: $TASK_SER2NET..." -ForegroundColor Yellow
$action2 = New-ScheduledTaskAction -Execute "wsl.exe" -Argument "-e bash -c 'sudo pkill ser2net; sudo ser2net -c /etc/ser2net.yaml'"
$trigger2 = New-ScheduledTaskTrigger -AtLogOn
$principal2 = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -RunLevel Highest
Register-ScheduledTask -TaskName $TASK_SER2NET -Action $action2 -Trigger $trigger2 -Principal $principal2 -Force | Out-Null
Write-Host "      Done." -ForegroundColor Green

## Run both now so a reboot isn't needed
Write-Host "[4/6] Attaching Zigbee dongle (hardware-id $HWID) now..." -ForegroundColor Yellow
try {
    $result = & usbipd attach --wsl --hardware-id $HWID 2>&1
    Write-Host "      $result" -ForegroundColor Gray
    Write-Host "      Done." -ForegroundColor Green
} catch {
    Write-Host "[WARNING] usbipd attach failed: $_" -ForegroundColor Red
    Write-Host "          Make sure the dongle is plugged in." -ForegroundColor Yellow
}

Write-Host "[5/6] Starting ser2net in WSL now..." -ForegroundColor Yellow
try {
    Start-Process "wsl.exe" -ArgumentList "-e bash -c 'sudo pkill ser2net 2>/dev/null; sleep 1; sudo ser2net -c /etc/ser2net.yaml'" -WindowStyle Hidden
    Start-Sleep -Seconds 3
    Write-Host "      Done." -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Failed to start ser2net in WSL: $_" -ForegroundColor Red
}

Write-Host "[6/6] Verifying ser2net is listening on port 7638..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
$listening = wsl -e bash -c "ss -tlnp 2>/dev/null | grep 7638"
if ($listening) {
    Write-Host "      Port 7638 is open and listening." -ForegroundColor Green
} else {
    Write-Host "[WARNING] Port 7638 not detected. ser2net may need a moment, check WSL manually if Z2M still fails." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "All done! Restart Zigbee2MQTT in Home Assistant now." -ForegroundColor Green
Write-Host "The tasks will run automatically on every login." -ForegroundColor Green
Write-Host ""
