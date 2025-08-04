<#
.SYNOPSIS
    Safely offboard a single Active Directory user.

.DESCRIPTION
    This script disables a user account, moves it to a "Disabled Users" OU,
    removes non-essential group memberships (excluding Domain Users), and 
    resets the password for security.

.NOTES
    - Requires RSAT: Active Directory module installed
    - Run as a domain administrator
    - Update `$disabledOU` to match your environment

.EXAMPLE
    .\Offboard-Single-ADUser.ps1
    Enter the username when prompted (SAMAccountName or UPN)
#>

param (
    [string]$Username = $(Read-Host "Enter the SAMAccountName or UPN of the user to offboard: "),
    [string]$DisabledOU = "OU=Disabled Users,DC=lab,DC=local"
)

Import-Module ActiveDirectory

$user = Get-ADUser -Identity $Username -Properties MemberOf, DistinguishedName -ErrorAction SilentlyContinue
if (-not $user) {
    Write-Host "User '$Username' not found in Active Directory." -ForegroundColor Red
    exit
}

Write-Host "`nStarting offboarding process for $($user.SAMAccountName)..." -ForegroundColor Cyan

# Disable
Disable-ADAccount -Identity $user.SAMAccountName
Write-Host "Account disabled."

# Move to Disabled OU
Move-ADObject -Identity $user.DistinguishedName -TargetPath $DisabledOU
Write-Host "Moved account to Disabled Users OU."

# Group handling
$groups = $user.MemberOf
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logPath = Join-Path $scriptPath "Offboard-Logs"

if ($groups) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    if (!(Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath | Out-Null }

    $logFile = "$logPath\$Username-groups-$timestamp.txt"
    $groups | ForEach-Object { (Get-ADGroup $_).Name } | Out-File $logFile

    foreach ($group in $groups) {
        if ($group -notmatch "Domain Users") {
            Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
        }
    }
    Write-Host "Group memberships removed (saved to $logFile)."
}
else {
    Write-Host "No additional group memberships found."
}

# Reset password
$newPass = [System.Web.Security.Membership]::GeneratePassword(12,2)
Set-ADAccountPassword -Identity $user.SAMAccountName -Reset -NewPassword (ConvertTo-SecureString $newPass -AsPlainText -Force)
Write-Host "Password reset for added security."

Write-Host "`nOffboarding completed for $Username." -ForegroundColor Green