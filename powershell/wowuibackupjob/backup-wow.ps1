## Script to backup WoW WTF Folder for addon configs & pull inventory of currently installed addons
## compress to zip and copy to onedrive


## Param setup, paths, variables etc
$SourceWTF = "C:\Games\World of Warcraft\_retail_\WTF"
$SourceAddOns = "C:\Games\World of Warcraft\_retail_\Interface\AddOns"
$BackupBase = "C:\Users\JakeC\OneDrive\WoW_UI_Backup"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$TempFolder = "C:\temp\WoW_Backup_$Timestamp"
$TempZipPath = "C:\temp\WoW_Backup_$Timestamp.zip"
$FinalZipPath = Join-Path $BackupBase "WoW_Backup_$Timestamp.zip"  ## Final destination

Write-Host "Starting WoW backup..." -ForegroundColor Green
Write-Host "Temp staging: $TempFolder" -ForegroundColor Cyan
Write-Host "Final destination: $FinalZipPath" -ForegroundColor Cyan

## Create temp directory (local for speed)
New-Item -ItemType Directory -Path $TempFolder -Force

## Get WTF files and backup to temp location first
if (Test-Path $SourceWTF) {
    Write-Host "Backing up WTF folder..." -ForegroundColor Yellow
    $WTFBackup = Join-Path $TempFolder "WTF"
    Copy-Item -Path $SourceWTF -Destination $WTFBackup -Recurse -Force
    Write-Host "WTF folder copied to temp location" -ForegroundColor Green
} else {
    Write-Host "WTF folder not found at: $SourceWTF" -ForegroundColor Red
}

## Get Addons inventory 
if (Test-Path $SourceAddOns) {
    Write-Host "Creating AddOns inventory..." -ForegroundColor Yellow
    $AddOnList = Get-ChildItem -Path $SourceAddOns -Directory | Select-Object Name
    $AddOnListPath = Join-Path $TempFolder "AddOns_List.txt"
    
    $AddOnList | ForEach-Object { $_.Name } | Out-File -FilePath $AddOnListPath -Encoding UTF8
    
    $Count = $AddOnList.Count
    Write-Host "AddOns inventory created ($Count addons found)" -ForegroundColor Green
} else {
    Write-Host "AddOns folder not found at: $SourceAddOns" -ForegroundColor Red
}

## Compress the backup locally
Write-Host "Compressing backup files..." -ForegroundColor Yellow

try {
    Compress-Archive -Path "$TempFolder\*" -DestinationPath $TempZipPath -CompressionLevel Optimal
    
    ## File size data for nerds
    $OriginalSize = (Get-ChildItem -Path $TempFolder -Recurse | Measure-Object -Property Length -Sum).Sum
    $CompressedSize = (Get-Item $TempZipPath).Length
    $CompressionRatio = [math]::Round((($OriginalSize - $CompressedSize) / $OriginalSize) * 100, 1)
    
    Write-Host "Compression completed successfully!" -ForegroundColor Green
    Write-Host "Original size: $([math]::Round($OriginalSize/1MB, 1)) MB" -ForegroundColor Cyan
    Write-Host "Compressed size: $([math]::Round($CompressedSize/1MB, 1)) MB" -ForegroundColor Cyan
    Write-Host "Space saved: $CompressionRatio%" -ForegroundColor Cyan
    
    ## Copy zip to OneDrive
    Write-Host "Copying ZIP to OneDrive backup folder..." -ForegroundColor Yellow
    Copy-Item -Path $TempZipPath -Destination $FinalZipPath -Force
    Write-Host "ZIP copied to OneDrive successfully!" -ForegroundColor Green
    
    ## Clean up temp files
    Write-Host "Cleaning up temp files..." -ForegroundColor Yellow
    Remove-Item -Path $TempFolder -Recurse -Force
    Remove-Item -Path $TempZipPath -Force
    Write-Host "temp files cleaned up" -ForegroundColor Green
    
} catch {
    Write-Host "Backup process failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "temp files left in: $TempFolder" -ForegroundColor Yellow
}

Write-Host "Backup completed successfully!" -ForegroundColor Green