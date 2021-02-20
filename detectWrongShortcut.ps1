Param (
    [Parameter(Mandatory=$true)]
    [string]$dirSource= "."
);

$links = @(gci -Filter *.lnk -Recurse -Path $dirSource);

Write-host $("Liens trouvés : {0}" -f $links.Count);

$linksWrong = @();

$shell=New-Object -ComObject WScript.Shell;
foreach ($file in gci -Filter *.lnk -Recurse -Path $dirSource) {
    
    $path=$shell.CreateShortcut($file.fullname).TargetPath;
    if(-not(Test-Path -path $path) ) { 
        $linksWrong += $file;
    }
}

Write-host $("Liens brisés : {0}" -f $linksWrong.Count);

return $linksWrong;