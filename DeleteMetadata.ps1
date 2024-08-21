param (
    [String] $vaultName = 'aio-kv-upt',
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3',
    [Int] $retentionDays = 2
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
    # Get all secrets in the Key Vault
    $secrets = Get-AzKeyVaultSecret -VaultName $vaultName

    if ($null -eq $secrets) {
        Write-Output "No secrets found in the Key Vault."
        return
    }

$currentDate = Get-Date
    foreach ($secret in $secrets) {
        try {
            # Retrieve tags for the secret
            $secretDetails = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secret.Name
            $tags = $secretDetails.Tags

            if ($null -eq $tags -or -not $tags.ContainsKey('CreatedDate')) {
                Write-Output "No 'CreatedDate' tag found for secret '$($secret.Name)'. Skipping."
                continue
            }
