#Find and List of Orphaned NSGs
Get-AZNetworkSecurityGroup | Where-Object { $_.NetworkInterfaces.count -eq 0 } | Select-Object name

----------------------------------------------------------------
#Find and Delete Orphaned NSGs
$NSGs = Get-AzNetworkSecurityGroup
$Orphan = $NSGs | Select-Object name,resourcegroupname | Where-Object { $_.NetworkInterfaces.count -eq 0 }

Foreach ($nsg in $Orphan){
$ResourceGroup=$nsg.resourcegroupname
$NSGName=$nsg.name
Write-Host "NSG Name        : $NSGName"
Write-Host "ResourceGoupName: $ResourceGroup"
#Write-Host "Deleting NSG"
#$nsg | Remove-AzDisk -Force
#Write-Host "NSG Successfully Deleted"
}




