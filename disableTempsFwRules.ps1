

Function Restart ($AllParameters, $Admin) {
    $AllParameters_String = "";
    ForEach ($Parameter in $AllParameters.GetEnumerator()){
        $Parameter_Key = $Parameter.Key;
        $Parameter_Value = $Parameter.Value;
        $Parameter_Value_Type = $Parameter_Value.GetType().Name;

        If ($Parameter_Value_Type -Eq "SwitchParameter"){
            $AllParameters_String += " -$Parameter_Key";
        } Else {
            $AllParameters_String += " -$Parameter_Key $Parameter_Value";
        }
    }

    $Arguments = "-File `"" + $PSCommandPath + "`" -NoExit" + $AllParameters_String;

    If ($Admin -Eq $True){
        Start-Process PowerShell -Verb Runas -ArgumentList $Arguments;
    } Else {        
        Start-Process PowerShell -ArgumentList $Arguments;
    }
}

$RanAsAdministrator = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);
If ($RanAsAdministrator -ne $True){
    Restart $PsBoundParameters -Admin $True;
} else {
    Get-NetFirewallRule | Where-Object {if ($null -ne $_.DisplayGroup) {  $_.DisplayGroup.contains("Temp") -and ($_.Enabled -eq $True) }  } | ForEach-Object { $($(get-date).ToShortDateString() +"-" + $(get-date).ToShortTimeString() + "-Désactivation de " + $_.DisplayName + " ("+$_.Name + ")"  ) | Out-File -FilePath "G:\Powershell\disableFw.log" -Append; Disable-NetFirewallRule -Name $_.Name }
    #Read-Host;
}