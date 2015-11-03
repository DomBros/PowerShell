# ----------------------------------------------------------------------------- 
# Script: ExchangeScripts.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 03-11-2015 - 14:12
# Keywords: 
# Comments: 
# 
# -----------------------------------------------------------------------------

# Variables
$ExchangeServer = "EX01"
$SourceDB = "Mailbox Database 05"
$DestinationDB = "Mailbox Database 15"

# Get all users in source db with mailboxes between 100 MB and 2500 MB
Get-MailboxDatabase $SourceDB | get-mailboxstatistics | where {$_.TotalItemSize -lt 2500MB -AND $_.TotalItemSize -gt 100MB -AND $_.DisplayName -notlike "SystemMailbox*"} | get-mailbox | get-mailboxstatistics | sort-object totalitemsize -descending | Select-Object displayname,totalitemsize | Export-CSV .\Mailboxen.csv -Delimiter ";" -NoTypeInformation

# Move users above to dest db
Get-MailboxDatabase $SourceDB | get-mailboxstatistics | where {$_.TotalItemSize -lt 2500MB -AND $_.TotalItemSize -gt 100MB -AND $_.DisplayName -notlike "SystemMailbox*"} | get-mailbox | New-MoveRequest -TargetDatabase $DestinationDB

# View mailboxes in dest db
Get-MailboxStatistics -Database $DestinationDB | where {$_.ObjectClass -eq “Mailbox”} | Sort-Object TotalItemSize -Descending | ft @{label=”User”;expression={$_.DisplayName}},@{label=”Total Size (MB)”;expression={$_.TotalItemSize.Value.ToMB()}}  -auto

# Check quota of databases
Get-MailboxDatabase -Server $ExchangeServer | FL name,issuewarningquota,prohibitsendquota,prohibitsendrecievequota

#Get-MailboxDatabase -Status | Select-Object Server,Name,AvailableNewMailboxSpace,DatabaseSize,EdbFilePath,Mounted | FT
#Get-Mailbox -Database $DestDB | Select-Object Name,SAMAccountName

add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010
add-pssnapin Microsoft.Exchange.Management.Powershell.Support
"C:\Program Files\Microsoft\Exchange Server\V14\Bin\RemoteExchange.ps1"