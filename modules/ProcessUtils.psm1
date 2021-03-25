
function Get-ProcessCmdLineArgs([System.Diagnostics.Process]$Process, [ref]$OutProcessIsFound)
{
    if ($null -ne $OutProcessIsFound) {
        $OutProcessIsFound.Value = $false;
    }

    $mngmtClass = [System.Management.ManagementClass]::new("Win32_Process");
    [System.Management.ManagementObject] $o = $null;
    foreach ($o in $mngmtClass.GetInstances() )
    {
        if ( $o.ProcessId.ToString().Equals($Process.Id.ToString()))
        {
            if ($null -ne $OutProcessIsFound) {
                $OutProcessIsFound.Value = $true;
            }
            [string] $fullCmdLine = $o.CommandLine.ToString();
            [string] $exePathLine = $o.ExecutablePath.ToString();
            if ($fullCmdLine.StartsWith("`""))
            {
                return $fullCmdLine.Replace("`"" + $exePathLine + "`" ", "");
            }
            else
            {
                return $fullCmdLine.Replace($exePathLine + " ", "");
            }
        }
    }
    return $null;
}



Export-ModuleMember -Function Get-ProcessCmdLineArgs;