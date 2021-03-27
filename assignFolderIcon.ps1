[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Path
)


function Get-IniContent ($filePath)
{
    $ini = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            $ini[$section][$name] = $value
        }
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

function Out-IniFile()
{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [hashtable]
        $InputObject,        
        [Parameter()]
        [String]
        $FilePath
    )

    $outFile = New-Item -ItemType file -Path $Filepath
    foreach ($i in $InputObject.keys)
    {
        if (!($($InputObject[$i].GetType().Name) -eq "Hashtable"))
        {
            #No Sections
            Add-Content -Path $outFile -Value "$i=$($InputObject[$i])"
        } else {
            #Sections
            Add-Content -Path $outFile -Value "[$i]"
            Foreach ($j in ($InputObject[$i].keys | Sort-Object))
            {
                if ($j -match "^Comment[\d]+") {
                    Add-Content -Path $outFile -Value "$($InputObject[$i][$j])"
                } else {
                    Add-Content -Path $outFile -Value "$j=$($InputObject[$i][$j])"
                }

            }
            Add-Content -Path $outFile -Value ""
        }
    }
}

$folders = Get-ChildItem -Path $Path -Directory | Where-Object { $( Get-ChildItem -Filter *.exe -Path $_.FullName | Measure-Object  ).Count -gt 0 } 

foreach($folder in $folders ) {
    $dFile = "desktop.ini";
    $iFile = @{};

    $isDesktopFileAlreadyExists = $false;

    if (Test-Path -Path $(Join-Path $folder.FullName $dFile) -PathType Leaf ) {
        $iFile = Get-IniContent -filePath $(Join-Path $folder.FullName $dFile);
        $isDesktopFileAlreadyExists = $true;
    }

    if (-not($iFile.ContainsKey(".ShellClassInfo")) ) {
        $iFile.Add(".ShellClassInfo", @{});
    } 

    $firstExe = @(Get-ChildItem -Filter *.exe -Path $folder.FullName)[0];

    $section = $iFile.".ShellClassInfo";
    if (-not($section.ContainsKey("IconResource")) ) {
        $section.Add("IconResource", $($firstExe.FullName + ",0"));
    } else {       
        #continue;
        $section."IconResource" = $($firstExe.FullName + ",0");
    }

    if ($isDesktopFileAlreadyExists) {
        Get-Item -Path $(Join-Path $folder.FullName $dFile) -Force | Remove-Item -Force;
    }
    $iFile | Out-IniFile -FilePath $(Join-Path $folder.FullName $dFile);
    (Get-Item $folder.FullName).attributes = 'ReadOnly, Directory';

}