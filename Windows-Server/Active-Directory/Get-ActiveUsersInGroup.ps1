# ----------------------------------------------------------------------------- 
# Script: Get-ActiveUsersInGroup.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 03-11-2015 - 14:30
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

Import-Module Activedirectory
Get-ADGroupMember -identity “Domain Admins” | get-aduser | Where {$_.Enabled -eq $true} | Select Name,SamAccountName,DistinguishedName,Enabled | Export-csv -path C:\Test\EnabledDomainAdminMembers.csv -Delimiter ';' -NoTypeInformation
Get-ADGroupMember -identity “Enterprise Admins” | get-aduser | Where {$_.Enabled -eq $true} | Select Name,SamAccountName,DistinguishedName,Enabled | Export-csv -path C:\Test\EnabledEnterpriseAdminMembers.csv -Delimiter ';' -NoTypeInformation