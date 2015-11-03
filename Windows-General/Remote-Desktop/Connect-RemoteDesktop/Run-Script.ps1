# ----------------------------------------------------------------------------- 
# Script: Run-Script.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 03-11-2015 - 14:17
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

# Define variables
$Location = "C:\Scripts\Connect-RemoteDesktop"
$Servers = 'Server1','Server2'
$Date = Get-Date -Format D

# Import functions
. .\Connect-Mstsc.ps1
. .\Sleep-Until.ps1

Set-Location $Location
Echo "" | Out-File ".\Log.txt" -Append
Echo "#### $Date - Starting the script for today. ####" | Out-File ".\Log.txt" -Append

$Username = "Domain\Svc_CitrixWarmUp"
$Encrypted = Get-Content ".\Encrypted_Pwd.txt" | ConvertTo-SecureString
$Credential = New-Object System.Management.Automation.PsCredential($Username, $Encrypted)

Connect-Mstsc -ComputerName $Servers -User $Username -Password $Credential.GetNetworkCredential().password -SleepSeconds "5"

Echo "#### $Date - Ending the script for today. ####" | Out-File ".\Log.txt" -Append