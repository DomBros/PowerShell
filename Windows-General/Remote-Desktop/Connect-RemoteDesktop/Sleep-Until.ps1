# ----------------------------------------------------------------------------- 
# Script: Sleep-Until.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 03-11-2015 - 14:17
# Keywords: 
# Comments: This will allow you to initiate Start-Sleep until a given time,
# as opposed to for a given time.It will accept any valid format of datetime.
# 
# Usage: Sleep-Until "07:05:14 pm" this will sleep until 7:05:14 pm.
#        Sleep-Until "dafasdfasdf"  this will return an error due to an incorrect date.
#
# Source: https://gallery.technet.microsoft.com/scriptcenter/Sleeppause-until-a-given-5c6bc7fa
# 
# -----------------------------------------------------------------------------

Function sleep-until($future_time) 
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