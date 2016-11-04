$computer = "Localhost"
$namespace = "root\ccm\Policy\Machine"
$PrimaryUsers = Get-WmiObject -class CCM_UserAffinity -computername $computer -namespace $namespace

foreach ($item in $PrimaryUsers) {
    if (($item.IsAutoAffinity -eq “True”) -or ($item.IsUserAffinitySet -eq "True"))
        {$PrimaryUser = $item.consoleuser
    }
}

$PrimaryUser = $PrimaryUser.Replace("YOURDOMAIN\", "")

$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment $tsenv.Value("PrimaryUser") = $PrimaryUser