# ----------------------------------------------------------------------------- 
# Script: Get-AllConnectedISOs.ps1
# Author: Jean-Paul van Ravensberg
# Date: 26-01-2016 - 19:55
# Keywords: 
# Comments: Get all VMs with mounted ISO files.
# 
# -----------------------------------------------------------------------------

Get-VM | foreach {Get-VirtualDVDDrive -VMMServer VMM01 -All} `
| Where-object {($_.ISO -ne $null) -and ($_.ISOLinked -eq $false)} `
| Export-Csv C:\Temp\Output.csv -Delimiter ";"
