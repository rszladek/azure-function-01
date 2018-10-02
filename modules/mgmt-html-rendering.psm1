function New-AstenHTMLReport {
    <#
        .Synopsis
        Build HTML Content

        .Description
        Build HTML Content

        .Parameter Body
        Insert HTML code needed in body

        .Parameter Head
        Insert HTML Head content needed

        .Outputs
        HTML Report
    #>

    param(
        [Parameter(Mandatory=$true)]
        [String]$Head,
        [Parameter(Mandatory=$true)]
        [String]$Body,
        [Parameter(Mandatory=$false)]
        [Switch]$LocalTest
    )

    # HTML Begin
    $html = "<html>"

    # Insert HTML Head
    $html += $Head

    # Start Body Content
    $html += "<body>"

    # Insert all content you need here
    $html += $Body

    # End Body Content
    $html += "</body>"

    # HTML End
    $html += "</html>"

    #Return HTML result
    if($LocalTest) {
        Set-Content -Value $html -Path "C:\Documents\pstest.htm" -Force # Local Test Only
    }
    Write-Output $html
}

function New-AstenHTMLHead {
    <#
        .Synopsis
        Build HTML Head Content

        .Description
        Build HTML Head Content

        .Parameter Title
        Insert Title

        .Parameter Style
        Insert CSS Style

        .Outputs
        HTML String
    #>

      param(
        [Parameter(Mandatory=$false)]
        [String[]]$Style,
        [Parameter(Mandatory=$false)]
        [String]$Title
    )

    # Start Head
    $html = "<head>"

    # Insert Title
    if($Title) {
        $html += "<title>$Title</title>"
    }

    # Insert CSS Style
    if ($Style) {
        $html += "<style>"
        # Add body default style
        $html += 'body {
            font-family:"az_ea_font","Segoe UI","wf_segoe-ui_normal","Segoe WP","Tahoma","Arial","sans-serif"
        }'
        # Add others CSS
        foreach ($css in $Style) {
            $html += $css
        }
        $html += "</style>"
    }

    # End Head
    $html += "</head>"

    # return result
    Write-Output $html
}


function New-AstenHTMLTable {
<#
    .Synopsis

    .Description

    .Parameter InputObject
    Array of hashtable, example:
    @(
        @{"key1"="value1"}
        @{"key1"="value2"}
    )

    .Parameter Properties
    Select particular key

    .Parameter CSSClass
    Useful if you want to custom table later

    .Parameter Title
    Add Title above your table in H2

    .Outputs
    HTML Report
#>

     param(
        [Parameter(Mandatory=$true)]
        [Object]$InputObject,
        [Parameter(Mandatory=$false)]
        [String]$CSSClass,
        [Parameter(Mandatory=$false)]
        [String[]]$Properties,
        [Parameter(Mandatory=$false)]
        [String]$Title
    )

    # Variables

    # Default style
    $style = "tr, th {
        text-align:left;
        font-size:10px;
        padding: 0;
        height: 40px;
        line-height:38px;
        font-weight:700;
        text-transform: uppercase;
    }
    
    table {
        border-spacing:0;
        table-layout: fixed;
        width: 100%;
    }
    
    th {
        border-color: #ccc;
        border-bottom-style: solid;
    }
    
    td {
        height:33px;
        border-color: #ccc;
        border-bottom-style: solid;
        border-bottom-width:1px;
        text-transform: none;
    }"   

    # Check if Title is needed
    if($Title) {
        $html = "<h3 style='margin-bottom: 5px; position: relative;font-size: 18px;color:#003056'>$Title</h3>"
    }

    # Build html Table
    if($CSSClass) {
        $html += "<table class='$CSSClass'>"
    } else {
        $html += "<table>"
    }

    # First prepare table header
    $arrayKeys = $InputObject[0].Keys | % ToString
    $html += "<tr>"
    foreach ($key in $arrayKeys) {
        $html += "<th>$($key)</th>"
    }
    $html += "</tr>"

    # Second insert values
    foreach ($object in $InputObject) {
        $html += "<tr>"
        foreach ($key in $arrayKeys) {
            $html += "<td>$($object.($key))</td>"
        }
        $html += "</tr>"
    }

    # End table
    $html += "</table>"

    # Return result HTML and CSS Style
    $result = @{"Table" = $html; "Style" = $style}
    Write-Output $result
}