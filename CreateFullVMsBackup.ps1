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
