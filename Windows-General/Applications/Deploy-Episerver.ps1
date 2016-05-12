<#
.SYNOPSIS
  Installs all the necessary components for the deployment of Episerver.
.DESCRIPTION
  This script installs all the necessary components for the deployment of Episerver.
  The script also installs Chrome and Firefox as well as Visual Studio. You can skip
  the deployment of apps by placing a '#' character before the application in the
  AppDownloads and OtherApps hashtables.
.PARAMETER PreserveTempDir
  This switch will preserve the temporary directory after running the script.
.NOTES
  Version:        1.0
  Author:         Jean-Paul van Ravensberg, Avanade
  Creation Date:  29-04-2016
  Purpose/Change: Initial script development
  --------------------------------------------------
  Version:        1.1
  Status:         Draft
  Author:         Jean-Paul van Ravensberg, Avanade
  Changed Date:   02-05-2016
  Purpose/Change: Added several improvements, including:
  - Error handling for application installation.
  - Replaced Invoke-Expression (https://blogs.msdn.microsoft.com/powershell/2011/06/03/invoke-expression-considered-harmful/)
  - Only continue with the script when the running application has been processed.
  - Minor bug fixes.
  --------------------------------------------------
  Version:        1.2
  Status:         Draft
  Author:         Jean-Paul van Ravensberg, Avanade
  Changed Date:   02-05-2016
  Purpose/Change: Added several improvements, including:
  - Downloading files in parallel as a job, instead of downloading one by one.
  - Replaced the New-GUID command with the Get-Random command, because of compatibility with older PowerShell versions.
  - Minor bug fixes.
  --------------------------------------------------
  Version:        1.3
  Status:         Final
  Author:         Jean-Paul van Ravensberg, Avanade
  Changed Date:   03-05-2016
  Purpose/Change: Added several improvements, including:
  - Downloading apps in parallel. (Takes +/- 10 min to download all apps)
  - Check if app has been installed before.
  - Reboot after SQL Express and Visual Studio installation.
  - Removed manual .NET installation because it's installed during Visual Studio installation.
  - Restart at the end of the script.
  - Minor bug fixes
  --------------------------------------------------
  Version:        1.4
  Status:         Final
  Author:         Jean-Paul van Ravensberg, Avanade
  Changed Date:   12-05-2016
  Purpose/Change: Added several improvements, including:
  - Added smtp4dev package to the deployment
  - Turned off IE Enhanced Security Mode
.EXAMPLE
  PS C:\> .\Deploy-Episerver.ps1
  This will run the script and remove the temporary directory after running the script.
.EXAMPLE
  PS C:\> .\Deploy-Episerver.ps1 -PreserveTempDir
  This will run the script and keep the temporary directory after running the script.
.LINK
  GitHub: https://github.com/jvravensberg/PowerShell/blob/master/Windows-General/Applications/Deploy-Episerver.ps1
#>

#Requires -RunAsAdministrator
#Requires -Version 4.0

[CmdletBinding()]
param (
[Parameter(Mandatory=$False)]
[Switch]$PreserveTempDir
)

# Starting script & writing header information
Clear-Host
Write-Output "--- Starting script at $(Get-Date -Format "dd-MM-yyyy HH:mm") ---"
If ($PreserveTempDir -eq $True) {
    Write-Output "INFO -- PreserveTempDir switch is set"
    }

# Variables
#region Variables

# Windows Management Framework 5 download location
$WMFSource = "https://download.microsoft.com/download/2/C/6/2C6E1B4A-EBE5-48A6-B225-2D2058A9CEFB/Win8.1AndW2K12R2-KB3134758-x64.msu"

# All the applications that needs to be downloaded
$AppDownloads=@{
  "ChromeSetup.msi" = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BBED34609-91DA-DE03-91F3-EBA0F7C9B2E3%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers/dl/chrome/install/googlechromestandaloneenterprise.msi";
  "FirefoxSetup.exe" = "https://download.mozilla.org/?product=firefox-46.0-SSL&os=win&lang=en-US";
  "WebPISetup.msi" = "http://download.microsoft.com/download/C/F/F/CFF3A0B8-99D4-41A2-AE1A-496C08BEB904/WebPlatformInstaller_amd64_en-US.msi";
  "VisualStudioSetup.exe" = "http://go.microsoft.com/fwlink/?LinkID=699337&clcid=0x409";
  "SQLExpressSetup.exe" = "http://download.microsoft.com/download/8/D/D/8DD7BDBA-CEF7-4D8E-8C16-D9F69527F909/ENU/x64/SQLManagementStudio_x64_ENU.exe";
  "IISExpressSetup.msi" = "https://download.microsoft.com/download/C/E/8/CE8D18F5-D4C0-45B5-B531-ADECD637A1AA/Dev14%20Update%201%20MSIs/iisexpress_amd64_en-US.msi";
  "smtp4devSetup.zip" = "https://smtp4dev.codeplex.com/downloads/get/269147#";
}

# Installation query switches for .EXE apps
$OtherApps=@{
  "FirefoxSetup.exe" = "-ms";
  "SQLExpressSetup.exe" = "/QS /Action=Install /Hideconsole /IAcceptSQLServerLicenseTerms=True /Features=SQL,Tools /InstanceName=SQLExpress /SQLSYSADMINACCOUNTS=Builtin\Administrators";
  "VisualStudioSetup.exe" = "/passive";
}

# Portable installation locations
$PortableApps=@{
  "smtp4dev.exe" = "$ENV:AppData\Microsoft\Windows\Start Menu\Programs\Startup";
}

# NuGet Packages that needs to be installed during the installation
$PSPackages=@{
 "Microsoft.AspNet.Mvc" = "5.2.3";
 }
#endregion

#region Functions
function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name iexplore -Force
    Write-Output "IE Enhanced Security Configuration (ESC) has been disabled."
}
#endregion

