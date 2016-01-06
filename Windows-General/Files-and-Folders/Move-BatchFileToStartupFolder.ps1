# ----------------------------------------------------------------------------- 
# Script: Move-BatchFileToStartupFolder.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 06-01-2016 - 16:26
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

Import-module ActiveDirectory
$Users = Get-ADGroupMember Lync2013 -Recursive | % SamAccountName | Sort

Foreach ($User in $Users) {
$ModDate = $Null
$Source = "\\ManagementServer\C$\Scripts\Start-SkypeForBusiness\Start Skype for Business.bat"
$Destination = "\\FileServer\Users$\$User\data\startmenu\Programs\Startup\Start Skype for Business.bat"

Write-Output "################"
Write-Output "Processing user $User now..."

If (Test-Path $Destination) {
$ModDate = Get-Item "$Destination" | % LastWriteTime
Write-Output "Modification date before copying: $ModDate"
}

Else {
Write-Output "File doesn't exist. Copying now..."
}

Write-Output "Changing file for $User in $Destination"
Copy-Item $Source $Destination

$ModDate = Get-Item "$Destination" | % LastWriteTime
Write-Output "Modification date after copying: $ModDate"

Write-Output "Finished processing user $User..."
Write-Output "################"
Write-Output ""
}
