# ----------------------------------------------------------------------------- 
# Script: Add-SCCMServersToCollection.ps1
# Author: Jean-Paul van Ravensberg
# Date: 07-12-2015 - 11:14
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

$Servers = Import-CSV 'C:\Users\Jean-Paul\Downloads\TestServers.csv'
$ItemCount = $Servers.Name.Count
$CollectionName = "Updating - Servers - 1 DEV"

Write-Output "$ItemCount items in CSV"

foreach($Server in $Servers.Name) {
   Write-Output "Importing $Server now..."
   Add-CMDeviceCollectionDirectMembershipRule -CollectionName $CollectionName -ResourceId $(get-cmdevice -Name $Server).ResourceID
}

<# Format of TestServers.csv:
Name
Server01
Server02
#>
