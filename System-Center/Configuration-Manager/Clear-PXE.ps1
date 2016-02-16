# ----------------------------------------------------------------------------- 
# Script: Clear-PXE.ps1
# Author: Jean-Paul van Ravensberg
# Date: 16-02-2016 - 13:20
# Keywords: 
# Comments: This script clear the last PXE Advertisement for all devices in
#           collection P0100014
#
# -----------------------------------------------------------------------------

Import-Module "D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
cd P01:

    while ($True) {
        $Devices = Get-CMDevice -CollectionId "P0100014" | % Name
        Foreach ($Device in $Devices) {
            Write-Output "$Device - Clearing PXE"
            $ResourceIDQuery = Get-WmiObject -Namespace "ROOT\SMS\SITE_P01" -class "SMS_R_System" -Filter "NAME='$Device'" -ErrorAction STOP
            $Array = (,$ResourceIDQuery.ResourceID)
            Invoke-WmiMethod -Namespace "ROOT\SMS\SITE_P01" -class "SMS_Collection" -name ClearLastNBSAdvForMachines -ArgumentList (,$Array) >> $Null
                }
            Sleep 10
        }
