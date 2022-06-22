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
    This PowerShell script is released under the MIT license (https://github.com/muhahaaa/blob/main/LICENSE.md)

    .LINK
    https://github.com/muhahaaa/AzureDevOps
#>

[CmdletBinding()]
param(
    # Azure DevOps organization URI (i.e. https://dev.azure.com/org)
    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string]$OrganizationUrl,
    # Azure DevOps PAT (Scope: Notifications - Read, write, & manage)
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