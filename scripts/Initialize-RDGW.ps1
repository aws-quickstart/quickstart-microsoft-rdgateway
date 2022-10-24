<#
    .SYNOPSIS
    Initialize-RDGW.ps1

    .DESCRIPTION
    This creates a selft signed certificate to be used with RDGW.
    
    .EXAMPLE
    .\Initialize-RDGW -DomainDNSName 'example.com' -DomainNetBiosName 'EXAMPLE' -GroupName 'RDS-Group'

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$DomainDNSName,

    [Parameter(Mandatory=$true)]
    [string]$DomainNetBiosName,

    [Parameter(Mandatory=$true)]
    [string[]]$GroupName
)

Import-Module -Name 'RemoteDesktopServices'

$UserGroups=@()
If ($DomainNetBiosName -eq 'BUILTIN') {
    $ServerFQDN = $env:COMPUTERNAME
    foreach ($group in $GroupName) {
        # Determining whether we should use Group@BUILTIN or GROUP@ComputerName syntax based on SID length of the group
        if((Get-LocalGroup $group).sid.BinaryLength -eq 16) {
            $UserGroups += "$group@$DomainNetBiosName"
        }
        else {
            $UserGroups += "$group@$env:COMPUTERNAME"
        }
    }
} Else {
    $ServerFQDN = "$env:COMPUTERNAME.$DomainDNSName"
    foreach ($group in $GroupName) {
        $UserGroups += "$GroupName@$DomainDNSName"
    }
}

Write-Output 'Creating DSC Certificate to Encrypt Credentials in MOF File'
Try {
    $Cert = New-SelfSignedCertificate -CertStoreLocation 'Cert:\LocalMachine\My' -DnsName $ServerFQDN -ErrorAction Stop
} Catch [System.Exception] {
    Write-Output "Failed to create self signed cert $_"
    Exit 1
}

Write-Output 'Exporting the public key certificate'
Try {
    $Cert | Export-Certificate -FilePath "C:\$env:COMPUTERNAME.cer" -Type 'CERT' -Force -ErrorAction Stop
} Catch [System.Exception] {
    Write-Output "Failed to copy self signed cert to publickeys directory $_"
    Exit 1
}

# I am not sure if we need the private key or not. 
#dir cert:\currentuser\my | Where-Object { $_.Subject -eq "CN=$ServerFQDN" } | Foreach-Object { [system.IO.file]::WriteAllBytes("c:\$env:COMPUTERNAME.cer",($_.Export('CERT', 'secret')) ) }

Write-Output 'Setting Default CAP'
Try {
    New-Item -Path 'RDS:\GatewayServer\CAP' -Name 'Default-CAP' -UserGroups $UserGroups -AuthMethod '1' -ErrorAction Stop
} Catch [System.Exception] {
    Write-Output "Failed to set Default CAP $_"
    Exit 1
}

Write-Output 'Setting Default RAP'
Try {
    New-Item -Path 'RDS:\GatewayServer\RAP' -Name 'Default-RAP' -UserGroups $UserGroups -ComputerGroupType '2' -ErrorAction Stop
} Catch [System.Exception] {
    Write-Output "Failed to set Default RAP $_"
    Exit 1
}

Write-Output 'Getting RDS SSL Thumbprint'
Try {
    $CertThumbprint = Get-ChildItem -Path 'cert:\LocalMachine\My' -ErrorAction Stop | Where-Object { $_.Subject -eq "CN=$ServerFQDN" } | Select-Object -ExpandProperty 'Thumbprint'
} Catch [System.Exception] {
    Write-Output "Failed getting RDS SSL Thumbprint  $_"
    Exit 1
}

Write-Output 'Setting RDS SSL Thumbprint'
Try {
    Set-Item -Path 'RDS:\GatewayServer\SSLCertificate\Thumbprint' -Value $CertThumbprint
} Catch [System.Exception] {
    Write-Output "Failed setting RDS SSL Thumbprint  $_"
    Exit 1
}

Restart-Service -Name 'tsgateway' -ErrorAction SilentlyContinue