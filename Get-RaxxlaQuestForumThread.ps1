<# Download and do a HTML parsing of the pages in The Quest To Find Raxxla.
FireFox worked best, Internet Explorer & MS Edge did not work with Selenium on my machine.
#>

function Get-ChildNodeText {
    param (
        $node,
        [System.Text.StringBuilder]$buffer
    )
    
    if ( $node.NodeType -eq [HtmlAgilityPack.HtmlNodeType]::Element) {
        foreach ( $child in $node.ChildNodes ) {
            Get-ChildNodeText $child $buffer
        }
    }
    elseif ($node.NodeType -eq [HtmlAgilityPack.HtmlNodeType]::Text) {
        $trimmed = $node.InnerText.Trim()
        if( $trimmed.Length -gt 0) {
            [void]$buffer.AppendLine($trimmed)
        }
    }
}

If (-not (Get-Module -ErrorAction Ignore -ListAvailable Selenium)) {
    Write-Verbose "Installing Selenium for the current user..."
    Install-Module Selenium -ErrorAction Stop
}
  
If (-not (Get-Module -ErrorAction Ignore -ListAvailable PowerHTML)) {
    Write-Verbose "Installing PowerHTML module for the current user..."
    Install-Module PowerHTML -ErrorAction Stop
}

Import-Module Selenium -ErrorAction Stop
Import-Module PowerHTML -ErrorAction Stop

$url = 'https://forums.frontier.co.uk/threads/the-quest-to-find-raxxla.168253/'
$driver = Start-SeFireFox

for ( $i = 1; $i -lt 1424; $i++) {
    $fileName = "c:\temp\page-$i.html"
    if ( !(Test-Path $fileName -PathType Leaf) ) {
        $stopwatch = [system.diagnostics.stopwatch]::StartNew()
        $driver.Url = $url + "page-" + $i
        
        # Downloading took ~2.5-3.5 seconds on my laptop
        Write-Host "Downloading page $i took $($stopwatch.ElapsedMilliseconds) ms"
        Set-Content -Path $fileName -Value $driver.PageSource
    }
    
    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
    $htmlDom = ConvertFrom-Html -Path $filename
    $nodes = $htmlDom.SelectNodes('//div')
    $textBuffer = [System.Text.StringBuilder]::new()
    foreach ($node in $nodes) {
        Get-ChildNodeText $node $textBuffer
    }   

    $textBuffer.ToString() | Set-Content -Path "c:\temp\page-$i.txt"
    
    # Parsing took ~25 ms on my laptop
    Write-Host "Parsing page $i took $($stopwatch.ElapsedMilliseconds) ms"
}

$driver.Dispose()
$driver = $null
