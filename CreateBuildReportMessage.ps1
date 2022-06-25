param (
    [Parameter(Mandatory=$true, HelpMessage="Platform used to get json and make message")] 
    [string] $JobName,
    [Parameter(Mandatory=$false, HelpMessage="Should return this item ready to be sent to Slack? Default is True")] 
    [boolean] $ReturnInsideBlockArray = $true

)

function CheckInputJson {
    param ( $inputJson)

    $necessaryProps = @(
        'job_nodeName',
        'job_duration',
        'job_commitHash',
        'job_branch'
        'job_url',
        'job_number',
        'job_result'
    )

    $hasError = $false

    foreach ($item in $necessaryProps) {
        if(($inputJson.PSobject.Properties.Name -contains $item) -eq $false) {
            $hasError = $true;
            Write-Error "JSON is missing property: $item"
        }
    }

    if($hasError -eq $true) {
        throw 
    }
}

function SetVars {
    param (
        $jobData,
        $platform
    )
    
    $jobDuration = [timespan]::FromMilliseconds($jobData.job_duration).ToString("hh\:mm\:ss")

    $color = 'red'
    switch ($jobData.job_result.ToLower()) {
        'success' { $color = 'green' }
        'aborted' { $color = 'blue' }
        'failure' { $color = 'red' }
    }

    $global:item_MachineUsed = $jobData.job_nodeName
    $global:item_TimeTook    = $jobDuration
    $global:item_Image       = "https://raw.githubusercontent.com/paulohgodinho/build-report-slack-message/main/AcessoryImages/$($jobData.job_imageName)_$($color).png"
    $global:item_SHA1        = $jobData.job_commitHash
    $global:item_URL         = $jobData.job_url
    $global:item_MainText    = "$($platform.ToUpper()) Build $($jobData.job_result)"
    $global:item_BuildNumber = $jobData.job_number
    $global:item_Branch      = $jobData.job_branch
    $global:item_extraText   = "\n By: $($jobData.job_user)"
}

$itemTemplate = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "/BlockKitTemplates/item.md") -Raw
$divider      = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "/BlockKitTemplates/divider.md") -Raw

if($null -eq $itemTemplate || $null -eq $divider) {
    Write-Error 'Not able to load message templates'
    throw
}

$jsonFileName = "./jobData_$JobName.json"

# if((Test-Json -Json $JsonData) -eq $false) {
#     Write-Error "Not able to parse $jsonFileName file to Json"
#     throw
# }

$jobData = Get-Content -Path "$jsonFileName" | ConvertFrom-Json
CheckInputJson -InputJson $jobData

Write-Output $jobData

SetVars -jobData $jobData -platform "$JobName"
$itemBlock = $ExecutionContext.InvokeCommand.ExpandString($itemTemplate)

$message = @"
    $itemBlock,
    $divider
"@

if($ReturnInsideBlockArray -eq $true) {
    return "{ `"blocks`": [ $message ]}"
}

return $message