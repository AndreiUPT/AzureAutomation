param (
    [String] $resourceGroupName = 'RG-AndreiUPT',
    [String] $automationAccountName = 'AndreiUPTAutomation',
    [String] $subscriptionId = 'a24b4eab-e1ce-49f2-b025-cf22b0e48aa3',
    [String] $vaultName = 'aio-kv-upt'
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
