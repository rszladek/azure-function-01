# Log Start function
Write-Output "[START] function < getSearchTorrentMessage > ..."

# Import Mandatory Modules
try {
    Import-Module "D:\home\site\wwwroot\modules\mgmt-html-rendering.psm1"
}
catch {
    Write-Error "[FAILED] import module"
}

# Variables
$secpasswd = ConvertTo-SecureString $env:SENDGRID_KEY -AsPlainText -Force
$sendgridcreds = New-Object System.Management.Automation.PSCredential ($env:SENDGRID_ACCOUNT, $secpasswd)
$tables = ""
$style = $null

# Service Bus trigger input
$message = Get-Content $torrentSearchMessage -Raw | ConvertFrom-Json
$content = $message | ConvertFrom-Json

foreach ($torrent in $content) {
    Write-Output "Processing ... [$($torrent.Name)]"
    # Format HTML mail
    $contentFormat = @() 
    foreach($raw in $torrent.Result) {
        $hashtable = @{}
        $raw.psobject.properties | Foreach { $hashtable[$_.Name] = $_.Value }
        $contentFormat += $hashtable
    }

    # Remove uneeded keys
    $mailOutput = @()
    foreach ($raw in $contentFormat) {
        $mailOutput += @{"Episode" = $raw.Episode; "Disponible" = $raw.Available}
    }

    # Set table html
    $title = "[" + $torrent.Name + "]" + " saison " + $torrent.Season
    $table = New-AstenHTMLTable -InputObject $mailOutput -Title $title
    $tables += $table.Table
    $style = $table.Style
}

$head = New-AstenHTMLHead -Style $style -Title "AstenFR TV Shows Tracking"
$html = New-AstenHTMLReport -Head $head -Body $tables

try {
    # Send Mail with content
    $paramsMail = @{
        "smtpServer" = $env:SMTP_SERVER
        "Port" = $env:SMTP_PORT
        "From" = $env:MAIL_FROM
        "To" = $env:MAIL_TO
        "Subject" = $env:MAIL_SUBJECT
        "Credential" = $sendgridcreds     
    }
    Send-MailMessage @paramsMail -Body $html -UseSsl -BodyAsHtml -ErrorAction Stop
} catch {
    Write-Output "[Failed] cannot send mail from sendgrid, $($_.Exception.Message)"
}

Write-Output "[END] function < getSearchTorrentMessage > ..."