<#
.SYNOPSIS
    Bulk delete multiple Active Directory users using a CSV file.

.DESCRIPTION
    This script removes specific user accounts from Active Directory based on 
    usernames listed in a CSV file. It confirms existence before deletion and logs 
    results for reference.

.NOTES
    - Requires RSAT: Active Directory module installed
    - Run as a domain administrator
    - Intended for controlled deletions (lab cleanup or bulk removals)

.EXAMPLE
    .\Delete-Multi-ADUsers.ps1
    (Provide CSV file path when prompted)
#>

param (
    [string]$CsvPath = $(Read-Host "Enter path to CSV file with 'Username' column")
)

# Import AD module
Import-Module ActiveDirectory

# Validate file path
if (-not (Test-Path $CsvPath)) {
    Write-Host "CSV file not found at: $CsvPath" -ForegroundColor Red
    exit
}

# Import users from CSV
$users = Import-Csv -Path $CsvPath

# Log setup
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logPath = Join-Path $scriptPath "Delete-Logs"
if (!(Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath | Out-Null }
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = "$logPath\delete-multi-$timestamp.txt"

Write-Host "`nStarting bulk deletion process..." -ForegroundColor Cyan

foreach ($entry in $users) {
    $username = $entry.Username

    # Verify user exists
    $user = Get-ADUser -Filter { SamAccountName -eq $username } -ErrorAction SilentlyContinue

    if ($user) {
        try {
            Remove-ADUser -Identity $user -Confirm:$false
            Write-Host "Deleted user: $username" -ForegroundColor Green
            "Deleted user: $username" | Out-File -FilePath $logFile -Append
        }
        catch {
            Write-Host "Error deleting user: $username - $_" -ForegroundColor Red
            "Error deleting user: $username - $_" | Out-File -FilePath $logFile -Append
        }
    }
    else {
        Write-Host "User not found: $username" -ForegroundColor Yellow
        "User not found: $username" | Out-File -FilePath $logFile -Append
    }
}

Write-Host "`nBulk deletion process completed. Log saved to $logFile" -ForegroundColor Cyan