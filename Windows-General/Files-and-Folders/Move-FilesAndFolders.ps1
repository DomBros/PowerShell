# Variables
$Source = "C:\Test\Source"
$Destination = "C:\Test\Destination"
$Options = "/E"

# Set event viewer logging
New-EventLog –LogName Application –Source "RoboCopy Script"
Install-PackageProvider -Name NuGet -MinimumVersion "2.8.5.201" -Force
Import-PackageProvider -Name NuGet -MinimumVersion "2.8.5.201" -Force
Save-Module -Name BurntToast -Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules" -Force

## Start script
Robocopy $Source $Destination $Options
If ($LASTEXITCODE -eq 0)
{
Write-Output "Robocopy - Copying completed successfully"
}
Else
{
$ErrorMessage = "Robocopy - Error copying file. Check Robocopy logs.."
Write-Output $ErrorMessage
Write-EventLog -LogName Application -Source "RoboCopy Script" -EntryType Error -EventId 1 -Message $ErrorMessage
New-BurntToastNotification -FirstLine $ErrorMessage
& {[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show("$ErrorMessage",'Robocopy')}
}