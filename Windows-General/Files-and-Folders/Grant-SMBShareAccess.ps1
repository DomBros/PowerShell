# ----------------------------------------------------------------------------- 
# Script: Grant-SMBShareAccess.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 02-03-2016 - 09:57
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

# Check the current share permissions
Write-Output "Current share permissions:"
Invoke-Command -ComputerName "VMM01" -ScriptBlock {
Get-SMBShareAccess -Name "VMMLibrary"
}

# Change this variable to your needs.
$Computers = (Get-ADComputer -Filter 'name -like "HOST2*"').Name
$DNSSuffix = (Get-ADDomain).dnsroot + "\"

# Grant access to the SCVMM share
Write-Output "`nRunning the script now..."

foreach ($Computer in $Computers) {
Invoke-Command -ComputerName "VMM01" -ArgumentList $Computer,$DNSSuffix -ScriptBlock {
$ComputerName = $($args[1]) + $($args[0]) + "$"
Write-Output "Adding $ComputerName"
Grant-SmbShareAccess -Name "VMMLibrary" -AccountName $ComputerName -AccessRight Read -Confirm:$False
}
}
