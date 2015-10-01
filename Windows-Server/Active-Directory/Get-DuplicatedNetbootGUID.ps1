# ----------------------------------------------------------------------------- 
# Script: Get-DuplicatedNetbootGUID.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 08/27/2015 08:30:39 
# Keywords: netbootGUID, SCCM, ConfigMgr
# Comments: With this script, you can find all AD objects with a duplicated netbootGUID.
# This come in handy when a machine doesn't get it's advertisements from SCCM because
# two objects in AD exists with the same netbootGUID value.
# -----------------------------------------------------------------------------

$CSVExport = '.\Script-output.csv'
$ADSearchBase = 'OU=Laptop,OU=NL,DC=domain,DC=com'

Get-ADComputer -Filter * -Properties name,netbootGUID -SearchBase $ADSearchBase | where-object{$_.netbootGUID -ne $null} | 

ForEach-Object{
    $props =@{
        Name=$_.Name
        netbootGUID=$null
    }

    # Without spaces
    $props.netbootGUID = (-join (([guid]$_.netbootGUID).tobytearray() | %{$_.tostring("X").padleft(2,"0")}))
    # With spaces
    #$props.netbootGUID = (-join (([guid]$_.netbootGUID).tobytearray() | %{($_.tostring("X").padleft(2,"0")).PadLeft(3,' ')}))

    New-Object PsObject -Property $props
}   | Export-Csv $CSVExport -Delimiter ';' -NoTypeInformation 