# Set temporary directory to folder if folder already exists
$TempFolder = Get-Item "C:\Temp\Deploy-Episerver*" -ErrorAction SilentlyContinue

# Create temporary folder to download the install files if it doesn't exists
If ($TempFolder -eq $Empty) {
    Write-Output "INFO -- No temporary folder found."
    
    $TempFolder = "C:\Temp\Deploy-Episerver-$(Get-Random)"
    Write-Output "Creating -- Temporary folder"
    New-Item -Path $TempFolder -ItemType Directory > $null
}
Else {Write-Output "INFO -- Existing temporary folder found."}

# Set the temporary folder as current directory
Set-Location $TempFolder

# Disable Internet Explorer Enhanced Security
Disable-InternetExplorerESC

# Check if .NET Framework 3.5 is installed for SQL Server Management Tools. If not: install it
If ((Get-WindowsFeature -Name NET-Framework-Core).InstallState -contains "Installed") {
    Write-Output "Skipping -- .NET Framework 3.5 is installed, skipping installation."
}
Else {
    Write-Output "Installing -- .NET Framework has not been installed."
    Install-WindowsFeature -Name NET-Framework-Core
}

# Check if PowerShell 5.0 is installed. If not: install it
if ($PSVersionTable.PSVersion -lt "5.0"){
    Write-Output "Installing -- PowerShell 5.0 not installed."
    New-Item -Path "$TempFolder\WMF" -ItemType Directory -ErrorAction Continue
    Write-Output "WARNING -- Windows Management Framework 5.0 will be installed. Your server will reboot afterwards. Run this script again after the installation."
    Pause
    Invoke-WebRequest $WMFSource -OutFile "$TempFolder\WMF\WMF.msu"
    Write-Output "INFO -- Download complete - installing now."
    Write-Output "INFO -- Please don't close this window. The server will reboot shortly."
    Write-Output "INFO -- Open this script again after the reboot."
    Start-Process "$TempFolder\WMF\WMF.msu" -ArgumentList "/quiet" -Wait
}
Else {Write-Output "Skipping -- PowerShell 5.0 is installed, skipping installation."}

