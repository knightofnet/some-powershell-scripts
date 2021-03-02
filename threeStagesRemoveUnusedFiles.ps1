Param (
    [Parameter(Mandatory=$true)]
    [string]$Path= "."
);

$unusedFilesSinceDays = 60;
$daysInVault = 60;




function searchUnusedFiles($path ) {

    $dateBorneInf = [datetime]::Now.AddDays($unusedFilesSinceDays * -1);

    $files = Get-ChildItem -Path $path | Where-Object { $_.LastWriteTime -lt $dateBorneInf };

    $files | ForEach-Object { 
        if (Test-Path -Path $_.FullName -PathType Container) {
            Write-Host "D " -NoNewline;
        } else {
            Write-Host ". " -NoNewline;
        }
    
        write-host $_.BaseName 
    
    }

    return $files;
}


$fToArch = searchUnusedFiles -path $Path;

