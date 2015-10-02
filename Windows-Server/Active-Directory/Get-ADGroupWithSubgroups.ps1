<#
.SYNOPSIS
Get-ADGroupWithSubgroups.ps1 checks for nested groups within
the specified groups and exports it to a CSV file.
.DESCRIPTION
Get-ADGroupWithSubgroups queries Active Directory to find
nested AD groups within a group.
.PARAMETER ExportFile
The location of the CSV export file. Default: .\Groups.csv
.PARAMETER OpenCSV
Opens the CSV automatically after running the script.
Default = $False
.PARAMETER OUsWithGroups
Specify the OU with the groups. Default: 
"OU=User Roles,OU=Roles,OU=Groups,DC=DOMAIN,DC=COM"
.PARAMETER KillExcel
Kills Excel before running the script. Default: $False
.EXAMPLE
.\Get-ADGroupWithSubgroups.ps1 -KillExcel -OpenCSV
.LINK
https://www.avanade.com
.NOTES
NAME: Get-ADGroupWithSubgroups.ps1
AUTHOR: Jean-Paul van Ravensberg, Avanade
LASTEDIT: 26-08-2015 15:16:30
KEYWORDS: Nested Groups, PowerShell
VERSION: 1.0
#>
[CmdletBinding()]
param (
[Parameter(Mandatory=$False)]
[Alias('File')]
[string]$ExportFile = ".\Groups.csv",

[parameter(Mandatory=$False)]
[alias("Open")]
[switch]$OpenCSV,

[parameter(Mandatory=$False)]
[alias("Group")]
[string]$OUsWithGroups = "OU=User Roles,OU=Roles,OU=Groups,DC=DOMAIN,DC=COM",

[parameter(Mandatory=$False)]
[switch]$KillExcel
)

## DEFINE FUNCTIONS ##
function Get-ADPrincipalGroupMembershipRecursive( ) {

    Param(
        [string] $dsn,
        [array]$groups = @())

    $obj = Get-ADObject $dsn -Properties memberOf

    foreach( $groupDsn in $obj.memberOf ) {
        $tmpGrp = Get-ADObject $groupDsn -Properties memberOf

        if( ($groups | where { $_.DistinguishedName -eq $groupDsn }).Count -eq 0 ) {
            $groups +=  $tmpGrp           
            $groups = Get-ADPrincipalGroupMembershipRecursive $groupDsn $groups
        }
    }

    return $groups
}

## PRESTART ##
if ($KillExcel) {
Get-Process Excel -ErrorAction Ignore | Foreach-Object { $_.CloseMainWindow() | Out-Null } | stop-process -Force -ErrorAction Ignore
Sleep -Seconds 1
}

# RREMOVE CSV ##
rm $ExportFile -Force -ErrorAction Ignore

## CREATE CSV ##
$headers = "GroupName","Name","memberOf"
$psObject = $Null
$psObject = New-Object psobject
foreach($header in $headers)
{
 Add-Member -InputObject $psobject -MemberType noteproperty -Name $header -Value ""
}
$psObject | Export-Csv $ExportFile -NoTypeInformation -Delimiter ";"

## EXPORT GROUPS TO CSV ##
$ADGroups = Get-ADGroup -SearchBase $OUsWithGroups -Filter *
Foreach ($ADGroup in $ADGroups) {
$ADGroupName = (Get-ADGroup $ADGroup).Name
New-Object PsObject -Property @{ GroupName = "$ADGroupName" } | Export-CSV $ExportFile -NoTypeInformation -Delimiter ";" -Append -Force

$name = "$ADGroup"
$groups   = Get-ADPrincipalGroupMembershipRecursive (Get-ADGroup $name).DistinguishedName
$groups | Select Name, @{L='memberOf'; E={$_.MemberOf[0]}} `
| Export-CSV $ExportFile -NoTypeInformation -Delimiter ";" -Append -Force
}

## OPEN CSV AFTERWARDS ##
if ($OpenCSV) {
$OpenCSV = & $ExportFile
}