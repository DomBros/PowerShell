# ----------------------------------------------------------------------------- 
# Script: Get-UserDetails.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 03-11-2015 - 14:30
# Keywords: 
# Comments: This script will show the details and the full name of a user.
# 
# -----------------------------------------------------------------------------

[CmdletBinding()]
param (
[Parameter(Mandatory=$True)]
[Alias('UserName')]
[string]$User
)

Import-Module ActiveDirectory
$SearchUser = Get-ADUser -Identity $User -Properties mail

If ($SearchUser -inotlike $Null) {
Write-Output $SearchUser
Write-Output "Full name of user:"
Write-Output $SearchUser.Name
}