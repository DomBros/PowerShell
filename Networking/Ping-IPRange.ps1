# ----------------------------------------------------------------------------- 
# Script: Ping-IPRange.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 22-10-2015 - 16:31
# Keywords: 
# Comments: Modified script based on http://powershell.com/cs/forums/t/18342.aspx
# 
# -----------------------------------------------------------------------------

$Subnet = "172.23.2."
$array1 = $()

1..10 | % {
    
    $Server = $Subnet + $_
    $status = @{ "Server" = $server;}
    if (Test-Connection $server -Count 1 -ea 0 -Quiet)
    { 
        $status["Results"] = "Up"
    } 
    else 
    { 
        $status["Results"] = "Down" 
    }
    New-Object -TypeName PSObject -Property $status -OutVariable serverStatus
    $array1 += $serverStatus

}