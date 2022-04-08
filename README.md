# build-report-slack-message
Builds a [Slack Block Kit](https://api.slack.com/block-kit) message payload using information from a Jenkins job, or any other information source. The message is contructed based on templates found in [BlockKitTemplates](BlockKitTemplates/) folder.

**Clone the repository and try it out with:**
```
$data = Get-Content './SampleData_success.json' -Raw
$message = ./CreateBuildReportMessage -JobName 'ios' -JsonData $data
Write-Output $message
```

## Available Parameters:
**JsonData** - The JSON string containing the required paramteres, check this [SampleData](SampleData_success.json) for a list of the required parameters. <br>
**JobName** - The name of the JOB, it will be used in the title of the message and to get the matching image from the folder, example: *myplatform*_green.png will be used in case of success. <br>
**ReturnInsideBlockArray** - True by default, the message comes inside ```{block: []}``` array, ready to be sent to Slack. If you are composing multiple messages, set this to false to get the raw Block Kit elements.

Call Sample:
```
.\CreateBuildReportMessage -JobName 'MyBuild' -JsonData 'JsonData' -ReturnInsideBlockArray $true
```

## Samples
iOS Build Success <br>
![Success](Media/success_sample.png) <br>
Apple TV Build Failure <br>
![Failure](Media/failure_sample.png)

## Jenkins usage

// TODO