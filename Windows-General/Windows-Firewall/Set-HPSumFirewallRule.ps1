# ----------------------------------------------------------------------------- 
# Script: Set-HPSumFirewallRule.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 22-10-2015 - 16:22
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

do {
$ServerName = Read-Host 'What is the Server Name?'
Invoke-Command -ComputerName $ServerName -ScriptBlock {netsh advfirewall firewall add rule name="HP SUM Update Software" Action=Allow Description="Firewall rule for HP SUM software." Dir=in RemoteIp=172.23.1.10 Security=NotRequired Enable=yes}

$DeleteRule = Read-Host "Please delete the rule after usage. Do you want to delete the firewall rule for $ServerName now? Press a button to continue..."
Invoke-Command -ComputerName $ServerName -ScriptBlock {netsh advfirewall firewall delete rule name="HP SUM Update Software"}

$response = Read-Host "Press Y to repeat the script. Press another button to exit..."
}
while ($response -eq "Y")