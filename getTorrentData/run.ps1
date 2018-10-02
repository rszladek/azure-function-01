# Log Start function
Write-Output "[START] function < getTorrentData > ..."

# Import Mandatory Modules
try {
    Import-Module "D:\home\site\wwwroot\modules\mgmt-torrent-search.psm1"
    Import-Module "D:\home\site\wwwroot\modules\AzureRmStorageTableCoreHelper.psm1"  
}
catch {
    Write-Error "[FAILED] import module"
}

# Variables
$storageAccount = $env:STORAGE_ACCOUNT
$storageAccountKey = $env:STORAGE_ACCOUNT_KEY
$storageTable = "tvshows"
$partitionKey = "show"

# Header
$headers = @{
    "Content-Type"="application/json"
}

# Create sa table context
$ctx = New-AzureStorageTableContext -StorageAccountName $storageAccount -StorageAccountKey $storageAccountKey -StorageTable $storageTable

# Retrieve data from table
$data = Get-DataFromSATableByPartitionKey -StorageTableContext $ctx -PartitionKey $partitionKey

# Invoke function getSearchTorrent
$baseUri = "https://asten-torrent-search.azurewebsites.net/api/HttpTriggerCSharp1?code=w1MHD4cEpNRij0xGFfKcrYE11cUbBLXJntK6jMM8bWUr2ChxPRGGcg=="

try {
    $req = Invoke-RestMethod -Method POST -Uri $baseUri -Headers $headers -Body $data
} catch {
    Write-Output $_.Exception.Message 
}

# Return function invoke result
Write-Output $req