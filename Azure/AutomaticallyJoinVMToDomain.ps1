# ----------------------------------------------------------------------------- 
# Script: AutomaticallyJoinVMToDomain.ps1 
# Author: Jean-Paul van Ravensberg
# Date: 10/18/2015 09:24:25 
# Keywords: 
# Comments:  This PowerShell Runbook for Azure will create a new machine and domain join it to your domain.
#            Script is based on the DexterPOSH script: http://www.dexterposh.com/2014/10/azure-automation-deploy-domain-join-vm.html
# 
# ----------------------------------------------------------------------------- 

workflow Deploy-Joined-VM
{
    param(
	    [parameter(Mandatory)] 
        [String] 
        $VMName,

	    [parameter(Mandatory)] 
        [String] 
        $DomainName,
		
	    [parameter(Mandatory)] 
        [String] 
        $ServiceName,
		
		[parameter(Mandatory)] 
        [String] 
        $InstanceSize = "Small",
		
		[parameter(Mandatory)] 
        [String] 
        $VMImageName = "WindowsServer2012R2DCGUI",
		
        [parameter(Mandatory)] 
        [String] 
        $AzureSubscriptionName = "Visual Studio Premium met MSDN",
        
        [parameter(Mandatory)] 
        [String] 
        $StorageAccountName,
        
		[parameter(Mandatory)] 
        [String] 
        $VMSubnetName = "subnet-1",
        
		[parameter(Mandatory)] 
        [String] 
        $VMVnetName,
        
		[parameter(Mandatory)] 
        [String] 
        $VMAffinityGroup = "West-Europe"   
    )
    $verbosepreference = 'continue'
    
	#Change this to your needs
	$DomainJoinAccount = "Domain Join Account"
	$LocalAccount = "LocalAdmin"
	$AutomationAccount = "Azure Automation Account"
	
    #Get the Credentials to authenticate to Azure
    Write-Verbose -Message "Getting the Credentials"
    $Cred = Get-AutomationPSCredential -Name $AutomationAccount
    $LocalCred = Get-AutomationPSCredential -Name $LocalAccount
    $DomainCred = Get-AutomationPSCredential -Name $DomainJoinAccount
    
    #Add the Account to the Workflow
    Write-Verbose -Message "Adding the Azure Automation Account to Authenticate" 
    Add-AzureAccount -Credential $Cred
    
    #select the Subscription
    Write-Verbose -Message "Selecting the $AzureSubscriptionName Subscription"
    Select-AzureSubscription -SubscriptionName $AzureSubscriptionName
    
    #Set the Storage for the Subscrption
    Write-Verbose -Message "Setting the Storage Account for the Subscription" 
    Set-AzureSubscription -SubscriptionName $AzureSubscriptionName -CurrentStorageAccountName $StorageAccountName
           
    #Select the most recent Server 2012 R2 Image
    Write-Verbose -Message  "Getting the Image details"
    $imagename = Get-AzureVMImage |
                     where-object -filterscript { $_.ImageName -eq $VMImageName } |
                     Sort-Object -Descending -Property PublishedDate | 
                     Select-Object -First 1 | 
                     select -ExpandProperty ImageName
    
    #use the above Image selected to build a new VM and wait for it to Boot
    $Username = $LocalCred.UserName
    $Password = $LocalCred.GetNetworkCredential().Password
    New-AzureQuickVM -Windows -ServiceName $ServiceName -Name $VMName -ImageName $imagename -Password $Password -AdminUsername $Username -SubnetNames $VMSubnetName -VNetName $VMVnetName -InstanceSize $InstanceSize -AffinityGroup $VMAffinityGroup -WaitForBoot
    Write-Verbose -Message "The VM is created and booted up now.. Doing a checkpoint"
    
    #CheckPoint the workflow
    CheckPoint-WorkFlow
    Write-Verbose -Message "Reached CheckPoint"

    #Call the Function Connect-VM to import the Certificate and give back the WinRM uri
    $WinRMURi = Get-AzureWinRMUri -ServiceName $ServiceName -Name $VMName | Select-Object -ExpandProperty AbsoluteUri

    InlineScript 
    { 
        do
        {
            #open a PSSession to the VM
            $Session = New-PSSession -ConnectionUri $Using:WinRMURi -Credential $Using:LocalCred -Name $using:VMName -SessionOption (New-PSSessionOption -SkipCACheck ) -ErrorAction SilentlyContinue 
            Write-Verbose -Message "Trying to open a PSSession to the VM $Using:VMName "
        } While (! $Session)
       
        #Once the Session is opened, first step is to join the new VM to the domain
        if ($Session)
        {
            Write-Verbose -Message "Found a Session opened to VM $using:VMname. Now will try to add it to the domain"
                                    
            Invoke-command -Session $Session -ArgumentList $Using:DomainCred,$Domain -ScriptBlock { 
                param($cred) 
                Add-Computer -DomainName $DomainName -DomainCredential $cred
                Restart-Computer -Force
            } 
        }        
    }
} #Workflow end