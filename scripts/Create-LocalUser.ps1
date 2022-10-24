<#
    .SYNOPSIS
    Create-LocalUser.ps1

    .DESCRIPTION
    This script creates a new local user, a local group and adds the user to that group as well as the local administrators group
    
    .EXAMPLE
    .\Create-LocalUser -AdminSecParam 'arn:aws:secretsmanager:us-west-2:############:secret:example-VX5fcW' -FullName 'John Doe' -Description 'This is a local user account'

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AdminSecParam
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

$AdminUserName = $AdminPassword.UserName
$AdminUserPW = ConvertTo-SecureString ($AdminPassword.Password) -AsPlainText -Force

Write-Output 'Creating local user'
Try {
    New-LocalUser -Name $AdminUserName -Password $AdminUserPW -ErrorAction Stop
} Catch [System.Exception]{
    Write-Output "Failed to create local user $_"
    Exit 1
}

Write-Output 'Creating local group'
Try {
    New-LocalGroup -Name "RDGWUsers" -Description "Users who will be authorized by default RDGW RAP" -ErrorAction Stop
} Catch [System.Exception]{
    Write-Output "Failed to create local Group $_"
    Exit 1
}

Write-Output 'Adding local user to group'
Try {
    Add-LocalGroupMember -Group 'Administrators' -Member $AdminUserName -ErrorAction Stop
    Add-LocalGroupMember -Group "RDGWUsers" -Member $AdminUserName -ErrorAction Stop
} Catch [System.Exception]{
    Write-Output "Failed to add local user to group $_"
    Exit 1
}