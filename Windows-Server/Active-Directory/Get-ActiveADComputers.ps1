# ----------------------------------------------------------------------------- 
# Script: Get-ActiveADComputers.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 07-01-2016 - 09:01
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

Import-Module ActiveDirectory
$Today = Get-Date
$CutOffDate = $Today.AddDays(-60)
$DomainDisName = Get-ADDomain | % DistinguishedName
$Random = Get-Random -Maximum 1000

Get-ADComputer -SearchBase "$DomainDisName" -Properties * `
-Filter {Name -notlike 'LAP-*' -and Name -notlike 'DES-*' -and modifyTimeStamp -lt $CutOffDate -and Enabled -eq $true} | `
Select Name,OperatingSystem,modifyTimeStamp,Enabled | Sort Name | `
Export-Csv C:\Temp\ActiveComputers-$Random.csv -Delimiter ";" -NoTypeInformation
