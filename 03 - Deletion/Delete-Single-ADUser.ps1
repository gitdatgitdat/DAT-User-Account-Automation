<#
.SYNOPSIS
    Permanently delete a single Active Directory user.

.DESCRIPTION
    This script removes a specified user account from Active Directory.
    It bypasses the disabling or moving step and deletes the account outright,
    intended for cleanup operations where retention is unnecessary.

.NOTES
    - Requires RSAT: Active Directory module installed
    - Run as a domain administrator
    - Use carefully — deletion is immediate and irreversible

.EXAMPLE
    .\Delete-Single-ADUser.ps1
    Enter the username (SAMAccountName or UPN) when prompted
#>

param (
    [string]$SamAccountName
)

# Prompt for username if not supplied
if (-not $SamAccountName) {
    $SamAccountName = Read-Host "Enter the SAMAccountName or UPN of the user to delete"
}

# Import AD module
Import-Module ActiveDirectory

# Verify the user exists
$user = Get-ADUser -Filter { SamAccountName -eq $SamAccountName } -ErrorAction SilentlyContinue

if (-not $user) {
    Write-Host "User '$SamAccountName' not found. Check spelling or search with Get-ADUser." -ForegroundColor Red
    exit
}

# Display the DN for context
Write-Host "`nUser found in: $($user.DistinguishedName)" -ForegroundColor Cyan

# Confirm deletion
$confirmation = Read-Host "Are you sure you want to DELETE '$SamAccountName'? (Y/N)"
if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    Remove-ADUser -Identity $user -Confirm:$false
    Write-Host "User '$SamAccountName' removed successfully." -ForegroundColor Green
} else {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
}