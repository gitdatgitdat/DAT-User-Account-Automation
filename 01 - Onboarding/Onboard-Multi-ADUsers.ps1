<#
.SYNOPSIS
    Bulk create Active Directory users from a CSV file.

.DESCRIPTION
    This script imports user data from a CSV file and creates new users in Active Directory.
    Organizational Units (OUs) are assigned based on the Department column.

.NOTES
    - Requires RSAT: Active Directory module installed
    - Run as a domain administrator
    - Update `$DomainName` and OU paths to match your environment

.EXAMPLE
    .\Onboard-Multi-ADUsers.ps1
    .\user.csv
#>

# ===== Configuration =====

# Path to CSV file with user info.
$csvPath = "Z:\Scripts\user.csv"

# Setting default password.
$DefaultPassword = "P@ssw0rd123"

# Domain name (for UPN)
$DomainName = "homelab.local"

# Array for successfully created account.
$CreatedUsers = @()

# ===== Import CSV and process =====

# Import the CSV and loop through each entry.
Import-CSV -Path $csvPath | ForEach-Object {
    $FirstName = $_.FirstName 
    $LastName = $_.LastName 
    $Department = $_.Department 

# Create username and email.
$SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
$UserPrincipalName = "$SamAccountName@$DomainName"

# Choose OU based on department.
switch ($Department.ToLower()) {
    "admins" { $OUPath = 'OU=Admins,OU=Homelab Users,DC=homelab,DC=local' }
    "standard" { $OUPath = 'OU=Standard,OU=Homelab Users,DC=homelab,DC=local' }
    "service accounts" { $OUPath = 'OU=Service Accounts,OU=Homelab Users,DC=homelab,DC=local' }
    default { $OUPath = 'OU=Standard,OU=Homelab Users,DC=homelab,DC=local' }
}

# Verify OU exists.
if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$OUPath)" -ErrorAction SilentlyContinue)) {
    Write-Host "OU not found: $OUPath. Skipping $FirstName $LastName." -ForegroundColor Yellow
    return
}

# Check if user already exists.
if (Get-ADUser -Filter {SamAccountName -eq $SamAccountName}) {
    Write-Host "User $SamAccountName already exists. Skipping..." -ForegroundColor Red
    return
}

# Debug output.
Write-Host "Creating user: $FirstName $LastName in $OUPath." -ForegroundColor Green

# Create the user
New-ADUser `
    -Name "$FirstName $LastName" `
    -GivenName $FirstName `
    -Surname $LastName `
    -SamAccountName $SamAccountName `
    -UserPrincipalName $UserPrincipalName `
    -Path $OUPath `
    -AccountPassword (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force) `
    -Enabled $true

# Track created user
$CreatedUsers += "$FirstName $LastName"
}

# Print summary of created users
if ($CreatedUsers.Count -gt 0) {
    Write-Host "`nSuccessfully created users:" -ForegroundColor Cyan
    $CreatedUsers | ForEach-Object { Write-Host " - $_" }
} else {
    Write-Host "`nNo new users were created." -ForegroundColor Yellow        

}