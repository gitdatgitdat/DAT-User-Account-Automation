##Bulk Active Directory User Creation Script

This PowerShell script automates bulk user creation in Active Directory from a CSV file. It reads first name, last name, and department values, then places each account into the correct Organizational Unit (OU) based on department mapping.

---

##Features

Imports users from a CSV file

Generates usernames (first initial + last name) and UPNs

Assigns users to OUs based on department

Validates OU existence before creation

Skips duplicates if accounts already exist

Outputs a summary of all successfully created accounts

---

##Example CSV Format

FirstName,LastName,Department
Alice,Smith,Admins
Bob,Jones,Standard
Charlie,Brown,Service Accounts

---

##Usage

Ensure RSAT (Active Directory module) is installed.

Update the CSV path and OU mappings in the script to match your environment.

Run PowerShell as a domain administrator and run:
.\Create-ADUsers.ps1
