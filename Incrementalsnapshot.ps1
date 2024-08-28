param (
    [String] $resourceGroup = 'RG-AndreiUPT',           
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3',
    [String] $region = 'northeurope'           
)

try {
    Connect-AzAccount -Identity
    Select-AzSubscription -SubscriptionId $subscriptionId
} catch {
    Write-Error -Message "Failed to authenticate using Managed Identity. Error: $_"
    throw $_
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Get all VMs in the specified resource group
$vms = Get-AzVM -ResourceGroupName $resourceGroup

foreach ($vm in $vms) {
    $vmName = $vm.Name
    Write-Output "Processing VM: $vmName"

    # Get the managed disks attached to the VM
    $osDisk = $vm.StorageProfile.OsDisk.ManagedDisk
    $dataDisks = $vm.StorageProfile.DataDisks

    # Create incremental snapshot for the OS disk
    try {
        $osDiskSnapshotName = "$($vmName)-osdisk-incremental-snapshot-$timestamp"
        $osDiskSnapshotConfig = New-AzSnapshotConfig -Location $region -CreateOption Copy -SourceResourceId $osDisk.Id -Incremental
        New-AzSnapshot -ResourceGroupName $resourceGroup -SnapshotName $osDiskSnapshotName -Snapshot $osDiskSnapshotConfig
        Write-Output "Incremental snapshot $osDiskSnapshotName created for OS disk of VM $vmName."
    } catch {
        Write-Error -Message "Failed to create incremental snapshot for OS disk of VM $vmName. Error: $_"
    }

    # Create incremental snapshots for the data disks
    foreach ($dataDisk in $dataDisks) {
        try {
            $dataDiskSnapshotName = "$($vmName)-$($dataDisk.Name)-incremental-snapshot"
            $dataDiskSnapshotConfig = New-AzSnapshotConfig -Location $region -CreateOption Copy -SourceResourceId $dataDisk.ManagedDisk.Id -Incremental
            New-AzSnapshot -ResourceGroupName $resourceGroup -SnapshotName $dataDiskSnapshotName -Snapshot $dataDiskSnapshotConfig
            Write-Output "Incremental snapshot $dataDiskSnapshotName created for data disk $($dataDisk.Name) of VM $vmName."
        } catch {
            Write-Error -Message "Failed to create incremental snapshot for data disk $($dataDisk.Name) of VM $vmName. Error: $_"
        }
    }
}
