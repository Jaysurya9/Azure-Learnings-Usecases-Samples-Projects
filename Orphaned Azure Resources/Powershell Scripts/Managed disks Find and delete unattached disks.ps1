# Set deleteUnattachedDisks=1 if you want to delete unattached Managed Disks
# Set deleteUnattachedDisks=0 if you want to see the Id of the unattached Managed Disks
$TagName = "AppliactionOwner"
$TagValue = "ApprovedDelete"
$deleteUnattachedDisks=0
$managedDisks = Get-AzDisk -TagName $TagName -TagValue $TagValue
foreach ($md in $managedDisks) {
    # ManagedBy property stores the Id of the VM to which Managed Disk is attached to
    # If ManagedBy property is $null then it means that the Managed Disk is not attached to a VM
    if($md.ManagedBy -eq $null){
        if($deleteUnattachedDisks -eq 1){
            Write-Host "Deleting unattached Managed Disk with Id: $($md.Id)"
            $md | Remove-AzDisk -Force
            Write-Host "Deleted unattached Managed Disk with Id: $($md.Id) "
        }else{
            $md.Id
        }
    }
    
#Part 2  
$DiskName = ""
$ResourceGroupName = ""
$SubscriptionName = ""
$TagName = ""
$TagValue = ""

Remove-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $DiskName -Force;
#or
Remove-AzDisk -TagName $TagName -TagValue $TagValue -Force;

