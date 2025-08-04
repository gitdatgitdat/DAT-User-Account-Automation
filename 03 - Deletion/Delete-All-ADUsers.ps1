<#
.SYNOPSIS
    Delete all Active Directory users in the specified Organizational Units (OUs).

.DESCRIPTION
    This script removes every AD user account found in the specified OUs except built-in
    administrator accounts. Designed for **lab environments only** — use with caution.

.NOTES
    - Intended strictly for test/lab environments
    - Requires RSAT: Active Directory module installed
    - Run as a domain administrator
    - Provide distinguished names (DNs) for target OUs as parameters

.EXAMPLE
    .\Delete-All-ADUsers.ps1 -OUs "OU=Standard,OU=Homelab Users,DC=homelab,DC=local","OU=Admins,OU=Homelab Users,DC=homelab,DC=local"
#>

param (
    [Parameter(Mandatory = $true)]
    [string[]]$OUs
)

# Import Active Directory module
Import-Module ActiveDirectory

# Confirmation prompt
do {
    $confirmation = Read-Host "Are you sure you want to DELETE ALL users in the specified OUs? (Y/N)"
} until ($confirmation -match "^[YyNn]$")

if ($confirmation -eq "N" -or $confirmation -eq "n") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

# Iterate through each OU and remove users
foreach ($OU in $OUs) {
    Write-Host "`nRemoving all users from: $OU" -ForegroundColor Cyan
    Get-ADUser -Filter * -SearchBase $OU | ForEach-Object {
        # Skip built-in Administrator account (safety check)
        if ($_.SamAccountName -ne "Administrator") {
            Remove-ADUser -Identity $_ -Confirm:$false
            Write-Host "Removed user: $($_.SamAccountName)" -ForegroundColor Yellow
        }
    }
}

Write-Host "`nAll specified users removed." -ForegroundColor Green