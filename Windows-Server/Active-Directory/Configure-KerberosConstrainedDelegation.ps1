# ----------------------------------------------------------------------------- 
# Script: Configure-KerberosConstrainedDelegation.ps1
# Author: Jean-Paul van Ravensberg
# Date: 02-03-2016 - 08:49
# Keywords: 
# Comments: 
# Source: http://s.jvrtech.net/1QrgvjI
# Original Author: Ben Gelens
#
# -----------------------------------------------------------------------------

# Configure the following parameters
$Computers = Get-ADComputer -Filter 'name -like "HOST2*"'
$SCVMMLibrarySRV = "VMM01"

# Default parameters
$DNSSuffix = "." + (Get-ADDomain).dnsroot

# Configure constrained delegation for all the computers in $Computers
foreach ($c in $computers)
{
$kcdentries = $computers | ?{$_.name -ne $c.name}
[array]$ServiceString = @()
foreach ($k in $kcdentries)
{
$ServiceString += "cifs/"+$k.name+$DNSSuffix
$ServiceString += "cifs/"+$k.name
$ServiceString += "Microsoft Virtual System Migration Service/"+$k.name+$DNSSuffix
$ServiceString += "Microsoft Virtual System Migration Service/"+$k.name
}
$ServiceString += "cifs/"+$SCVMMLibrarySRV+$DNSSuffix
$ServiceString += "cifs/"+$SCVMMLibrarySRV
<# for LM KCD with Kerberos only is enough ISO sharing through SCVMM library requires protocol transition according to http://technet.microsoft.com/en-us/library/ee340124.aspx to enable protocol transition, the useraccountcontrol attribute will be changed to 16781344 #>
Set-ADObject -Identity $C -replace @{"msDS-AllowedToDelegateTo" = $ServiceString; "userAccountControl"="16781344"}
}
