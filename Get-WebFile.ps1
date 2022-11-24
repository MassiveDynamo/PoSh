# https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows
# Get-WebFile -Uri https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-64-bit.exe -Filename "c:\temp\Git-2.38.1-64-bit.exe"

function Get-WebFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Uri,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Filename,
        [string]$PAT,
        [int]$MaxRetryCount = 3
    )
    
    begin {       
        if ( $Uri.Count -ne $Filename.Count) {
            throw "The Uri and the Filename array count must be identical."
        }

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $wc = New-Object System.Net.WebClient
        if ( $null -eq $PAT ) {
            $wc.UseDefaultCredentials = $true
        }

        [UInt64]$length = 0
        $timer = [system.diagnostics.stopwatch]::StartNew()
    }
    
    process {
        for ( $i = 0; $i -lt $Uri.Count; $i++) {
            for ($retryCount = 1; $retryCount -lt $MaxRetryCount + 1; $retryCount++) {
                try {
                    $wc.DownloadFile($Uri[$i], $Filename[$i])
                    break;
                }
                catch {
                    Write-Host $_
                    Write-Host "Retry attempt $retryCount of $MaxRetryCount"
                    Start-Sleep -Milliseconds 500
                }
            }

            $fs = Get-ChildItem -Path $Filename[$i] -File
            $length += $fs.Length
        }
    }
    
    end {
        $timer.Stop()
        Write-Host "Downloaded $($Uri.Count) file(s) with a total length of $length bytes in $($timer.ElapsedMilliseconds) ms"
        $wc.Dispose()
        $wc = $null
    }
}