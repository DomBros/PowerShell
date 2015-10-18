# ----------------------------------------------------------------------------- 
# Script: Restart-IE.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 10/18/2015 10:29:33 
# Keywords: 
# Comments: Script opens IE, sleeps for 5 sec, clears internet cache and kills
#           IE after 10 seconds in a loop.
# 
# ----------------------------------------------------------------------------- 

Function Restart-IE {
    Get-Process iexplor* | Stop-Process
    Start-Process iexplore.exe "https://www.google.nl" -WindowStyle Normal
    Sleep 5
    RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 4351
    Sleep 10
        }

Function Loop {
    while ($i -lt 9999) {
        $i++
        Restart-IE
    }
    Write-Host "Count complete - $i"
}

Loop