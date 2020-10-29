[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$AdminSecParam,

    [Parameter(Mandatory=$false)][string]$FullName,

    [Parameter(Mandatory=$false)][string]$Description
)

# Getting Password from Secrets Manager for AD Admin User
Try {
    $AdminSecret = Get-SECSecretValue -SecretId $AdminSecParam -ErrorAction Stop | Select-Object -ExpandProperty 'SecretString'
} Catch [System.Exception] {
    Write-Output "Failed to get $AdminSecParam Secret $_"
    Exit 1
}

Try {
    $AdminPassword = ConvertFrom-Json -InputObject $AdminSecret -ErrorAction Stop
} Catch [System.Exception] {
    Write-Output "Failed to convert AdminSecret from JSON $_"
    Exit 1
}

$AdminUser = $AdminPassword.UserName

try {
    $ErrorActionPreference = "Stop"
    Start-Transcript -Path C:\cfn\log\$($MyInvocation.MyCommand.Name).log -Append

    $SecureString = ConvertTo-SecureString ($AdminPassword.Password) -AsPlainText -Force
    New-LocalUser $AdminUser -Password $SecureString -FullName $FullName -Description $Description
    net localgroup Administrators $AdminUser /ADD
}
catch {
    $_ | Write-AWSQuickStartException
}
