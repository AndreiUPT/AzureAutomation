param (
    [String] $resourceGroupName = 'RG-AndreiUPT',
    [String] $automationAccountName = 'AndreiUPTAutomation',
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3'
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
        # Create or update the schedule
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
            } elseif ($intervalType -eq 'Week') {
                $schedule = New-AzAutomationSchedule -ResourceGroupName $resourceGroupName `
                                                     -AutomationAccountName $automationAccountName `
                                                     -Name $scheduleName `
                                                     -StartTime $startTime `
                                                     -WeekInterval $interval `
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

        # Register the runbook with the schedule
        $registration = Register-AzAutomationScheduledRunbook -ResourceGroupName $resourceGroupName `
                                                             -AutomationAccountName $automationAccountName `
                                                             -RunbookName $runbookName `
                                                             -ScheduleName $schedule.Name `
                                                             -Parameters $runbookParameters

        if ($null -ne $registration) {
            Write-Output "Runbook '$runbookName' registered with schedule '$scheduleName' successfully."
        } else {
            Write-Error "Failed to register runbook '$runbookName' with schedule '$scheduleName'."
        }
    } catch {
        Write-Error -Message "An error occurred: $_"
    }
}

try {
    Connect-AzAccount -Identity
    Select-AzSubscription -SubscriptionId $subscriptionId
    Write-Output "Authenticated successfully."
} catch {
    Write-Error -Message "Failed to authenticate using Managed Identity. Error: $_"
    throw $_
}

# Schedule the runbook to create a managed disk from the newest snapshot
Register-RunbookWithSchedule -runbookName 'DeleteOldManagedBackupDisk' `
                             -scheduleName 'WeeklyDeleteManagedBackupDiskSchedule' `
                             -intervalType 'Week' `
                             -interval 1 `
                             -startTime (Get-Date).Date.AddDays(7 - (Get-Date).DayOfWeek + [System.DayOfWeek]::Monday).AddHours(8) `
