$Computer = "LAP001"
Invoke-Command -ComputerName $Computer -ScriptBlock {
Write-Output "Enable Firewall Rule"
netsh firewall set service remotedesktop enable

Write-Output "Enable RDP"
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
}
