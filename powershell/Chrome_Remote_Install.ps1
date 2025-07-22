## Paramsetup
$installerPath = "C:\Temp\ChromeSetup.exe"
$machineNames = Get-Content "C:\Temp\Machines.txt" ## list of machine names in a text file - 1 per line

foreach ($machine in $machineNames) {
    Invoke-Command -ComputerName $machine -ScriptBlock {
        param(
            $InstallerPath
        )
        if (Test-Path $InstallerPath) {
            Start-Process -FilePath $InstallerPath -ArgumentList "/silent /install" -Wait
        } else {
            Write-Host "Installer not found on $($env:COMPUTERNAME)"
        }
    } -ArgumentList $installerPath
}