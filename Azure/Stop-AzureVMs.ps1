# ----------------------------------------------------------------------------- 
# Script: StopAzureVMs.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 10/18/2015 09:24:13 
# Keywords: 
# Comments: Script is based on the following TechNet article: http://blogs.technet.com/b/georgewallace/archive/2014/11/05/shutting-down-a-azure-vm-with-azure-automation.aspx
# 
# ----------------------------------------------------------------------------- 

workflow Stop-AzureVMOnSchedule {

param(
    	# Azure Automation Account.
    	[Parameter(Mandatory = $true)] 
    	[string]$AdAzureCred,

    	# The name of the VM(s) to start on schedule.  Can be wildcard pattern.
    	[Parameter(Mandatory = $true)] 
    	[string]$VMName,
	
    	# The service name that $VMName belongs to.
    	[Parameter(Mandatory = $true)] 
    	[string]$ServiceName,

        # The Azure Subscription Name
        [parameter(Mandatory = $true)] 
        [String]$AzureSubscriptionName,

        # The Azure Storage Account Name
        [parameter(Mandatory = $true)] 
        [String]$StorageAccountName
	) 

    $verbosepreference = 'continue'
	$Cred = Get-AutomationPSCredential -Name $AdAzureCred | Write-Verbose

	# Connect to Azure
	Add-AzureAccount -Credential $Cred | Write-Verbose

	# Select the Azure subscription 
	# TODO: Fill in the -SubscriptionName parameter with the name of your Azure subscription
	Select-AzureSubscription -SubscriptionName $AzureSubscriptionName
    Set-AzureSubscription -SubscriptionName $AzureSubscriptionName -CurrentStorageAccountName $StorageAccountName

    Write-Output "-------------------------------------------------------------------------"

    Write-Output "Starting the Shutdown NOW!"

    Stop-AzureVM -Name $VMName -ServiceName $ServiceName -Force -Verbose

    Write-Output "-------------------------------------------------------------------------"
 
}