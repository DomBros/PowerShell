# ----------------------------------------------------------------------------- 
# Script: Get-ModifiedGPOs.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 22-10-2015 - 16:18
# Keywords: 
# Comments: Use this script to find modified GPOs
# 
# -----------------------------------------------------------------------------

Import-Module grouppolicy
$CompDomain = Get-ADDomain -current LocalComputer
$CurrentDate = Get-Date
$ChangedGPOs = Get-Gpo -domain $CompDomain.DNSRoot -all | Where {$_.ModificationTime.Year.equals($CurrentDate.Year) -And $_.ModificationTime.Month.equals($CurrentDate.Month)}
"Found " + $ChangedGPOs.count + " GPOs." | out-host
Foreach ($GPO in $ChangedGPOs) { 
    "          " + $GPO.DisplayName + " - " + $GPO.ModificationTime | out-host 
}