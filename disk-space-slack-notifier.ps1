# Author - Amit P | Focis Information Systems | http://focis.nz
# 6 Jul 2016 - This scripts gets the remaining free space on a volume then sends a notification into slack based on a 
# pre-determined theshold. The script uses remaining disk space in GB and not percentages to determine alert condition.

# Configuration Variables #############################################################################################################
[string]$DriveLetter = "E" # the drive letter to check free space on *** WITHOUT THE SEMICOLON ***
[string]$DriveVolumeName = "Shared Folders" # a meaningful name for this volume

[int64]$WarningThresholdGB = 80 # set your threshold here in GB

$SlackURI = "https://hooks.slack.com/services/XXXX/XXXX/XXXX" # replace with your notification URL
$SlackNotifyChannel = "#sysadminz" # the channel to which notifications will be sent
$SlackNotifyUsername = "Disk Space Bot" # the message will appear to come from this user
$SlackEmoji = ":x:" # See https://get.slack.help/hc/en-us/articles/202931348-Emoji-and-emoticons
#######################################################################################################################################

# Get disk info
$diskInfo = Get-PSDrive $DriveLetter | Select-Object Free

# Convert to GiB
[int64]$diskGBFree = $diskInfo.Free
$diskGbFree = $diskGbFree / 1GB

# Check if the disk space threshold has been reached
If ($diskGBFree -lt $WarningThresholdGB) {

# If it has, craft a message to slack
$payload = @{
	"channel" = $SlackNotifyChannel;
	"icon_emoji" = $SlackEmoji;
	"text" = "Low disk space - only $diskGbFree GB remains on $DriveVolumeName";
	"username" = $SlackNotifyUsername;
}

# then send it
Invoke-WebRequest `
	-Uri $SlackURI `
	-Method "POST" `
	-Body (ConvertTo-Json -Compress -InputObject $payload)
}
