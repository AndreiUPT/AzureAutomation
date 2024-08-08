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
