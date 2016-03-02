# ----------------------------------------------------------------------------- 
# Script: Add-VMMNetworkAdapterToLogicalNetwork.ps1
# Author: Jean-Paul van Ravensberg
# Date: 02-03-2016 - 12:18
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

# Import the Virtual Machine Manager module
Import-Module VirtualMachineManager

# Change this to your needs
$ComputerName = "HV01"
$PRDSwitch = "Production_Trunk"
$EthSwitch = "Infra_Trunk"
$PRD_VMHostNetworkAdapter = Get-VMHostNetworkAdapter -VMHost $ComputerName | Where {$_.ConnectionName -ilike $PRDSwitch}
$PRD_LogicalNetwork = Get-SCLogicalNetwork -Name "Production_Trunk"
$PRD_LogicalNetwork2 = Get-SCLogicalNetwork -Name "UAT Network"
$Eth_VMHostNetworkAdapter = Get-VMHostNetworkAdapter -VMHost $ComputerName | Where {$_.ConnectionName -ilike $EthSwitch}
$Eth_LogicalNetwork = Get-SCLogicalNetwork -Name "INFRA"

# Add the $PRD_VMHostNetworkAdapter to the Production_Trunk Logical Network
$guid = [guid]::NewGuid()

# Set the Productie_Trunk adapter
Set-SCVMHostNetworkAdapter -VMHostNetworkAdapter $PRD_VMHostNetworkAdapter -AddOrSetLogicalNetwork $PRD_LogicalNetwork -JobGroup $guid
Set-SCVMHostNetworkAdapter -VMHostNetworkAdapter $PRD_VMHostNetworkAdapter -AddOrSetLogicalNetwork $PRD_LogicalNetwork2 -JobGroup $guid
Set-SCVMHostNetworkAdapter -VMHostNetworkAdapter $PRD_VMHostNetworkAdapter -Description "" -JobGroup $guid -VLanMode "Trunk" -AvailableForPlacement $true -UsedForManagement $false

# Set the Ethernet Trunk adapter
Set-SCVMHostNetworkAdapter -VMHostNetworkAdapter $Eth_VMHostNetworkAdapter -AddOrSetLogicalNetwork $Eth_LogicalNetwork -JobGroup $guid
Set-SCVMHostNetworkAdapter -VMHostNetworkAdapter $Eth_VMHostNetworkAdapter -Description "" -JobGroup $guid -VLanMode "Trunk" -AvailableForPlacement $false -UsedForManagement $True

# Run the action
Set-SCVMHost -VMHost $ComputerName -JobGroup $guid -RunAsynchronously
