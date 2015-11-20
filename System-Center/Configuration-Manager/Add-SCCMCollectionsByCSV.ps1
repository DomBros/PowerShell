# ----------------------------------------------------------------------------- 
# Script: Add-SCCMCollectionsByCSV.ps1
# Author: Jean-Paul van Ravensberg
# Date: 20-11-2015 - 14:51
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
Import-Module ActiveDirectory
Set-Location PR1:

$LimitingCollection = 'All Systems'
$Collections = Import-CSV 'C:\Collections.csv'
$RefreshType = 'ConstantUpdate'

foreach ($Collection in $Collections.Name) 
 {
    $NewCollection = New-CMDeviceCollection -Name $Collection -LimitingCollectionName $LimitingCollection -RefreshType $RefreshType
    Move-CMObject -FolderPath 'PR1:\DeviceCollection\Updates' -InputObject $NewCollection
 }
