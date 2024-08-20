param (
    [String] $vaultName = 'aio-kv-upt',
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3',
    [String] $resourceGroupName = 'RG-AndreiUPT'
)

try {
    Connect-AzAccount -Identity
    Select-AzSubscription -SubscriptionId $subscriptionId
    Write-Output "Authenticated successfully."
} catch {
    Write-Error -Message "Failed to authenticate using Managed Identity. Error: $_"
    throw $_
}

