<#
.SYNOPSIS
    Safely offboard multiple Active Directory users.

.DESCRIPTION
    This script reads a list of users from a CSV or text file and performs the
    offboarding process for each:
        - Disable account
        - Move to Disabled Users OU
        - Export and remove non-essential group memberships
        - Reset password for security

.NOTES
    - Requires RSAT: Active Directory module installed
    - Run as a domain administrator
    - Update `$DisabledOU` to match your environment

.EXAMPLE
    .\Offboard-Multi-ADUsers.ps1 -UserList "C:\path\to\users.csv"
    (CSV must have a 'Username' header with SAMAccountName or UPN values)
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$UserList,

    [string]$DisabledOU = "OU=Disabled Users,DC=lab,DC=local"
)

# Import AD module
Import-Module ActiveDirectory

# Load user list
if (-not (Test-Path $UserList)) {
    Write-Host "User list file not found: $UserList" -ForegroundColor Red
    exit
}

# Handle both CSV and TXT (CSV requires 'Username' column)
if ($UserList -match "\.csv$") {
    $users = Import-Csv $UserList | Select-Object -ExpandProperty Username
} else {
    $users = Get-Content $UserList
}

# Prepare log folder
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$logPath = Join-Path $scriptPath "Offboard-Logs"
if (!(Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath | Out-Null }

# Offboard each user
foreach ($Username in $users) {
    Write-Host "`nProcessing $Username..." -ForegroundColor Cyan

    $user = Get-ADUser -Identity $Username -Properties MemberOf, DistinguishedName -ErrorAction SilentlyContinue
    if (-not $user) {
        Write-Host "User '$Username' not found. Skipping." -ForegroundColor Yellow
        continue
    }

    # Disable account
    Disable-ADAccount -Identity $user.SamAccountName
    Write-Host "Account disabled."

    # Move to Disabled OU
    Move-ADObject -Identity $user.DistinguishedName -TargetPath $DisabledOU
    Write-Host "Moved to Disabled Users OU."

    # Group memberships
    $groups = $user.MemberOf
    if ($groups) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
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
    Set-ADAccountPassword -Identity $user.SamAccountName -Reset -NewPassword (ConvertTo-SecureString $newPass -AsPlainText -Force)
    Write-Host "Password reset for security."
}

Write-Host "`nMulti-user offboarding completed." -ForegroundColor Green