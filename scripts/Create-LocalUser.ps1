[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$AdminUser,

    [Parameter(Mandatory=$true)]
    [string]$AdminPassword,

    [Parameter(Mandatory=$false)]
    [string]$FullName,

    [Parameter(Mandatory=$false)]
    [string]$Description
)

try {
    $ErrorActionPreference = "Stop"
    Start-Transcript -Path C:\cfn\log\$($MyInvocation.MyCommand.Name).log -Append

    $SecureString = ConvertTo-SecureString -AsPlainText $AdminPassword -Force
    New-LocalUser $AdminUser -Password $SecureString -FullName $FullName -Description $Description
}
catch {
    $_ | Write-AWSQuickStartException
}
