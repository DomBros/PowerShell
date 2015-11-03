# ----------------------------------------------------------------------------- 
# Script: Get-WebPageTime.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 03-11-2015 - 14:28
# Keywords: 
# Comments: Use this function to check how long it will take to open a webpage.
# Example: Get-WebPageTime -times 30 -URLs 'https://google.com','https://google.nl'
#
# -----------------------------------------------------------------------------

Function Get-WebPageTime {
param($URLs, $Times)
$i = 0
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
While ($i -lt $Times){
Foreach ($URL in $URLs) {
$Request = New-Object System.Net.WebClient
$Request.UseDefaultCredentials = $true
$Start = Get-Date
$PageRequest = $Request.DownloadString($URL)
$TimeTaken = ((Get-Date) - $Start).TotalMilliseconds 
$Request.Dispose()
Write-Host Request $i for $URL took $TimeTaken ms -ForegroundColor Green
$i ++}
}
}