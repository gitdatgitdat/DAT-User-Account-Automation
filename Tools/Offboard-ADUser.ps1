# Purpose: Safely offboard a user account in active directory

param (
    [string]$Username = $(Read-Host "Enter the SAMAccountName or UPN of the user to offboard: ")
)

# Import AD module
Import-Module ActiveDirectory

# Validate user
$user = Get-ADUser -Identity $Username -Properties MemberOf, DistinguishedName -ErrorAction SilentlyContinue
if (-not $user) {
    Write-Host "User '$Username' not found in Active Directory." -ForegroundColor Red
    exit
}

Write-Host "`nStarting offboarding process for $($user.SAMAccountName)..." -ForegroundColor Cyan

# Step 1: Disable account
Disable-ADAccount -Identity $user.SAMAccountName
Write-Host "Account disabled."

# Step 2: Move to Disabled OU (Adjust DN for lab OU structure)
$disabledOU = "OU=Disabled Users,DC=lab,DC=local"
Move-ADObject -Identity $user.DistinguishedName -TargetPath $disabledOU
Write-Host "Moved account to Disabled Users OU."

# Step 3: Export and remove group memberships
$groups = $user.MemberOf
if ($groups) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $logPath = ".\Offboard-Logs"
    if (!(Test-Path $logPath)) { New-Item -ItemType Directory -Path $logPath | Out-Null}

    $logFile = "$logPath\$Username-groups-$timestamp.txt"
    $groups | ForEach-Object {
        (Get-ADGroup $_).Name
    } | Out-File $logFile

    # Remove user from all groups except Domain Users
    foreach ($group in $groups) {
        if ($group -notmatch "Domain Users") {
            Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
        }
    }
    Write-Host "Group memberships removed (saved to $logFile)."
}

# Step 4: Reset password
$newPass =[System.Web.Security.Membership]::GeneratePassword(12,2)
Set-ADAccountPassword -Identity $user.SAMAccountName -Reset -NewPassword (ConvertTo-SecureString $newPass -AsPlainText -Force)
Write-Host "Password reset for added security."

# Completion
Write-Host "`nOffboarding completed for $Username." -ForegroundColor Green