# Download files needed for the installation
ForEach($AppDownload in $AppDownloads.GetEnumerator()) {

# Check if application has already been downloaded. Otherwise, create a job to download it in parallel
if (!(Test-Path $AppDownload.Name -PathType Leaf)) {
    Write-Output "Downloading -- $($AppDownload.name) because it doesn't exists."
    
    $AppScriptBlock = {
    # Accept the loop variable across the job-context barrier
    param() 
    
    # Download the application
    Invoke-WebRequest $($args[0]).Value -OutFile "$($args[1])\$(($args[0]).Name)"
    }
    # Start the job
    Start-Job $AppScriptBlock -Name $AppDownload.Name -ArgumentList $AppDownload, $TempFolder  > $null
}
Else {Write-Output "Skipping -- $($AppDownload.name) exists, skipping download."}
}

# Wait for all to complete
Write-Output "INFO -- Waiting until all downloads are completed."
While (Get-Job -State "Running") { Start-Sleep 2 }

# Remove finished jobs
Remove-Job *
Write-Output "INFO -- Finished downloading at $(Get-Date -Format "dd-MM-yyyy HH:mm")"

# Create unzip folder for the ZIP contents
$UnzipFolder = Get-Item $TempFolder\Unzip -ErrorAction SilentlyContinue
If ($UnzipFolder -eq $Empty) {
    Write-Output "INFO -- No unzip folder found."
    
    $UnzipFolder = "$TempFolder\Unzip"
    Write-Output "Creating -- Unzip folder"
    New-Item -Path $UnzipFolder -ItemType Directory > $null
}
Else {Write-Output "INFO -- Existing temporary folder found."}

# Unpack portable applications
$ZipPackages = Get-Item -Path *.zip | % Name

ForEach ($ZipPackage in $ZipPackages) {
    Write-Output "Unpacking -- $ZIPPackage"
    $ZipSource = $TempFolder + "\" + $ZipPackage
    
    Add-Type -AssemblyName “system.io.compression.filesystem”
    [io.compression.zipfile]::ExtractToDirectory($ZipSource, $UnzipFolder)
}

