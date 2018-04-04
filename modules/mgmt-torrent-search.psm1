<#
    .synopsis
    Module contains functions/cmdlets in order to perform some torrent researches on Torrent9 
    .description
    Module contains following functions:
        -Find-TorrentFile
        -Send-MessageTorrentAvailable
        -Get-TorrentFile
        -Send-TorrentFileToSA
    .notes
    Author: ASTEN FR
#>

function Find-TorrentFile {
<#
    .synopsis
    Search for torrent file
    .description
    Search for torrent file
    Works for TV Show
    .parameter Name
    Tv show name
    .parameter Season
    Season number
    .parameter StartEpisode
    Episode from which to start searching
    .notes
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$Name,
        [Parameter(Mandatory=$true)]
        [Int16]$Season,
        [Parameter(Mandatory=$true)]
        [int16]$StartEpisode                
    )
    
    # Variables
    $url = "http://www.torrent9.red/get_torrent/"
    $extensionFile = ".torrent"
    $seasonNumber = "{0:D2}" -f $Season
    $endEpisode = 28
    $values = @()

    # Code Logic
    Write-Verbose -Message "[SEARCH] Torrent <$Name> - <S$seasonNumber> from episode <$StartEpisode>"

    try {
        for ($i = $StartEpisode; $i -lt $endEpisode; $i++) {
            # 2 digits format XX
            $episodeNumber = "{0:D2}" -f $i
            $requestUrl = $url + $Name + "-s" + $seasonNumber + "e" + $episodeNumber + "-vostfr-hdtv" + $extensionFile
            try {
                Write-Verbose " [CHECK] url <$requestUrl> ..."
                $request = Invoke-WebRequest -Uri $requestUrl
                $values += @{"Episode" = $episodeNumber; "URL" = $requestUrl; "Available" = $true; "ErrorMessage" = $null}
            }
            catch {
                # Stop exexution and send details
                $values += @{"Episode" = $episodeNumber; "URL" = $requestUrl; "Available" = $false; "ErrorMessage" = $_.Exception.Message}
                $i = $endEpisode
            }
            # wait before next request
            Start-Sleep -Seconds 5
        }

        # Return Result in JSON
        $result = @{"Name" = $Name; "Season" = $seasonNumber; "Result" = $values}
        Write-Output $result | ConvertTo-JSON
    }
    catch {
        # Send default exception
        Write-Error -Message $_.Exception.Message -ErrorAction Stop
    }
}

function Set-AzureServiceBusSASToken {
<#
    .synopsis
    Generate token for Azure Service Bus
    .description
    Generate token for Azure Service Bus
    .parameter ServiceBusResourceURI
    Service bus namespace
    .parameter AccessPolicyKeyName
    Access Policy Name
    .parameter AccessPolicyKey
    Access Policy Key
    .notes
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$ServiceBusResourceURI,
        [Parameter(Mandatory=$true)]
        [String]$AccessPolicyKeyName,
        [Parameter(Mandatory=$true)]
        [String]$AccessPolicyKey
    )

    # Set Token Expiration
    $endDate=[datetime]"4/11/2018 00:00"
    $origin = [DateTime]"1/1/1970 00:00"
    $diff = New-TimeSpan -Start $origin -End $endDate
    $expiry = [Convert]::ToInt32($diff.TotalSeconds)

    # Set URI encoded
    $serviceBusResourceURIEncoded = [System.Web.HttpUtility]::UrlEncode($ServiceBusResourceURI)

    # Set signature encoding SHA256
    $stringToEncode = $serviceBusResourceURIEncoded + "`n" + $expiry
    $encodeStringBytes = [System.Text.Encoding]::UTF8.GetBytes($stringToEncode)
    $hash = New-Object -TypeName System.Security.Cryptography.HMACSHA256
    $hash.Key = [Text.Encoding]::UTF8.GetBytes($AccessPolicyKey)
    $signatureString = $hash.ComputeHash($encodeStringBytes)
    $signatureString = [System.Convert]::ToBase64String($signatureString)
    $signatureString = [System.Web.HttpUtility]::UrlEncode($signatureString)

    # Return result
    $sasToken = "SharedAccessSignature sr=$serviceBusResourceURIEncoded&sig=$signatureString&se=$expiry&skn=$AccessPolicyKeyName"
    return $sasToken
}

function Send-MessageTorrentAvailable {
<#
    .synopsis
    Send json data to Azure Service Bus
    .description
    Send json data to Azure Service Bus
    .parameter Message
    Message must be formatted in Hashtable or JSON
    .parameter SasToken
    Service Bus token format
    .notes
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [Object]$Message,
        [Parameter(Mandatory=$true)]
        [String]$SasToken                 
    )

    # Variables
    $uri = "https://asten-torrent-search-dev-sb01.servicebus.windows.net/torrent-search-queue01/messages"
    $headers = @{'Authorization'=$SasToken}
    $result = @()
    $errorStack = ""
    $brokerProperties = @{
      State='Active'
    }
  
    # Set Header
    $brokerPropertiesJson = ConvertTo-Json $brokerProperties -Compress
    $headers.Add('BrokerProperties',$brokerPropertiesJson)

    # Convert Message in JSON format
    $data = $Message | ConvertTo-Json

    # Set Message format
    $contentType = "application/atom+xml;type=entry;charset=utf-8"

    # API call
    try {
        $request = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $data -ContentType $contentType
        $result =  @{
            Message = $Message
            ErrorStack = $errorStack
            ErrorCode = 0
        }
    }
    catch {
        $result = @{
            Message = $Message
            ErrorStack = $_.Exception.Message
            ErrorCode = 1
        }
    }

    # Return result
    Write-Output $result | ConvertTo-Json
}