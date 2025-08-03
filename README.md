## Bulk Active Directory User Creation Script

A collection of PowerShell scripts to automate user account onboarding and offboarding within Active Directory.   
These scripts help reduce manual work and ensure consistency when provisioning or deprovisioning accounts.  

---

## Features

- Onboarding (Create-ADUsers.ps1)

Bulk-create user accounts from a CSV file.

Supports setting attributes like name, username, and department.

Places users into the appropriate OU.

Prepares accounts for post-creation setup (e.g., assigning groups).

- Offboarding (Offboard-ADUser.ps1)

Disables a specified user account.

Moves the account to a Disabled Users OU.

Exports and removes group memberships (retains a log for reference).

Resets the password for security.

- Single User Removal

Deletes a single user account by SamAccountName.

Confirms user existence and prompts before removal.

- Bulk User Removal

Removes all accounts from specified OUs (e.g., test users).

Includes confirmation prompt for safety.

---

## Example CSV for Bulk User Creation

FirstName,LastName,Department  
Alice,Smith,Admins  
Bob,Jones,Standard  
Charlie,Brown,Service Accounts  

---

## Usage

Ensure RSAT (Active Directory module) is installed.

Update the CSV path and OU mappings in the script to match your environment.

Run PowerShell as a domain administrator and run:

- Bulk create users
.\Create-ADUsers.ps1

- Offboard user
.\Offboard-ADUser.ps1

- Remove single user
.\Remove-Single-ADUser.ps1 -SamAccountName bjones

- Bulk remove test users
.\Clear-Lab-ADUsers.ps1

Additional inline comments are included within each script in the Tools folder for clarity.

---

## Planned Enhancements

Single user creation

Bulk offboarding

Add OneDrive/SharePoint backup for offboarding

Combine onboarding and offboarding into a single interactive menu

Implement logging and summary reports for all actions

---
