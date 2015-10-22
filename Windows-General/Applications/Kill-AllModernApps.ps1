# ----------------------------------------------------------------------------- 
# Script: Kill-AllModernApps.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 22-10-2015 - 16:28
# Keywords: 
# Comments: Modified script. Original script by Burt_Harris:
# https://stackoverflow.com/questions/24377560/find-open-metro-apps-using-powershell
# 
# -----------------------------------------------------------------------------

function Get-ModernAppProcess {
    $wildcard = "$env:ProgramFiles\WindowsApps\*" # Native Apps
    $wwa = "$env:windir\System32\WWAHost.exe"     # HTML+Javascript Apps
    Get-Process | Where-Object { $_.Path -like $wildcard -or $_.Path -eq $wwa}
}
Get-ModernAppProcess | Stop-Process