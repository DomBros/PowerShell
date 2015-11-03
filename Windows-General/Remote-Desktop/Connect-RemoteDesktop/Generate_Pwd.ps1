# ----------------------------------------------------------------------------- 
# Script: Generate_Pwd.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 03-11-2015 - 14:17
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

$credential = Get-Credential "Domain\ServiceAccount"
$credential.Password | ConvertFrom-SecureString | Set-Content C:\Scripts\Connect-RemoteDesktop\encrypted_pwd.txt