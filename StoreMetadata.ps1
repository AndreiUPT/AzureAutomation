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

try {
    # Get all snapshots in the resource group
    $snapshots = Get-AzSnapshot -ResourceGroupName $resourceGroupName

    foreach ($snapshot in $snapshots) {
        $snapshotName = $snapshot.Name

        # Create a hashtable with snapshot details
        $snapshotDetails = @{
            Id           = $snapshot.Id
            Name         = $snapshot.Name
            Location     = $snapshot.Location
            CreationTime = $snapshot.TimeCreated.ToString("o")  # ISO 8601 format
            DiskSizeGB   = $snapshot.DiskSizeGB
            OsType       = $snapshot.OsType
        }

# Convert the hashtable to JSON
$snapshotDetailsJson = $snapshotDetails | ConvertTo-Json -Depth 10

# Convert JSON to SecureString
$secureStringValue = $snapshotDetailsJson | ConvertTo-SecureString -AsPlainText -Force

# Set the secret in Azure Key Vault
Set-AzKeyVaultSecret -VaultName $vaultName -Name "$($snapshotName)-metadata" -SecretValue $secureStringValue

Write-Output "Snapshot details for '$snapshotName' stored successfully."
}
} catch {
    Write-Error -Message "Failed to store snapshot details. Error: $_"
}
