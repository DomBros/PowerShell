# ----------------------------------------------------------------------------- 
# Script: ExportSystemInfo.ps1
# Author: Jean-Paul van Ravensberg
# Date: 06-02-2014
# Keywords: 
# Comments: My first PowerShell script ever! Oh gosh, embarrassingggg!
#           Shows details of currently running PC
# -----------------------------------------------------------------------------

$computerSystem = get-wmiobject Win32_ComputerSystem
$computerBIOS = get-wmiobject Win32_BIOS
$computerOS = get-wmiobject Win32_OperatingSystem
$computerUpdate = get-wmiobject Win32_QuickFixEngineering
$computerDisk = get-wmiobject Win32_LogicalDisk -Filter "DriveType=3"
$driveLetter = Read-Host 'What is the drive letter of the USB stick?'
$location = $driveLetter + ":\scripts\PowerShell\ExportSystemInfo\Outputs\" + $computerSystem.Name + ".txt"
$date = Get-Date
cls

# Check if file already exists. If so, delete it.
$FileExists = Test-Path $location 
If ($FileExists -eq $True) {
Write-Host "File exists, deleting now..."
Remove-Item $location
}
Else {Write-Host "File doesn't exists"
}

"---------- SYSTEM INFORMATION ----------" >> $location
"Current date (MM/DD/YYYY): " + $date >> $location
"Computer name: " + $computerSystem.Name >> $location
"Manufacturer: " + $computerSystem.Manufacturer >> $location
"Model: " + $computerSystem.Model >> $location
"Serial Number: " + $computerBIOS.SerialNumber >> $location
"BIOS Version: " + $computerBIOS.SMBIOSBIOSVersion >> $location
"Operating System: " + $computerOS.caption + $computerOS.OSArchitecture + ", Service Pack: " + $computerOS.ServicePackMajorVersion >> $location
"User logged In: " + $computerSystem.UserName >> $location
"Last Reboot: " + $computerOS.ConvertToDateTime($computerOS.LastBootUpTime) >> $location
"Domain: " + $computerSystem.Domain >> $location
"Primary Owner: " + $computerSystem.PrimaryOwnerName >> $location
"" >> $location

"System Specifications:" >> $location
"----------------------------------------" >> $location
"Free Disk Space: " + $computerDisk.FreeSpace/1gb + " GB" >> $location
"Total Physical Memory: " + $computerSystem.TotalPhysicalMemory/1gb + " GB" >> $location
"Free Physical Memory: " + $computerOS.FreePhysicalMemory/1mb + " GB" >> $location
"" >> $location

"Updates installed on this computer:" >> $location
"----------------------------------------" >> $location
Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName . >> $location
"" >> $location

"Services running on this computer:" >> $location
"----------------------------------------" >> $location
Get-WmiObject -Class Win32_Service -ComputerName . | Format-Table -Property Status,Name,DisplayName -AutoSize -Wrap >> $location

"---------- END OF FILE ----------" >> $location
"" >> $location

Write-Host "Script is finished"
Write-Host "Results were saved into $location"
Start-Sleep -s 5

# [System.Windows.Forms.MessageBox]::Show("Results were saved into $location`nClick OK to close this window.", "Jean-Paul van Ravensberg")
