Param (   
    [Parameter(Mandatory = $true)]
    [ValidateSet('Block', 'Allow', 'DomainController')]
    [string]$Action = "Block",
    
    [Parameter(Mandatory = $true)]
    [ValidateSet('Outbound', 'Inbound', 'Both')]
    [string]$Direction = "Outbound",

    [string]$Path = ".",

    [switch]$Recurse
);

$script:ErrorActionPreference = 'Stop';

Function Ps-Restart ($AllParameters, $Admin) {

    $g = [System.Environment]::CommandLine;

    $AllParameters_String = "";
    ForEach ($Parameter in $AllParameters.GetEnumerator()) {
        $Parameter_Key = $Parameter.Key;
        $Parameter_Value = $Parameter.Value;
        $Parameter_Value_Type = $Parameter_Value.GetType().Name;

        If ($Parameter_Value_Type -Eq "SwitchParameter") {
            $AllParameters_String += " -$Parameter_Key";
        }
        Else {
            $AllParameters_String += " -$Parameter_Key $Parameter_Value";
        }
    }

    $Arguments = "-File `"" + $PSCommandPath + "`" " + $AllParameters_String;
    Write-Host $Arguments;
    If ($Admin -Eq $True) {
        Start-Process PowerShell -Verb Runas -ArgumentList $Arguments -Wait;
    }
    Else {        
        Start-Process PowerShell -Wait -NoNewWindow -ArgumentList $Arguments;
    }
}


$RanAsAdministrator = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);
If ($RanAsAdministrator -ne $True) {
    Ps-Restart $PsBoundParameters -Admin $True;
    return;
} 

$intRuleCreated = 0;

try {
    Write-Debug "Start";
    Get-ChildItem -LiteralPath $Path -Recurse:$Recurse.IsPresent -Filter "*.exe" | ForEach-Object {
        $appName = $_.VersionInfo.ProductName;
        if ([String]::IsNullOrEmpty($appName)) {
            $appName = $_.BaseName;
        }
        $appVersion = $_.VersionInfo.ProductVersion;
        if ([String]::IsNullOrEmpty($appVersion)) {
            $appVersion = "no-version";
        }         

        $dName = $("{0} - {1} ({2})" -f $appName, $appVersion, $_.Name);
        $descr = "Outbound rule to block {0}" -f $dName ;
        $group = "New-FirewallRuleBlockExe";

        Write-Host $_.FullName;
<#
        $var = "
        New-NetFirewallRule -DisplayName $dName `
        -Description $descr -Group $group `
        -Enabled True -Profile Any -Direction $Direction -Action $Action `
        -Program $_.FullName `
        -EdgeTraversalPolicy Block -PolicyStore PersistentStore ;        
";

Write-Host $var;
#>


        New-NetFirewallRule -DisplayName $dName `
            -Description $descr -Group $group `
            -Enabled True -Profile Any -Direction $Direction -Action $Action `
            -Program $_.FullName `
            -EdgeTraversalPolicy Block -PolicyStore PersistentStore ;


        Write-Host $("Rule created:" + $dName) ;
        $intRuleCreated++;


    }
}
catch {
    Read-Host;
}


