# Import module and set location to SCCM Drive
Import-Module "D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"
Set-Location "P01:\"

# Create collections for packages
$PackageDeviceCollectionLocation = 'P01:\DeviceCollection\Packages'
$Packages = Get-CMPackage

Foreach ($Package in $Packages) {
    $PackageName = "Package - " + $Package.Manufacturer + " - " + $Package.Name
    Write-Output "Creating collection: $($PackageName)"
    
    Try {
        $PackageDeviceCollection = New-CMDeviceCollection -Name $PackageName -RefreshType ConstantUpdate -LimitingCollectionName "All Systems"
        $PackageDeviceCollectionMove = Move-CMObject -FolderPath $PackageDeviceCollectionLocation -InputObject $PackageDeviceCollection
        }

    Catch {
        Write-Output $_.Exception
        }
}

# Create collections for applications
$ApplicationDeviceCollectionLocation = 'P01:\DeviceCollection\Applications'
$Applications = Get-CMApplication

Foreach ($Application in $Applications) {
    $ApplicationName = "Application - " + $Application.Manufacturer + " - " + $Application.LocalizedDisplayName
    Write-Output "Creating collection: $($ApplicationName)"

    Try {
        $ApplicationDeviceCollection = New-CMDeviceCollection -Name $ApplicationName -RefreshType ConstantUpdate -LimitingCollectionName "All Systems"
        $ApplicationDeviceCollectionMove = Move-CMObject -FolderPath $ApplicationDeviceCollectionLocation -InputObject $ApplicationDeviceCollection
        }

    Catch {
        Write-Output $_.Exception
        }
}
