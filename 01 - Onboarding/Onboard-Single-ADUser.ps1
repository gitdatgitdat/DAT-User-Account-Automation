<#
.SYNOPSIS
    Create a single Active Directory user.

.DESCRIPTION
    This script interactively creates a new AD user account.
    It prompts for first name, last name, department, and places the user
    in the appropriate OU based on department.

.NOTES
    - Requires RSAT: Active Directory module installed
    - Run as a domain administrator
    - Update `$DomainName` and OU paths for your environment

.EXAMPLE
    .\Onboard-Single-ADUser.ps1
    Follow prompts for user details
#>

# ===== Configuration =====

# Default password and domain name
$DefaultPassword = "P@ssw0rd123"
$DomainName = "homelab.local"

# Prompt for user details
$FirstName = Read-Host "Enter First Name"
$LastName  = Read-Host "Enter Last Name"
$Department = Read-Host "Enter Department (Admins / Standard / Service Accounts)"

# Generate username and UPN
$SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
$UserPrincipalName = "$SamAccountName@$DomainName"

# Select OU based on department
switch ($Department.ToLower()) {
    "admins" { $OUPath = 'OU=Admins,OU=Homelab Users,DC=homelab,DC=local' }
    "standard" { $OUPath = 'OU=Standard,OU=Homelab Users,DC=homelab,DC=local' }
    "service accounts" { $OUPath = 'OU=Service Accounts,OU=Homelab Users,DC=homelab,DC=local' }
    default { $OUPath = 'OU=Standard,OU=Homelab Users,DC=homelab,DC=local' }
}

# Validate OU exists
if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$OUPath)" -ErrorAction SilentlyContinue)) {
    Write-Host "OU not found: $OUPath. Please check your OU structure." -ForegroundColor Red
    exit
}

# Check if user already exists
if (Get-ADUser -Filter {SamAccountName -eq $SamAccountName}) {
    Write-Host "User '$SamAccountName' already exists. Aborting." -ForegroundColor Yellow
    exit
}

# Debug output
Write-Host "`nCreating user: $FirstName $LastName in $OUPath" -ForegroundColor Cyan

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

Write-Host "User '$FirstName $LastName' created successfully." -ForegroundColor Green