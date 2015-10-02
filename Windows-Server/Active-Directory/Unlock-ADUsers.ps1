# ----------------------------------------------------------------------------- 
# Script: Unlock-ADUsers.ps1 
# Author: Jean-Paul van Ravensberg 
# Date: 11/08/2015 09:27:15 
# Keywords: Unlock, ADUser, Active Directory
# Comments: Easy script to unlock a user with PowerShell
# -----------------------------------------------------------------------------

[CmdletBinding()]
param
(
[Parameter(Mandatory=$True)]
[Alias('User')]
$Users
)
Import-Module activedirectory

Foreach ($User in $Users) {
Unlock-ADAccount $User
Write-Output "User $User has been unlocked!"
}