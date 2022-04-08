# Get data from sample Json
# Create Message
# Send to Slack Webhook

$data = Get-Content './SampleData_success.json' -Raw
$message = ./CreateBuildReportMessage -JobName 'ios' -JsonData $data
#Invoke-RestMethod -Uri 'https://hooks.slack.com/my-web-hook-url' -Method Post -ContentType 'application/json' -Body $message

Write-Output 'Sent:' $message