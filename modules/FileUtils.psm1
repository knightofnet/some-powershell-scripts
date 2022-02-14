function Show-InExplorer() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.IO.FileSystemInfo]
        $File
    );

    <#
        .SYNOPSIS
        Reveal a file or a folder into Windows Explorer.

        .DESCRIPTION
        Reveal a file or a folder into Windows Explorer.

        .PARAMETER File
        The File object to reveal.

        .INPUTS
        The File object to reveal.

        .OUTPUTS
        None.

        .EXAMPLE
        PS> Show-InExplorer -File (Get-Item -Path "c:\Windows")

        .LINK
        Online version: https://github.com/knightofnet/some-powershell-scripts

    #>    

    $null = [System.Diagnostics.Process]::Start("explorer.exe", "/select, `"" + $File.FullName + "`"");
}

function Show-InExplorer() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]
        $FilePath
    );    

    <#
        .SYNOPSIS
        Reveal a file or a folder into Windows Explorer.

        .DESCRIPTION
        Reveal a file or a folder into Windows Explorer.

        .PARAMETER FilePath
        The path to the element to reveal.

        .INPUTS
        The path to the element to reveal.

        .OUTPUTS
        None.

        .EXAMPLE
        PS> Show-InExplorer -FilePath "c:\Windows"

        .LINK
        Online version: https://github.com/knightofnet/some-powershell-scripts

    #>        

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

Function Get-MP3MetaData
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([Psobject])]
    Param
    (
        [String] [Parameter(Mandatory=$true, ValueFromPipeline=$true)] $Filepath
    )

    $File = Get-Item -LiteralPath $Filepath;


    $shell = New-Object -ComObject "Shell.Application"
    $ObjDir = $shell.NameSpace($File.Directory.FullName)

    $ObjFile = $ObjDir.parsename($File.Name)
    $MetaData = @{}
    $MP3 = ($ObjDir.Items() | Where-Object {$File.path -like "*.mp3" -or $File.path -like "*.mp4"})
    $PropertArray = 0,1,2,12,13,14,15,16,17,18,19,20,21,22,27,28,36,220,223

    Foreach($item in $PropertArray)
    { 
        If($ObjDir.GetDetailsOf($ObjFile, $item)) #To avoid empty values
        {
            $MetaData[$($ObjDir.GetDetailsOf($MP3,$item))] = $ObjDir.GetDetailsOf($ObjFile, $item)
        }
        
    }

    New-Object psobject -Property $MetaData | Select-Object *, @{n="Directory";e={$Dir}}, @{n="Fullname";e={Join-Path $Dir $File.Name -Resolve}}, @{n="Extension";e={$File.Extension}}
            

}


Export-ModuleMember -Function Get-MP3MetaData,Show-InExplorer, Get-HumanReadableSize, Get-EmptyFolder, Show-DiskUsage;