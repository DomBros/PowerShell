# ----------------------------------------------------------------------------- 
# Script: Connect-Mstsc.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 03-11-2015 - 14:17
# Keywords: 
# Comments:
# Source: Jaap Brasser (http://www.jaapbrasser.com)
#
# -----------------------------------------------------------------------------

function Connect-Mstsc {
<#   
.SYNOPSIS   
	Function to connect an RDP session without the password prompt
    
.DESCRIPTION 
	This function provides the functionality to start an RDP session without having to type in the password
	
.PARAMETER ComputerName
    This can be a single computername or an array of computers to which RDP session will be opened

.PARAMETER User
    The user name that will be used to authenticate

.PARAMETER Password
    The user name that will be used to authenticate

.NOTES   
    Name: Connect-Mstsc
    Author: Jaap Brasser
    DateUpdated: 2014-07-08
    Version: 1.1

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
	. .\Connect-Mstsc.ps1
    
Description 
-----------     
This command dot sources the script to ensure the Connect-Mstsc function is available in your current PowerShell session

.EXAMPLE   
	Connect-Mstsc -ComputerName server01 -User contoso\jaapbrasser -Password supersecretpw

Description 
-----------     
A remote desktop session to server01 will be created using the credentials of contoso\jaapbrasser

.EXAMPLE   
	Connect-Mstsc server01,server02 contoso\jaapbrasser supersecretpw

Description 
-----------     
Two RDP session to server01 and server02 will be created using the credentials of contoso\jaapbrasser
#>
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [Alias("CN")]
            [string[]]$ComputerName,
        [Parameter(Mandatory=$true,Position=1)]
        [Alias("U")] 
            [string]$User,
        [Parameter(Mandatory=$true,Position=2)]
        [Alias("P")] 
            [string]$Password,
        [Parameter(Mandatory=$false,Position=3)]
        [Alias("S")] 
            [string]$SleepSeconds,
        [Parameter(Mandatory=$false,Position=4)]
        [Alias("A")]
            [switch]$Admin
    )
    begin {
        [string]$MstscArguments = ''
        switch ($true) {
            {$Admin} {$MstscArguments += '/admin'}
        }
    }
    process {
        foreach ($Computer in $ComputerName) {
            $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
            $Process = New-Object System.Diagnostics.Process

            $ProcessInfo.FileName = "$($env:SystemRoot)\system32\cmdkey.exe"
            $ProcessInfo.Arguments = "/generic:TERMSRV/$Computer /user:$User /pass:$Password"
            $Process.StartInfo = $ProcessInfo
            $Process.Start()

            $ProcessInfo.FileName = "$($env:SystemRoot)\system32\mstsc.exe"
            $ProcessInfo.Arguments = "$MstscArguments /v $Computer"
            $Process.StartInfo = $ProcessInfo
            $Process.Start()
            
            $Date = Get-Date -Format G
            Sleep -Seconds $SleepSeconds
            Echo "$Date - Connecting to $Computer." | Out-File "C:\Scripts\Connect-RemoteDesktop\Log.txt" -Append
        }
    }
}