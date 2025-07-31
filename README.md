## Bulk Active Directory User Creation Script

This collection of PowerShell scripts automates bulk user creation and cleanup in Active Directory.   
It uses a CSV file for input and places accounts into Organizational Units (OUs) based on department mapping.

---

## Features

- Bulk User Creation

Imports users from a CSV file.

Generates usernames (first initial + last name) and UPNs.

Assigns accounts to OUs based on department mapping.

Verifies OU existence before creating accounts.

Skips duplicates automatically.

Displays a summary of successfully created accounts.

- Bulk User Removal

Removes all accounts from specified OUs (e.g., test users).

Includes confirmation prompt for safety.

- Single User Removal

Deletes a single user account by SamAccountName.

Confirms user existence and prompts before removal.

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

# Bulk create users
.\Create-ADUsers.ps1

# Bulk remove test users
.\Clear-Lab-ADUsers.ps1

# Remove single user
.\Remove-Single-ADUser.ps1 -SamAccountName bjones

Additional inline comments are included within each script in the Tools folder for clarity.

---
