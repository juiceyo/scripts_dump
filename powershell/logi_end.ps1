## Get all processes that start with "lghub"
$processes = Get-Process | Where-Object { $_.Name -like "lghub*" }

## Terminate each using the proc id                                                                                                                    
foreach ($process in $processes) {
    try {
        Stop-Process -Id $process.Id -Force
        Write-Host "Terminated process: $($process.Name) (ID: $($process.Id))"
    } catch {
        Write-Host "Failed to terminate process: $($process.Name) (ID: $($process.Id))"
    }
}