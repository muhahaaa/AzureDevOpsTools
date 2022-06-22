<#
    .SYNOPSIS
    Enable Azure DevOps notifications

    .DESCRIPTION
    Enable Azure DevOps notifications after using with Azure DevOps Migration Tools
    Affected notifications:
    - Work Items Assign
    - @mentions (can't be set via Azure DevOps web access)

    Required PAT scopes:
    - Notifications - Read, write, & manage

    .NOTES
    Written by (c) Eike Hirdes, 2022 (https://github.com/muhahaaa/)
    This PowerShell script is released under the MIT license (https://github.com/muhahaaa/AzureDevOpsTools/blob/main/LICENSE.md)

    .EXAMPLE
    ./Enable-AzDevOpsNotifications.ps1 -OrganizationUrl http://dev.azure.com/your-org -Pat 12345xxxYOURPATxxx67890

    .LINK
    https://github.com/muhahaaa/AzureDevOps
#>

[CmdletBinding()]
param(
    # Azure DevOps organization URL (i.e. https://dev.azure.com/org)
    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string]$OrganizationUrl,
    # Azure DevOps PAT (scope: Notifications - Read, write, & manage)
    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string]$Pat
)

$subscriptions = $("ms.vss-work.my-workitem-assigned-to-changes-subscription", "ms.vss-mentions.identity-mention-subscription")

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("PAT:$($Pat)"))
$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}

foreach ($subscription in $subscriptions) {
    Write-Host "Set $subscription"
    $apiUri = "{0}/_apis/notification/Subscriptions/{1}?api-version=6.0" -f $OrganizationUrl, $subscription

    $response = Invoke-WebRequest -Uri $apiUri -Method PATCH -Headers $Headers -Body "{'status':0}" -ContentType "application/json"

    if ($response.StatusCode -eq 200){
        Write-Host "- enabled"
    }
}