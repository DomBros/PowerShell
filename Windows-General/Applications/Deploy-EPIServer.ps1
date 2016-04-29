<#
.SYNOPSIS
  Installs all the necessary components for the deployment of EPIServer.
.DESCRIPTION
  To do:
  - Error handling for MSI installation
  - Configure EPIServer from the script
  - Remove temporary directory if switch RemoveTempDir is being used
.NOTES
  Version:        1.0
  Author:         Jean-Paul van Ravensberg, Avanade
  Creation Date:  29-04-2016
  Purpose/Change: Initial script development
.EXAMPLE
  . .\Deploy-EPIServer.ps1
.LINK
  https://github.com/jvravensberg/PowerShell/blob/master/Windows-General/Applications/Deploy-EPIServer.ps1
#>

# Starting script
Write-Output "--- Starting script at $(Get-Date -Format "dd-MM-yyyy HH:mm") ---"

# Variables
#region Variables
$TempFolder = "$env:TEMP\$((New-GUID).Guid)"
$WMFSource = "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win8.1AndW2K12R2-KB3134758-x64.msu"

$AppDownloads=@{
  "Chrome.msi" = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BBED34609-91DA-DE03-91F3-EBA0F7C9B2E3%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers/dl/chrome/install/googlechromestandaloneenterprise.msi";
  "Firefox.exe" = "htps://download.mozilla.org/?product=firefox-46.0-SSL&os=win&lang=en-US";
  "WebPI.msi" = "http://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904/WebPlatformInstaller_amd64_en-US.msi";
  "WebPlatformInstaller.exe" = "http://go.microsoft.com/fwlink/?LinkId=255386";
  "VisualStudio.exe" = "http://go.microsoft.com/fwlink/?LinkID=699337&clcid=0x409";
  "SQLExpress.exe" = "http://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x64/SQLManagementStudio_x64_ENU.exe";
  "IISExpress.msi" = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=48264&6B49FDFB-8E5B-4B07-BC31-15695C5A2143=1";
  "dotNET.exe" = "https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe";
  "EPIVSExtension.vsix" = "https://visualstudiogallery.msdn.microsoft.com/4ad95160-e72f-4355-b53e-0994d2958d3e/file/76574/15/EPiServerVsExtension.vsix"
  }

$OtherApps=@{
  #"dotNET.exe" = ".\dotNET.exe /q /norestart";
  #"Firefox.exe" = ".\Firefox.exe -ms";
  #"SQLExpress.exe" = ".\SQLExpress.exe /q /Action=Install /Hideconsole /Features=SQL,Tools /InstanceName=SQLExpress /SQLSYSADMINACCOUNTS=Builtin\Administrators";
  #"VisualStudio.exe" = ".\VisualStudio.exe /Q /S";
  "EPIVSExtension.vsix" = "& 'C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\VSIXInstaller.exe' /q /a /i EPIVSExtension.vsix";
}

$PSPackages=@{
 "Microsoft.AspNet.Mvc" = "5.2.3";
 }
#endregion

# Create temporary folder to download the install files
if (!(Test-Path $TempFolder -PathType Container)) {
Write-Output "Creating temporary folder"
New-Item -Path $TempFolder -ItemType Directory -ErrorAction Continue
Set-Location $TempFolder
}
Else {Write-Output "Skipping -- Temporary folder already exists"; Set-Location $TempFolder}

# Check if PowerShell 5.0 is installed
if ($PSVersionTable.PSVersion -lt "5.0"){
Write-Host "PowerShell 5.0 not installed. Installing now..."
New-Item -Path "$TempFolder\WMF" -ItemType Directory -ErrorAction Continue
Write-Output "WARNING: Windows Management Framework 5.0 will be installed. Your server will reboot afterwards. Run this script again after the installation."
Pause
Invoke-WebRequest $WMFSource -OutFile "$TempFolder\WMF\WMF.msu"
Invoke-Expression "$TempFolder\WMF\WMF.msu /quiet"
Exit
}
Else {Write-Output "PowerShell 5.0 is installed. Skipping installation"}

# Download files needed for the installation
ForEach($AppDownload in $AppDownloads.GetEnumerator()) {

if (!(Test-Path $AppDownload.Name -PathType Leaf)) {
Write-Output "Downloading -- $($AppDownload.name) because it doesn't exists"
Invoke-WebRequest $AppDownload.Value -OutFile $AppDownload.Name
}
Else {Write-Output "Skipping -- $($AppDownload.name) exists, skipping download."}
}

# Install MSI applications
$MSIPackages = Get-Item -Path *.msi | % Name

ForEach($MSIPackage in $MSIPackages) {
Write-Output "Installing -- $MSIPackage"
msiexec /i $MSIPackage /qn /l* "$MSIPackage.log"
}

# Install other applications
ForEach($OtherApp in $OtherApps.GetEnumerator()) {

if (Test-Path $OtherApp.Name -PathType Leaf) {
Write-Output "Installing -- $($OtherApp.Name)"
Invoke-Expression $OtherApp.Value
}
Else {Write-Output "Skipping -- $($OtherApp.Name) doesn't exists, skipping installation."}
}

# Install PSPackages
Write-Output "Registering NuGet Package Sources"
Register-PackageSource -Name "NuGet.org" -ProviderName NuGet -Location "https://www.nuget.org/api/v2/" -Force -ForceBootstrap
Register-PackageSource -Name "NuGet EpiServer" -ProviderName NuGet -Location "http://nuget.episerver.com/feed/packages.svc/" -Force -ForceBootstrap

Write-Output "Installing NuGet Package Sources"
ForEach($PSPackage in $PSPackages.GetEnumerator()) {
Write-Output "Installing -- $($PSPackage.Name)"
Install-Package -Name $PSPackage.Name -MinimumVersion $PSPackage.Value -MaximumVersion $PSPackage.Value -Force -ForceBootstrap | Select Name, Status
}

# Finishing script
Write-Output "--- Finishing script at $(Get-Date -Format "dd-MM-yyyy HH:mm") ---"
