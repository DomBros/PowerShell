# ----------------------------------------------------------------------------- 
# Script: Fix-SCCMClientForCitrix.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 14-01-2016 - 09:39
# Keywords: 
# Comments: This script prepares the SCCM Client before capturing the
#           Citrix XenApp/XenDesktop Golden Image. This script works
#           for Server 2008 R2 and should work for 2012 (R2) too.
# -----------------------------------------------------------------------------

### Stopping CCMExec Service
Write-Output "Stopping CCMExec Service"
Stop-Service "ccmexec" -Force

$CCMExecSvc = Get-Service ccmexec
$CCMExecSvcStatus = $CCMExecSvc.Status
Write-Output "Current status CCMExec Service is $CCMExecSvcStatus."

### Removing SCCM Client Config File
Write-Output "Remove SCCM Client Config file if exists..."
Remove-Item "C:\Windows\SMSCFG.INI" -Force -Verbose

### Removing SCCM Client Certificates
$Certs = Get-Item cert:\LocalMachine\SMS
$Certs.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$SCCMCerts = Get-ChildItem $Certs.PSPath

Write-Output "Removing SMS Certificates"
Foreach ($Cert in $SCCMCerts) {
    $Certs.Remove($Cert)
}
$Certs.Close()

Read-Host -Prompt "Press Enter to exit"
