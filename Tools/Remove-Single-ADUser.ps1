<#
.SYNOPSIS
    Remove a single Active Directory user.
    Intended for lab environments to remove dummy/test users safely.

.DESCRIPTION
    Prompts for a username (SamAccountName) or accepts it as a parameter.
    Validates existence before removal and confirms action.

.EXAMPLE
    # Provide account when calling the script
    .\Remove-SingleADUser.ps1 -SamAccountName bjones

    #OR

    # Call the script
    .\Remove-SingleADUser.ps1
    # Provide the account's username
    Enter username: 
#>

param (
    [string]$SamAccountName
)

if (-not $SamAccountName) {
    $SamAccountName = Read-Host "Enter username"
}

# Check if user exists
$user = Get-ADUser -Filter { SamAccountName -eq $SamAccountName } -ErrorAction SilentlyContinue

if (-not $user) {
    Write-Host "User '$SamAccountName' not found." -ForegroundColor Yellow
    exit
}

# Confirm before deletion
$confirmation = Read-Host "Are you sure you want to delete '$SamAccountName'? (Y/N)"
if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    Remove-ADUser -Identity $user -Confirm:$false
    Write-Host "User '$SamAccountName' removed successfully." -ForegroundColor Green
} else {
    Write-Host "Operation canceled." -ForegroundColor Cyan
}