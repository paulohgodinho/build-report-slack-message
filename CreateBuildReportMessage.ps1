param (
    [Parameter(Mandatory=$true, HelpMessage="Platform used to get json and make message")] 
    [string] $JobName,
    [Parameter(Mandatory=$true, HelpMessage="JSON data to get the information from")] 
    [string] $JsonData,
    [Parameter(Mandatory=$false, HelpMessage="Should return this item ready to be sent to Slack? Default is True")] 
    [boolean] $ReturnInsideBlockArray = $true

)

function CheckInputJson {
    param ( $inputJson)

    $necessaryProps = @(
        'nodeName',
        'duration',
        'commitHash',
        'branch'
        'url',
        'number',
        'user',
        'result'
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
    
    $jobDuration = [timespan]::FromMilliseconds($jobData.duration).ToString("hh\:mm\:ss")

    $color = 'red'
    switch ($jobData.result.ToLower()) {
        'success' { $color = 'green' }
        'aborted' { $color = 'blue' }
        'failure' { $color = 'red' }
    }

    $global:item_MachineUsed = $jobData.nodeName
    $global:item_TimeTook    = $jobDuration
    $global:item_Image       = "https://raw.githubusercontent.com/paulohgodinho/build-report-slack-message/main/AcessoryImages/$($jobData.imageName)_$($color).png"
    $global:item_SHA1        = $jobData.commitHash
    $global:item_URL         = $jobData.url
    $global:item_MainText    = "$($platform.ToUpper()) Build $($jobData.result)"
    $global:item_BuildNumber = $jobData.number
    $global:item_Branch      = $jobData.branch
    $global:item_extraText   = "\n By: $($jobData.user)"
}

$itemTemplate = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "/BlockKitTemplates/item.md") -Raw
$divider      = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "/BlockKitTemplates/divider.md") -Raw

if($null -eq $itemTemplate || $null -eq $divider) {
    Write-Error 'Not able to load message templates'
    throw
}

if((Test-Json -Json $JsonData) -eq $false) {
    Write-Error 'Not able to parse Input String to Json'
    throw
}

$jobData = $JsonData | ConvertFrom-Json
CheckInputJson -InputJson $jobData

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