# Echo
Write-Output "[START] Function SearchTorrent ..."

# Import Mandatory Modules
try {
    Import-Module "..\modules\mgmt-torrent-search.psm1"    
}
catch {
    Write-Error "[FAILED] import module <mgmt-torrent-search.psm1>"
}

# Variables
$result = @()

# Set data
$data = @(
    @{"Name" = "dc-s-legends-of-tomorrow"; "Season" = "02"; "StartEpisode"= 1},
    @{"Name" = "s-w-a-t"; "Season" = "01"; "StartEpisode"= 1},
    @{"Name" = "the-flash"; "Season" = "04"; "StartEpisode"= 9},
    @{"Name" = "arrow"; "Season" = "06"; "StartEpisode"= 9}
)
 
# Searching for torrent files
foreach ($raw in $data) {
    $result += Find-TorrentFile -Name $raw.Name -Season $raw.Season -StartEpisode $startEpisode
}