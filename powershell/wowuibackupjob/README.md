# WoW UI Backup Job

Simple PowerShell script to backup World of Warcraft addon configs and create an inventory of installed addons. Compresses to ZIP and saves to OneDrive.

## What It Does

- Backs up entire WTF folder (addon configs, UI settings)
- Creates list of installed addon names  
- Compresses ~470MB down to ~150MB ZIP file
- Saves to OneDrive for cloud backup

## Usage

**Manual:**
```powershell
.\backup-wow.ps1
```

**Scheduled (recommended):**  
Set up Windows Task Scheduler to run daily at 2 AM or whenever.

## Requirements

- WoW installed at `C:\path\to\wow\folder\`
- OneDrive (or any cloud based auto sync) syncing to `C:\path\to\folder\sync\`

## Output

Creates timestamped ZIP files like:
```
WoW_Backup_2025-08-30_14-30-15.zip
```

Each contains your WTF folder + AddOns_List.txt with addon names.

## Notes

- Uses `C:\temp` for fast local compression before copying to OneDrive
- Automatically cleans up temp files
- Typical compression saves 60-80% space