# ----------------------------------------------------------------------------- 
# Script: Remove-Sophos.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 11-11-2015 - 09:32
# Version: 1.0
# Keywords: 
# Comments: This script removes the Sophos software
#           Don't forget to change "SERVER"
#           Credits to The Scripting Guys: http://blogs.technet.com/b/heyscriptingguy/archive/2011/12/14/use-powershell-to-find-and-uninstall-software.aspx 
#
# -----------------------------------------------------------------------------

## Enable logging ##
Function LogMe() 
    {
    Param ([parameter(Mandatory = $true, ValueFromPipeline = $true)] $logEntry,
	   [switch]$display,
	   [switch]$error,
	   [switch]$warning
	   )
    $CurrentDir = "\\SERVER\Sources\Applications\Sophos\Uninstall"
    $LogDir = "$Currentdir\Logs"

    if((Test-Path $LogDir) -eq 0)
    {
        mkdir $LogDir;
    }

    $LogFile = Join-Path $LogDir ("$Hostname.log")

    If ($error) { Write-Host "$logEntry" -Foregroundcolor Red; $logEntry = "[ERROR] $logEntry" }
	ElseIf ($warning) { Write-Host "$logEntry" -Foregroundcolor Yellow; $logEntry = "[WARNING] $logEntry"}
	ElseIf ($display) { Write-Host "$logEntry" -Foregroundcolor Green; $logEntry = "$logEntry" }
    Else { Write-Host "$logEntry"; $logEntry = "$logEntry" }

	$logEntry | Out-File $LogFile -Append
    
    } #End Function: LogMe

## Log started script
$StartDate = Get-Date -Format 'dd-MM-yyyy-HH-mm-ss'
$Hostname = Hostname
"Script Started at $StartDate" | LogMe -display

## Set Variables ##
$classKey1="IdentifyingNumber=`"`{D929B3B5-56C6-46CC-B3A3-A1A784CBB8E4`}`",Name=`"Sophos Anti-Virus`",version=`"10.3.15`""
$classKey2="IdentifyingNumber=`"`{7CD26A0C-9B59-4E84-B5EE-B386B2F7AA16`}`",Name=`"Sophos AutoUpdate`",version=`"4.3.10.27`""
$classKey3="IdentifyingNumber=`"`{FED1005D-CBC8-45D5-A288-FFC7BB304121`}`",Name=`"Sophos Remote Management System`",version=`"4.0.2`""

## Log if Sophos is installed ##
gwmi win32_product -filter "Name LIKE '%Sophos%'" | LogMe -display

## Kill the Sophos processes and services ##
### Services ###
Write-Output "Check if service runs" | LogMe -display
Get-Service | Where {$_.DisplayName -ilike '*Sophos*'} | LogMe -display

Write-Output "Killing service now..." | LogMe -display
Get-Service | Where {$_.DisplayName -ilike '*Sophos*'} | Stop-Service -Force

Write-Output "Check if service exists" | LogMe -display
Get-Service | Where {$_.DisplayName -ilike '*Sophos*'} | LogMe -display

### Processes ###
Write-Output "Check if processes are active" | LogMe -display
Get-Process | Where {$_.Description -ilike '*Sophos*' -or $_.Name -ilike 'ALMON'} | LogMe -display

Write-Output "Killing processes now..." | LogMe -display
Get-Process | Where {$_.Description -ilike '*Sophos*' -or $_.Name -ilike 'ALMON'} | Stop-Process -Force

Write-Output "Check if process exists" | LogMe -display
Get-Process | Where {$_.Description -ilike '*Sophos*' -or $_.Name -ilike 'ALMON'} | LogMe -display

## Uninstall Sophos ##
([wmi]"Win32_Product.$classKey1").uninstall()
([wmi]"Win32_Product.$classKey2").uninstall()
([wmi]"Win32_Product.$classKey3").uninstall()

## Log if Sophos has been removed ##
gwmi win32_product -filter "Name LIKE '%Sophos%'" | LogMe -display

## Log stopped script ##
$EndDate = Get-Date -Format 'dd-MM-yyyy-HH-mm-ss'
"Script Stopped at $EndDate" | LogMe -display
