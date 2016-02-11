# ----------------------------------------------------------------------------- 
# Script: Get-CMDeviceMacAddress.ps1
# Author: Jean-Paul van Ravensberg
# Date: 10-02-2016 - 09:59
# Keywords: 
# Comments: This script gets the MAC Address and SMBIOSGUID from all devices
#  in $CollectionName
#
# -----------------------------------------------------------------------------

#Import-module ConfigurationManager
#Import-Module "D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"

$SiteServer = 'CM01'
$SiteCode = 'PR1'
$CollectionName = 'All Laptops'

$Collections = Get-WmiObject -ComputerName $SiteServer -Namespace  "ROOT\SMS\site_$SiteCode" -Class SMS_Collection | where {$_.Name -like "$CollectionName"}

foreach ($Collection in $Collections){
    $SMSClients = Get-WmiObject -ComputerName $SiteServer -Namespace  "ROOT\SMS\site_$SiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($Collection.CollectionID)' order by name" | select *
    foreach ($SMSClient in $SMSClients){
        $ClientName = $SMSClient.Name
        $ClientMAC = (Get-WmiObject -Class SMS_R_SYSTEM -ComputerName $SiteServer -Namespace root\sms\site_$SiteCode | where {$_.Name -eq "$ClientName"}).MACAddresses
        $SMBiosGUID = (Get-WmiObject -Class SMS_R_SYSTEM -ComputerName $SiteServer -Namespace root\sms\site_$SiteCode | where {$_.Name -eq "$ClientName"}).SMBIOSGUID
        $SMSClient.Name + ", " + $ClientMAC + ", " + $SMBiosGUID + ", " + $Collection.Name | Sort $ClientMac
    }
}
