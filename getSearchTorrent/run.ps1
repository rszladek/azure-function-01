# Log Start function
Write-Output "[START] function < getSearchTorrent > ..."

# Variables
$result = @()
$sbTokenParams = @{
    ServiceBusResourceURI = $env:SBResourceUri
    AccessPolicyKeyName = $env:AccessPolicyName
    AccessPolicyKey = $env:AccessPolicyKey
}

# Import Mandatory Modules
try {
    Import-Module "D:\home\site\wwwroot\modules\mgmt-torrent-search.psm1"    
}
catch {
    Write-Error "[FAILED] import module <mgmt-torrent-search.psm1>"
}

# Retrieve HTTP data sent by function getTorrentData
try {
    $data = Get-Content $req -Raw | ConvertFrom-Json
} catch {
    Write-Output "[FAILED] to ready body message ..."
}

# Launch Torrent search
foreach ($raw in $data) {
    $torrentDetails = Find-TorrentFile -Name $raw.Show -Season $raw.Season -StartEpisode $raw.StartEpisode
    $result += $torrentDetails | ConvertFrom-Json
}

# Display result logs
$result = $result | ConvertTo-Json -Depth 10
Write-Output "[INFO] $result"

# Generate SB Token
try {
    $token = Set-AzureServiceBusSASToken @sbTokenParams
} catch {
    Write-Output "[FAILED] to generate token, `r`n $($_.Exception.Message) ..."
}

# Send message
try {
    $msg = Send-MessageTorrentAvailable -Message $result -SasToken $token
} catch {
    Write-Output "[FAILED] to send sb message, `r`n $($_.Exception.Message) ..."
}

# Log End function
Write-Output "[END] function < getSearchTorrent >"

# Send HTTP response
Out-File -Encoding Ascii -FilePath $res -inputObject "200"