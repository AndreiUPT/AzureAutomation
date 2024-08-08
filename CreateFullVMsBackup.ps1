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
