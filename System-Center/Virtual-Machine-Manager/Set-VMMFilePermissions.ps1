# ----------------------------------------------------------------------------- 
# Script: Set-VMMFilePermissions.ps1
# Author: Jean-Paul van Ravensberg
# Date: 26-01-2016 - 20:00
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

#Enter-PSSession HYPERV01

# Use this command to get the SID of a user with permissions on a file
(Get-Acl 'C:\ClusterStorage\Volume01\SQL01\Virtual Hard Disks\SQL01_DISK1.vhd').Access `
| Select-Object  -ExpandProperty IdentityReference

$sid=get-acl 'C:\ClusterStorage\Volume01\SQL01\Virtual Hard Disks\SQL01_DISK1.vhd'

$sid.SetSecurityDescriptorSddlForm( ($sid.sddl + "(A;;FA;;;S-1-5-83-1-464899076-1125452419-2945959552-3702979762)(A;OICIIO;0x101f01ff;;;S-1-5-83-1-464899076-1125452419-2945959552-3702979762)") ) 
set-acl 'C:\ClusterStorage\Volume01\SQL01\Virtual Hard Disks\*' -AclObject $sid
