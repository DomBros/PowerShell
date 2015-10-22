# ----------------------------------------------------------------------------- 
# Script: Sleep-Until.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 22-10-2015 - 16:35
# Keywords: 
# Comments: Source: https://gallery.technet.microsoft.com/scriptcenter/Sleeppause-until-a-given-5c6bc7fa
# 
# -----------------------------------------------------------------------------

function Sleep-Until($future_time) 
{ 
    if ([String]$future_time -as [DateTime]) { 
        if ($(get-date $future_time) -gt $(get-date)) { 
            $sec = [system.math]::ceiling($($(get-date $future_time) - $(get-date)).totalseconds) 
            start-sleep -seconds $sec 
        } 
        else { 
            write-host "You must specify a date/time in the future" 
            return 
        } 
    } 
    else { 
        write-host "Incorrect date/time format" 
    } 
}