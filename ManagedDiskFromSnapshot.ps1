param (
    [String] $resourceGroupName = 'RG-AndreiUPT',
    [String] $diskNamePrefix = 'backupDisk-',
    [Int] $diskSizeGB = 128,
    [String] $location = 'northeurope',
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3',
    [String] $snapshotPrefix = 'snapshot-1'
)

try {
    Connect-AzAccount -Identity
    Select-AzSubscription -SubscriptionId $subscriptionId
    Write-Output "Authenticated successfully."
} catch {
    Write-Error -Message "Failed to authenticate using Managed Identity. Error: $_"
    throw $_
}

try {
    # Retrieve all snapshots in the resource group
    $snapshots = Get-AzSnapshot -ResourceGroupName $resourceGroupName

    if ($null -eq $snapshots) {
        Write-Error "No snapshots found in resource group '$resourceGroupName'."
        exit
    }

# Filter snapshots based on the region/location, prefix, and type (excluding incremental snapshots)
    $filteredSnapshots = $snapshots | Where-Object {
        $_.Location -eq $location -and
        $_.Name -like "$snapshotPrefix*" 
    }

    if ($null -eq $filteredSnapshots -or $filteredSnapshots.Count -eq 0) {
        Write-Error "No snapshots found with prefix '$snapshotPrefix' in location '$location'."
        exit
    }

    # Find the newest snapshot based on creation time
    $newestSnapshot = $filteredSnapshots | Sort-Object -Property TimeCreated -Descending | Select-Object -First 1

    if ($null -eq $newestSnapshot) {
        Write-Error "Failed to find the newest snapshot with prefix '$snapshotPrefix' in location '$location'."
        exit
    }

    # Output the snapshot details for verification
    Write-Output "Newest Snapshot ID: $($newestSnapshot.Id)"
    Write-Output "Snapshot Name: $($newestSnapshot.Name)"
    Write-Output "Snapshot Creation Time: $($newestSnapshot.TimeCreated)"
    Write-Output "Snapshot Size (GB): $($newestSnapshot.DiskSizeGB)"
    Write-Output "Snapshot Location: $($newestSnapshot.Location)"
