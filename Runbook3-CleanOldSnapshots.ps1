param (
    [String] $resourceGroupName = 'RG-AndreiUPT',
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3',
    [Int] $retentionDays = 1
)

try {
    Connect-AzAccount -Identity
    Select-AzSubscription -SubscriptionId $subscriptionId
} catch {
    Write-Error -Message "Failed to authenticate using Managed Identity. Error: $_"
    throw $_
}

function Cleanup-OldSnapshots {
    param (
        [String] $resourceGroupName,
        [Int] $retentionDays
    )

    try {
        $cutoffDate = (Get-Date).AddDays(-$retentionDays)
        $snapshots = Get-AzSnapshot -ResourceGroupName $resourceGroupName | Where-Object { $_.TimeCreated -lt $cutoffDate }

        foreach ($snapshot in $snapshots) {
            Remove-AzSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshot.Name -Force
            Write-Output "Deleted old snapshot '$($snapshot.Name)' created on '$($snapshot.TimeCreated)'."
        }
    } catch {
        Write-Error "Failed to cleanup old snapshots. Error: $_"
        throw $_
    }
}

Cleanup-OldSnapshots -resourceGroupName $resourceGroupName -retentionDays $retentionDays
