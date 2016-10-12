# Original script from https://wprogramming.wordpress.com/2011/07/14/examples-in-automation-rdp-port-change/

param(
  [parameter(Mandatory=$true)]
  [int]
  $port = "443"
)

# Set the registry value for the port
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Termin*Server\WinStations\RDP*CP\ -Name PortNumber -Value $port

# Open the firewall port for Remote Desktop and Remote Desktop FX
netsh advfirewall firewall add rule name="Custom RDP (in)" protocol=TCP dir=in localport=$port action=allow program="System"
netsh advfirewall firewall add rule name="Custom RDP Remote FX (in)" protocol=TCP dir=in localport=$port action=allow program='%SystemRoot%\system32\svchost.exe'

# Disable the previous rules on the old port
netsh advfirewall firewall delete rule name='Remote Desktop (TCP-In)'
netsh advfirewall firewall delete rule name='Remote Desktop - RemoteFX (TCP-In)'

# Restart the service to finalize the changes
# Use -Force as it has dependant services
Restart-Service -Name TermService -Force
