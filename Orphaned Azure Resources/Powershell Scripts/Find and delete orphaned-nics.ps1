#Find and Delete Orphaned NICS


#Find and List of Orphaned NICs
Get-AzNetworkInterface | Select-Object Name,ResourceGroupName,VirtualMachine | Where-Object { $_.VirtualMachine -eq $null }

----------------------------------------------------------------
#Powershell Script - to find and Delete Orphaned NICs
$NICs = Get-AzNetworkInterface 
$Orphan = $Nics | Select-Object Name,ResourceGroupName,VirtualMachine | Where-Object { $_.VirtualMachine -eq $null }

Foreach ($nic in $Orphan){

$VMName=$nic.virtualmachine
$NICName=$nic.Name
$ResourceGroup=$nic.ResourceGroupName

Write-Host "NIC Name        : $NICName"
Write-Host "Resource Group  : $ResourceGroup"

Write-Host "Deleting NIC"
$nic | Remove-AzNetworkInterface -Force
Write-Host "NIC Deleted Successfully"

}
----------------------------------------------------------------