# Move unpacked portable applications to folder
Foreach ($PortableApp in $PortableApps.GetEnumerator()) {
    Write-Output "Moving -- $($PortableApp.Name)"
    Copy-Item ($UnzipFolder + "\" + $($PortableApp.Name)) $PortableApp.Value -Force
}

# Install MSI applications
$MSIPackages = Get-Item -Path *.msi | % Name

ForEach($MSIPackage in $MSIPackages) {
    Write-Output "Installing -- $MSIPackage"
    $MSIArguments = "/i `"$MSIPackage`" /qn /l* `"$MSIPackage.log`""
    $MSIInstallation = (Start-Process msiexec -arg $MSIArguments -Wait -PassThru).ExitCode
    
    # If exit code is 0, the installation finished succesfully
    If ($MSIInstallation -ieq 0) {
        Write-Output "Success -- Installed $MSIPackage successfully"
        }
        Elseif ($MSIInstallation -ieq "1603") {
        Write-Output "Failed -- Installation for $MSIPackage failed. Exit code $MSIInstallation.`
    You may receive this error message if any one of the following conditions is true:`
    - Windows Installer is attempting to install an app that is already installed on your PC.`
    - The folder that you are trying to install the Windows Installer package to is encrypted.`
    - The drive that contains the folder that you are trying to install the Windows Installer package to is accessed as a substitute drive.`
    - The SYSTEM account does not have Full Control permissions on the folder that you are trying to install the Windows Installer package to."
        }
        Else {
        Write-Output "Failed -- Installation for $MSIPackage failed. Exit code $MSIInstallation"
        }
}

# Install other applications
Write-Output "INFO -- Server will possibly be rebooted during the installation."

# Sort objects in $OtherApps by name so that Visual Studio and SQL Express will be installed first
ForEach($OtherApp in $OtherApps.GetEnumerator() | Sort-Object -Property Name -Descending)  {

# Check if application has already been installed
$AppInstall = Get-Content $TempFolder\Installed.txt -ErrorAction SilentlyContinue

# If application package exists and if file is not in the "Installed.txt" file, proceed with the installation
if ((Test-Path $OtherApp.Name -PathType Leaf) -and ($AppInstall -notcontains $OtherApp.Name)) {
    Write-Output "Installing -- $($OtherApp.Name)"

    # Installing Visual Studio or SQL Express could take a long time
    If ($OtherApp.Name -contains "VisualStudioSetup.exe" -or $OtherApp.Name -contains "SQLExpressSetup.exe") {
        Write-Output "INFO -- $($OtherApp.Name) installation could take up to 60 minutes to complete. Started at $(Get-Date -Format "dd-MM-yyyy HH:mm")"          
    }

    $OtherAppInstallation = (Start-Process $OtherApp.Name -ArgumentList $OtherApp.Value -Wait -PassThru).ExitCode
        If ($OtherAppInstallation -ieq 0) {
        Write-Output "Success -- Installed $($OtherApp.Name) successfully"

        # Add the application name to the Installed.txt file
        Add-Content -Value $($OtherApp.Name) -Path $TempFolder\Installed.txt
            
            # Reboot when Visual Studio or SQL Express finished the installation
            If ($OtherApp.Name -contains "VisualStudioSetup.exe" -or $OtherApp.Name -contains "SQLExpressSetup.exe") {
            Write-Output "INFO -- Rebooting now at $(Get-Date -Format "dd-MM-yyyy HH:mm")."
            Restart-Computer -Force
            }
        }
        Elseif ($OtherAppInstallation -ieq "-2068643838") {
        Write-Output "Success -- The state of the $($OtherApp.Name) installation was not changed after the setup execution."
        }
        Else {
        Write-Output "Failed -- Installation for $($OtherApp.Name) failed. Exit code $OtherAppInstallation"
        }
}
Else {Write-Output "Skipping -- $($OtherApp.Name) doesn't exists or already has been installed, skipping installation."}
}

# Register Package Providers
Write-Output "INFO -- Registering NuGet Package Sources"
Register-PackageSource -Name "NuGet.org" -ProviderName NuGet -Location "https://www.nuget.org/api/v2/" -Force -ForceBootstrap
Register-PackageSource -Name "NuGet Episerver" -ProviderName NuGet -Location "https://nuget.episerver.com/feed/packages.svc/" -Force -ForceBootstrap

# Installing NuGet Packages
Write-Output "Installing -- NuGet Packages"
ForEach($PSPackage in $PSPackages.GetEnumerator()) {
    Write-Output "Installing -- $($PSPackage.Name)"
    Install-Package -Name $PSPackage.Name -MinimumVersion $PSPackage.Value -MaximumVersion $PSPackage.Value -Force -ForceBootstrap | Select Name, Status
}

# Set location before next command. Otherwise the $TempFolder directory could not be removed.
Set-Location $env:SystemRoot

# Remove temporary folder if switch $PreserveTempDir isn't set
If ($PreserveTempDir -ne $True) {
    Write-Output "Deleting -- temporary directory"
    Remove-Item $TempFolder -Force -Recurse
    }
Else {Write-Output "INFO -- PreserveTempDir switch is set. Temporary directory will not be removed."}

# Finishing script
Write-Output "--- Finishing script at $(Get-Date -Format "dd-MM-yyyy HH:mm") ---"

# Reboot server and exit PowerShell
Write-Output "The server needs to be restarted."
Pause
Restart-Computer -Force
Exit
