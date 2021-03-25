function Show-InExplorer() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.IO.FileSystemInfo]
        $File
    );

    $null = [System.Diagnostics.Process]::Start("explorer.exe", "/select, `"" + $File.FullName + "`"");
}

function Show-InExplorer() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]
        $FilePath
    );    
    $null = [System.Diagnostics.Process]::Start("explorer.exe", "/select, `"" + $FilePath + "`"");
}

function Get-HumanReadableSize([long] $size, [string] $format = "{0:0.##} {1}")
{
    [string[]] $sizes = @( "o", "ko", "Mo", "Go", "To" );

    [double] $len = $size;
    [int] $order = 0;
    while (($len -ge 1024) -and ($order -lt $sizes.Length - 1))
    {
        $order++;
        $len = $len / 1024;
    }

    # Adjust the format string to your preferences. For example "{0:0.#}{1}" would
    # show a single decimal place, and no space.
    return [String]::Format($format, $len, $sizes[$order]);

}


function Get-EmptyFolder () {
    Param (        
        [string]$Path= ".",
        [switch]$Recurse
    );

    if ($Recurse.IsPresent) {
        return Get-ChildItem -LiteralPath $Path -Recurse -Directory | Where-Object { $(Get-ChildItem -LiteralPath $_.FullName | Measure-Object).Count -eq 0};
    } 
    return Get-ChildItem -LiteralPath $Path -Directory | Where-Object { $(Get-ChildItem -LiteralPath $_.FullName | Measure-Object).Count -eq 0};

}

function Show-DiskUsage() {
    Param (        
        [string]$Path= ".",
        [int]$Depth = 0,
        [switch]$Relative,
        [switch]$Recurse,
        [switch]$ShowHiddenAndSystem
    );

    if (($Recurse.IsPresent) -and ($Depth -eq 0)) {
        $Depth = 1;
    }

    if ($Path -eq ".") {
        $Path = $(Get-Item -LiteralPath . -Force).FullName;
    }

    $Path = Join-Path $Path "";

    Write-Host "";
    write-host $("{0}" -f $Path);
    #write-host $("Length: " -f $(Get-item -LiteralPath $Path).Length);
    Write-Host "";


    $results = @();

    Get-ChildItem -Path $Path -force:$ShowHiddenAndSystem.IsPresent -ErrorAction SilentlyContinue | ForEach-Object {

        $lenItem = $_.Length;

        Get-ChildItem -recurse -force $_.fullname -File -ErrorAction SilentlyContinue | ForEach-Object { $len += $_.length }
        $dirShow = $_.FullName;
        if ($Relative.IsPresent) {
            $dirShow = $dirShow.Replace($Path, "");
        }
        $typeItem = "";
        if ($_ -is [io.directoryinfo]) {
            $typeItem = "d";
            $lenItem = $(Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue -File | Measure-Object -Property Length -sum).Sum;
        } else {
            
        }

     

        #write-host $($dirShow, ":", '{0:N2} MB' -f ($len / 1MB))
        $hashRes = @{};
        $hashRes.Add("IsDir", $typeItem);
        $hashRes.Add("Name", $dirShow);
        $hashRes.Add("Length", $lenItem);
        $hashRes.Add("Lenght (hr)", $(Get-HumanReadableSize -size $lenItem));
        $hashRes.Add("FullName", $_.FullName);

        $results += [pscustomobject]$hashRes;        

       
    }

    $orders = @(@{Expression = "IsDir"; Descending = $True}, @{Expression = "Name"; Descending = $False});

    $results | Select-Object -Property "IsDir",Name, Length, "Lenght (hr)" | Sort-Object -Property $orders | Out-Default ;
   

    if ($Recurse.IsPresent -and ($Depth -gt 0)) {
        $results | Where-Object { $_.Isdir -eq "d"} | ForEach-Object {
            Show-DiskUsage -Path $_.FullName -Relative -Depth $($Depth - 1) -Recurse;
        }
    }
}


Export-ModuleMember -Function Show-InExplorer, Get-HumanReadableSize, Get-EmptyFolder, Show-DiskUsage;