param (
    [String] $resourceGroupName = 'RG-AndreiUPT',
    [String] $snapshotNamePrefix = 'snapshot-1',  #prefix name convention for full snapshots
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3',
    [String] $location = 'north europe'  
)

try {
    Connect-AzAccount -Identity
    Select-AzSubscription -SubscriptionId $subscriptionId
} catch {
    Write-Error -Message "Failed to authenticate using Managed Identity. Error: $_"
    throw $_
}

function Create-VMBackup {
    param (
        [String] $resourceGroupName,
        [String] $vmName,
        [String] $snapshotNamePrefix,
        [String] $location
    )

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $snapshotName = "$snapshotNamePrefix-$vmName-$timestamp"

      try {
        # VM OS disk ID
        $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
        $osDiskId = $vm.StorageProfile.OsDisk.ManagedDisk.Id

        # Snapshot configuration
        $snapshotConfig = New-AzSnapshotConfig -SourceUri $osDiskId -Location $location -CreateOption Copy

        # Create snapshot
        $snapshot = New-AzSnapshot -Snapshot $snapshotConfig -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName

        Write-Output "Snapshot '$snapshotName' created successfully for VM '$vmName' in resource group '$resourceGroupName' at location '$location'."
    } catch {
        Write-Error "Failed to create snapshot for VM '$vmName' in resource group '$resourceGroupName'. Error: $_"
        throw $_
    }
}
