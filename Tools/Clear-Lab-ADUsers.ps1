<#
.SYNOPSIS
    Deletes all user accounts from specified Organizational Units (OUs) in Active Directory.

.DESCRIPTION
    This script removes all user accounts within the provided OUs.
    Intended for lab environments to quickly reset test accounts.

    WARNING: This will permanently delete all users in the specified OUs. 

.PARAMETER OUs
    Distinguished Names (DNs) of the OUs to target for cleanup.

.EXAMPLE
    # Clear test users from Admins and Standard OUs
    $OUs = @(
        "OU=Admins,OU=Lab Users,DC=example,DC=local",
        "OU=Standard,OU=Lab Users,DC=example,DC=local"
    )
    .\Clear-Lab-ADUsers.ps1 -OUs $OUs

    # Alternative with same result
    .\Clear-ADUsers.ps1 -OUs "OU=Admins,DC=example,DC=com","OU=Standard,DC=example,DC=com"
#>

param (
    [Parameter(Mandatory = $true)]
    [string[]]$OUs
)

# Confirmation prompt
do {
    $confirmation = Read-Host "Are you sure you want to delete ALL users in the specified OUs? (Y/N)"
} until ($confirmation -match "^[YyNn]$")

if ($confirmation -eq "N" -or $confirmation -eq "n") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

foreach ($OU in $OUs) {
    Write-Host "Removing all users from: $OU" -ForegroundColor Yellow
    Get-ADUser -Filter * -SearchBase $OU | Remove-ADUser -Confirm:$false
}

Write-Host "All specified users removed." -ForegroundColor Green