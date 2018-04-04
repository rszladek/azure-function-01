# Echo start
Write-Output "[START] Function GetSearchTorrentMessage ..."

# Service Bus trigger input
$message = Get-Content $torrentSearchMessage -Raw

# Check if message is empty or not
# messge empty nothing to do
# message not empty launch other function

# Step 1 - Send Notification
# Step 2 - Download file
# Step 3 - Upload file to storage account