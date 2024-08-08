param (
    [String] $sourceResourceGroup = 'RG-AndreiUPT',
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3',
    [String] $targetRegion = "westeurope"
)

try {
    # Authenticate and select subscription
    Connect-AzAccount -Identity
    Select-AzSubscription -SubscriptionId $subscriptionId
} catch {
    Write-Error -Message "Failed to authenticate using Managed Identity. Error: $_"
    throw $_
}

# Get all snapshots in the source resource group
$snapshots = Get-AzSnapshot -ResourceGroupName $sourceResourceGroup

foreach ($snapshot in $snapshots) {
    # Check if the snapshot is incremental
    if ($snapshot.Incremental -eq $true) {
        try {
            # Define the new snapshot name
            $snapshotCopyName = "$($snapshot.Name)-copy-newRegion"
            
            # Create the snapshot copy in the target region
            $snapshotConfig = @{
                Location = $targetRegion
                CreateOption = "CopyStart"
                SourceResourceId = $snapshot.Id
                Incremental = $true
            }

            New-AzSnapshot -ResourceGroupName $sourceResourceGroup -SnapshotName $snapshotCopyName -Snapshot (New-AzSnapshotConfig @snapshotConfig)

            Write-Output "Incremental snapshot $($snapshot.Name) copied to $targetRegion as $snapshotCopyName."
        } catch {
            Write-Error -Message "Failed to copy snapshot $($snapshot.Name) to $targetRegion. Error: $_"
        }
    } else {
        Write-Output "Snapshot $($snapshot.Name) is not incremental. Skipping."
    }
}
