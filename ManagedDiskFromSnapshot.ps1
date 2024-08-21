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
