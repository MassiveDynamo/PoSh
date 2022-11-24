function Get-WebFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Uri,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Filename,
        [string]$Auth
    )
    
    begin {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $wc = New-Object System.Net.WebClient
        if( $null -eq $Auth ) {
            $wc.UseDefaultCredentials = $true
        }

        [UInt64]$length = 0
        $timer = [system.diagnostics.stopwatch]::StartNew()
    }
    
    process {
            try {
                $wc.DownloadFile($Uri, $Filename)
                $fs = Get-ChildItem -Path $Filename -File
                $length += $fs.Length
            }
            catch {
                Write-Host $_
            }
        }
    
    end {
        $timer.Stop()
        Write-Host "Downloaded $length bytes in $($timer.ElapsedMilliseconds) ms"
        $wc.Dispose()
        $wc = $null
    }
}