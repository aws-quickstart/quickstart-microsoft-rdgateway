[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string[]]$EIPs,

    [Parameter(Mandatory=$true)]
    [string]$Region
)

try {
    $ErrorActionPreference = "Stop"

    Start-Transcript -Path c:\cfn\log\Set-EIP.ps1.txt -Append

    Write-Host $EIPs

    Write-Host $Region

    Write-Host "EIP assignment functionality coming soon..."
    Write-Host "Script End."
}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}
