# ----------------------------------------------------------------------------- 
# Script: Start-AzureVMsOnSchedule.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 10/18/2015 09:24:17 
# Keywords: 
# Comments: Script is based on the following TechNet script: https://gallery.technet.microsoft.com/scriptcenter/Start-Windows-Azure-b6c179b6
# 
# ----------------------------------------------------------------------------- 

workflow Start-AzureVMsOnSchedule {

param(
    	# Azure Automation Account.
    	[Parameter(Mandatory = $true)] 
    	[string]$AdAzureCred,

    	# The name of the VM(s) to start on schedule.  Can be wildcard pattern.
    	[Parameter(Mandatory = $true)] 
    	[string]$VMNames = "'DC1', 'CM1'",
	
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
	$Cred = Get-AutomationPSCredential -Name $AdAzureCred

	# Connect to Azure
	Add-AzureAccount -Credential $Cred | Write-Verbose

	# Select the Azure subscription 
	# TODO: Fill in the -SubscriptionName parameter with the name of your Azure subscription
	Select-AzureSubscription -SubscriptionName $AzureSubscriptionName
    Set-AzureSubscription -SubscriptionName $AzureSubscriptionName -CurrentStorageAccountName $StorageAccountName

    # Step 2 Start VM(s) first Cloud Service
    ForEach ($VMName in $VMNames) {
            Start-AzureVM –ServiceName $ServiceName –Name $VMName -Force -Verbose }

    Write-Output "Finishing runbook"
 
}