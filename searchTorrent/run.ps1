# Echo
Write-Output "[START] Function SearchTorrent ..."

# Import Mandatory Modules
try {
    Import-Module "d:\home\sites\wwwroot\modules\mgmt-torrent-search.psm1"    
}
catch {
    Write-Error "[FAILED] import module <mgmt-torrent-search.psm1>"
}

# Variables
$result = @()

# Set data
$data = @(
    @{"Name" = "dc-s-legends-of-tomorrow"; "Season" = "02"; "StartEpisode"= 16},
    @{"Name" = "s-w-a-t"; "Season" = "01"; "StartEpisode"= 12},
)
 
# Searching for torrent files
foreach ($raw in $data) {
    $result += Find-TorrentFile -Name $raw.Name -Season $raw.Season -StartEpisode $startEpisode
}

Write-Output $result