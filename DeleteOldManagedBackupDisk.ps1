param (
    [String] $resourceGroupName = 'RG-AndreiUPT',
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3',
    [String] $diskNameSubstring = 'backup',
    [Int] $retentionDays = 7
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
    # Get all managed disks in the specified resource group
    $disks = Get-AzDisk -ResourceGroupName $resourceGroupName

    # Get the current date
    $currentDate = Get-Date

    # Iterate through the disks and check for the specified conditions
    foreach ($disk in $disks) {
        # Check if the disk name contains the specified substring "backup"
        if ($disk.Name -like "*$diskNameSubstring*") {
            $diskCreationDate = $disk.TimeCreated
            $daysOld = ($currentDate - $diskCreationDate).Days
