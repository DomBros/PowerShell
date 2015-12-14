# ----------------------------------------------------------------------------- 
# Script: New-DeviceGuardPolicy.ps1
# Author: Jean-Paul van Ravensberg
# Date: 14-12-2015 - 13:46
# Keywords: 
# Comments: This script creates a new Device Guard policy. Credits to 
#           the original author.
# 
# -----------------------------------------------------------------------------

# Create a shadow copy to avoid scan failures from locks (in use files)
# Scan offline volume too
$S1 = (Get-WmiObject -List Win32_ShadowCopy).Create("C:\", "ClientAccessible")
$S2 = Get-WmiObject Win32_ShadowCopy | ? {$_.ID -eq $S1.ShadowID}
$D = $S2.DeviceObject + "\"
cmd /c mklink /d C:\scpy "$D"

# Generate new policy from scan of your golden system / image
# Doing this at Certificate level (file/hash)
# Problem with hashlevel is that if a file gets updated, it's no longer trusted.
# Filepath is where the file will be saved
# ScanPath = shadowcopy path
# UserPEs = looking for both the kernel mode binaries and user mode binaries
# Looking for Portable Executables, checks for a user mode or kernel mode binary and creates the appropriate rules in the policy
New-CIPolicy -Level PcaCertificate -FilePath C:\Demo\DemoPolicy.xml -ScanPath C:\scpy -UserPEs

# Delete the shadow copy afterwards
"vssadmin delete shadows /Shadow=""$($S2.ID.ToLower())"" /Quiet" | iex

# Check the contents of the policy
C:\Users\Jean-Paul\Desktop\FinalPolicy.xml

# Convert the policy file to a binary file and apply it to the system
ConvertFrom-CIPolicy C:\Demo\DemoPolicy.xml C:\Demo\DemoPolicy.bin
Copy C:\Demo\DemoPolicy.bin C:\Windows\System32\CodeIntegrity\SIPolicy.p7b

# If you sign the policy file it will protect it from the admin of the machine or even a physical attacker. Enable Audit Mode is turned on by default
# because you can lose because it's a powerful tool and you can lock out administrators and lock yourself out.
# Start in Audit Mode and enforce later.
# In the policy file, you will see the trusted certificates and if they are trusted in kernel or user mode.
# Event Viewer under code integrity you can check which programs wanted to run and under enforced mode, you'll see which programs
# where not allowed to run.
