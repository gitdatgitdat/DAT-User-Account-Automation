## Bulk Active Directory User Creation Script
A PowerShell toolkit for automating user account management in Active Directory.  
Includes onboarding, offboarding, and deletion scripts for both single and bulk users, designed to streamline routine administrative tasks in enterprise or lab environments.

---

## Structure

- **01 - Onboarding**
  - `Onboard-Multi-ADUsers.ps1`: Bulk user creation from CSV
  - `Onboard-Single-ADUser.ps1`: Interactive prompt for single user onboarding
  - `user.csv`: CSV template for input

- **02 - Offboarding**
  - `Offboard-Multi-ADUsers.ps1`: Bulk user offboarding from CSV
  - `Offboard-Single-ADUser.ps1`: Prompt-based offboarding for a single user
  - `user.csv`: CSV template for input

- **03 - Deleting**
  - `Delete-Multi-ADUsers.ps1`: Bulk deletion via username CSV
  - `Delete-Single-ADUser.ps1`: Delete one specified user
  - `Delete-All-ADUsers.ps1`: Wipe all users from one or more OUs (for lab resets)
  - `user.csv`: CSV template for input

---

## Features

### Onboarding
- Creates new AD users from a CSV or manual input
- Assigns to OUs based on department
- Preconfigures account password and username
- Includes basic error handling for duplicates or missing OUs

### Offboarding
- Disables accounts and moves them to a "Disabled Users" OU
- Logs and removes group memberships (excluding `Domain Users`)
- Resets passwords to ensure account is inaccessible
- Supports single or bulk offboarding with logs

### Deleting
- Delete a specific user with confirmation
- Bulk delete users by name from a CSV
- Clear all users from one or more OUs (for test/lab environments)

---

## CSV Examples

### For `Onboard-Multi-ADUsers.ps1`:
FirstName,LastName,Department  
Alice,Smith,Admins  
Bob,Jones,Standard  
Charlie,Brown,Service Accounts  

### For `Offboard-Multi-ADUsers.ps1` and `Delete-Multi-ADUsers.ps1`:
Username  
asmith  
bjones  
cbrown  

---

## Usage

> **Pre-requisite:** Run as a domain administrator with RSAT (Active Directory module) installed.

### Onboarding

- Bulk onboarding  
.\Onboard-Multi-ADUsers.ps1

- Single user onboarding  
.\Onboard-Single-ADUser.ps1

### Offboarding

- Bulk offboarding  
.\Offboard-Multi-ADUsers.ps1

- Single user offboarding  
.\Offboard-Single-ADUser.ps1

### Deletion

- Delete specific user  
.\Delete-Single-ADUser.ps1

- Delete multiple users from CSV  
.\Delete-Multi-ADUsers.ps1

- Delete all users in one or more OUs  
.\Delete-All-ADUsers.ps1 -OUs "OU=Standard,OU=Homelab Users,DC=homelab,DC=local"

## Planned Enhancements

Add OneDrive/SharePoint backup before offboarding

Combine onboarding/offboarding tools into an interactive menu

Improve logging with success/failure summaries

Add email/group assignment options

Integrate with Microsoft Graph for Entra ID support

## Disclaimer

These scripts are intended for educational, testing, or internal automation purposes.  
Always review and test in a lab environment before applying to production.  

---
