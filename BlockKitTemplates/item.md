{
	"type": "section",
	"text": {
		"type": "mrkdwn",
		"text": "*<$item_URL|$item_MainText>*\n Build Number: $item_BuildNumber \n Branch: $item_Branch \n SHA1: $item_SHA1 $item_ExtraText"
	},
	"accessory": {
		"type": "image",
		"image_url": "$item_Image",
		"alt_text": "Image"
	}
},
{
	"type": "context",
	"elements": [
		{
			"type": "plain_text",
			"emoji": true,
			"text": ":desktop_computer:  Built on: $item_MachineUsed  |  :clock4: Took: $item_TimeTook"
		}
	]
}