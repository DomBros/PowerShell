# ----------------------------------------------------------------------------- 
# Script: Disable-BitLockerToGo.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 22-10-2015 - 16:37
# Keywords: 
# Comments: Disable BitLocker To Go with this script
# 
# -----------------------------------------------------------------------------

[CmdletBinding()]
param (
)
$Date = Get-Date -Format "dd-MM-yyyy hh:mm:ss"
Write-Verbose "Setting the BitLocker To Go Registry Key at $Date"
Push-Location
Set-Location HKLM:\System\CurrentControlSet\Policies\Microsoft\FVE
Set-ItemProperty . RDVDenyWriteAccess "0" -Type DWord
Pop-Location
Write-Verbose "Completed at $Date"