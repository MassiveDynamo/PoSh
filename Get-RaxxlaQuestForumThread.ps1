<# Download and do a HTML parsing of the pages in The Quest To Find Raxxla.
FireFox worked best, Internet Explorer & MS Edge did not with Selenium on my machine.
#>
Import-Module Selenium

$url = 'https://forums.frontier.co.uk/threads/the-quest-to-find-raxxla.168253/'
$driver = Start-SeFireFox
$stopwatch = [system.diagnostics.stopwatch]::StartNew()
$driver.Url = $url
Write-Host $stopwatch.ElapsedMilliseconds
Set-Content -Path c:\temp\page-0.html -Value $driver.PageSource

for ( $i = 1; $i -lt 1424; $i++) {
    $fileName = "c:\temp\page-$i.html"
    if ( !(Test-Path $fileName -PathType Leaf) ) {
        $stopwatch.Reset()
        $stopwatch.Start()
        $driver.Url = $url + "page-" + $i
        Write-Host "Downloading page $i took $($stopwatch.ElapsedMilliseconds) ms"
        Set-Content -Path $fileName -Value $driver.PageSource
    }
    
    $stopwatch.Reset()
    $stopwatch.Start()
    $html = New-Object -Com "HTMLFile"
    $html.IHTMLDocument2_write($page)
    $html.all.tags("div") | ForEach-Object InnerText | Set-Content -Path "c:\temp\page-$i.txt"
    Write-Host "Parsing page $i took $($stopwatch.ElapsedMilliseconds) ms"
    $html = $null
}
