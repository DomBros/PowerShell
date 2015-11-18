# ----------------------------------------------------------------------------- 
# Script: New-SCCMCollectionByOU.ps1
# Author: Jean-Paul van Ravensberg
# Date: 18-11-2015 - 14:51
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
Import-Module ActiveDirectory
Set-Location PR1:

$Date = Get-Date
$searchbase = 'OU=Company,DC=AD,DC=domain,DC=com'
$append = ' - OU'
$LimitingCollection = 'All Systems'
$SearchScope = 'Subtree'
$RefreshType = 'ConstantUpdate'
$Comment = "Automatically created at $date"


$OUS = Get-ADOrganizationalUnit -searchbase $searchbase -SearchScope $SearchScope -Filter * -Properties canonicalname
foreach ($OU in $OUS) 
 {
    $Name=$OU.Name
    $Canonical=$OU.CanonicalName
    $NewCollection = New-CMDeviceCollection -Name "$Name $append" -LimitingCollectionName $LimitingCollection -RefreshType $RefreshType
    Move-CMObject -FolderPath 'PR1:\DeviceCollection\Active Directory' -InputObject $NewCollection

    Add-CMDeviceCollectionQueryMembershipRule -CollectionName "$Name $append" -QueryExpression "select SMS_R_SYSTEM.ResourceID, SMS_R_SYSTEM.ResourceType,
    SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.SystemOUName
   = '$Canonical'" -RuleName "$Name $append"
 }
