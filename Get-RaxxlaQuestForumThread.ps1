<# Download and do a HTML parsing of the pages in The Quest To Find Raxxla.
FireFox worked best, Internet Explorer & MS Edge did not work with Selenium on my machine.
#>

If (-not (Get-Module -ErrorAction Ignore -ListAvailable Selenium)) {
    Write-Verbose "Installing Seleniummo dule for the current user..."
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
        Write-Host "Downloading page $i took $($stopwatch.ElapsedMilliseconds) ms"
        Set-Content -Path $fileName -Value $driver.PageSource
    }
    
    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
    $htmlDom = ConvertFrom-Html -Path $filename
    $htmlDom.SelectNodes('//div') | ForEach-Object InnerText | Set-Content -Path "c:\temp\page-$i.txt"
    Write-Host "Parsing page $i took $($stopwatch.ElapsedMilliseconds) ms"
}

$driver.Dispose()
$driver = $null
