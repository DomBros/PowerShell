# ----------------------------------------------------------------------------- 
# Script: Get-VMsWithoutGuestServices.ps1
# Author: Jean-Paul van Ravensberg
# Date: 26-01-2016 - 19:55
# Keywords: 
# Comments: Get all VMs without Guest Services installed.
# 
# -----------------------------------------------------------------------------

Import-Module 'C:\Program Files\Microsoft System Center 2012\Virtual Machine Manager\bin\psModules\virtualmachinemanager\virtualmachinemanager.psd1'

$VMs = @(Get-VM)
$VMsWithoutServices = @($VMs | where { $_.HasVMAdditions -eq $False })

if ($VMsWithoutServices.Count -eq "0") { throw "All virtual machines have Virtual Guest Services installed." }
$VMsWithoutServices | Sort-Object -Property Name | Format-Table Name
