<#
.SYNOPSIS
    Detects invalid and broken shortcuts (*.lnk files) and returns them. 
 
.NOTES
    Name: detectBrokenShortcut.ps1
    Author: Aryx.knightofnet
    Version: 1.0

 
.EXAMPLE
    detectBrokenShortcut.ps1 [-Path $path] [-Recurse]
 
 
.LINK
    https://github.com/knightofnet/some-powershell-scripts/blob/main/detectBrokenShortcut.ps1
#>
Param (
    [CmdletBinding()]
    [string]$Path= ".",
    [switch]$Recurse=$false
);

$links = @(Get-ChildItem -Filter *.lnk -Recurse:$Recurse.isPresent -Path $Path -ErrorAction $ErrorActionPreference);

Write-host $("Link files found: {0}" -f $links.Count);

$linksWrong = @();

$shell=New-Object -ComObject WScript.Shell;
foreach ($file in $links) {
    
    $path=$shell.CreateShortcut($file.fullname).TargetPath;
    if (-not( [string]::IsNullOrEmpty($path)) -and (-not(Test-Path -path $path) )) { 
        $linksWrong += $file;
    } elseif ( $null -eq $path) {
        Write-Debug $("Path empty for shortcut {0}" -f $path);
    }
}

Write-host $("Broken link files: {0}" -f $linksWrong.Count);

return $linksWrong;