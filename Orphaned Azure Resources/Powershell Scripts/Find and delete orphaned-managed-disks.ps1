#Find and Delete Orphaned Managed Disks

#Find and  List of Unattached Disks - Orphaned
Get-AzDisk | Select-Object -Property Name,ResourceGroupName,Type,DiskSizeGB,DiskState | Where-Object -Property DiskState -eq “Unattached”

# Find and  List of Attached Disks
Get-AzDisk | Select-Object -Property Name,ResourceGroupName,Type,DiskSizeGB,DiskState | Where-Object -Property DiskState -eq “Attached”

# Find and List of Reserved Disks
Get-AzDisk | Select-Object -Property Name,ResourceGroupName,Type,DiskSizeGB,DiskState | Where-Object -Property DiskState -eq “Reserved”

#Powershell Script –to find and delete orphaned managed disks
$Disk = Get-AzDisk
$Orphan = $Disk | Select-Object -Property Name,ResourceGroupName,Type,DiskSizeGB,DiskState
$state_reserved = $Orphan | Where-Object -Property DiskState -eq “Reserved”
$state_unattached = $Orphan | Where-Object -Property DiskState -eq “Unattached”
$State_attached = $Orphan | Where-Object -Property DiskState -eq “attached”

#Find and Delete - Unattached State Disk
Foreach ($disks in $state_unattached){
$ResourceGroup=$disks.ResourceGroupName
$DiskName=$disks.Name
$DiskState=$disk.DiskState
Write-Host "Disk Name        : $DiskName"
Write-Host "ResourceGoupName : $ResourceGroup"
Write-Host "Disk State       : $DiskState"
Write-Host "Deleting unattached Managed Disk"
#$disks | Remove-AzDisk -Force
Write-Host "Successfully Deleted"
Write-Host ""
}

#View Reserved State Disks
Foreach ($disks in $state_reserved){
$ResourceGroup=$disks.ResourceGroupName
$DiskName=$disks.Name
$DiskState=$disk.DiskState
Write-Host "Disk Name        : $DiskName"
Write-Host "ResourceGoupName : $ResourceGroup"
Write-Host "Disk State       : $DiskState"
Write-Host ""
}

#View Attached State Disks
Foreach ($disks in $State_attached){
$ResourceGroup=$disks.ResourceGroupName
$DiskName=$disks.Name
$DiskState=$disk.DiskState
Write-Host "Disk Name        : $DiskName"
Write-Host "ResourceGoupName : $ResourceGroup"
Write-Host "Disk State       : $DiskState"
Write-Host ""
}
