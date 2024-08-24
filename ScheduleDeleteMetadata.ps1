param (
    [String] $resourceGroupName = 'RG-AndreiUPT',
    [String] $automationAccountName = 'AndreiUPTAutomation',
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3',
    [String] $runbookName = 'DeleteMetadata', 
    [String] $scheduleName = 'DailyDeleteMetadataSchedule(2DaysRetention)'
)

function Register-RunbookWithSchedule {
    param (
        [String] $runbookName,
        [String] $scheduleName,
        [String] $intervalType,
        [Int] $interval,
        [Datetime] $startTime,
        [Hashtable] $runbookParameters
    )

 try {
        # Create or update schedule
        $schedule = Get-AzAutomationSchedule -ResourceGroupName $resourceGroupName `
                                             -AutomationAccountName $automationAccountName `
                                             -Name $scheduleName -ErrorAction SilentlyContinue
        if ($null -eq $schedule) {
            if ($intervalType -eq 'Day') {
                $schedule = New-AzAutomationSchedule -ResourceGroupName $resourceGroupName `
                                                     -AutomationAccountName $automationAccountName `
                                                     -Name $scheduleName `
                                                     -StartTime $startTime `
                                                     -DayInterval $interval `
                                                     -TimeZone 'UTC'
            }

            if ($null -ne $schedule) {
                Write-Output "Schedule '$scheduleName' created successfully."
            } else {
                Write-Error "Failed to create schedule '$scheduleName'."
                return
            }
        } else {
            Write-Output "Schedule '$scheduleName' already exists."
        }