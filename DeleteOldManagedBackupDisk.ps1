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

# Check if the disk is older than the retention period
            if ($daysOld -ge $retentionDays) {
                # Delete the disk
                Remove-AzDisk -ResourceGroupName $resourceGroupName -DiskName $disk.Name -Force
                Write-Output "Deleted managed disk '$($disk.Name)' which is $daysOld days old."
            } else {
                Write-Output "Managed disk '$($disk.Name)' is $daysOld days old and not eligible for deletion."
            }
        } else {
            Write-Output "Managed disk '$($disk.Name)' does not match the naming criteria."
        }
    }
} catch {
    Write-Error -Message "Failed to delete old managed disks. Error: $_"
}
