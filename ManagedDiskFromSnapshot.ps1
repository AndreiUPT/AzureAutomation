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
