Param (
    [Parameter(Mandatory=$true)]
    [string]$Path= ".",
    [string[]]$Exclude = @(),
    [string]$ArchiveRel = "Archives",
    [int]$MinusMonth = 0,
    [switch]$DryRun
);


$pathArchiveTarget = $(join-path $Path $ArchiveRel);


$listElt = Get-ChildItem -Path $Path;

$listDone = New-Object System.Collections.Generic.List[System.IO.FileSystemInfo];

foreach ($elt in $listElt) {
    
    if ($elt.FullName -eq $pathArchiveTarget) {
        write-debug $("Is a arhive Folder");
        continue;
    }
    <#
    $m = $elt.BaseName -match "^\d{2}((0[1-9])|(1[0-2]))$" 
    if ((Test-Path -Path $elt.FullName -PathType Container) -and ( $m)) {
        write-debug $("Is a date Folder: " + $elt.BaseName);
        #$elt.LastWriteTime = $([datetime]::Parse("01/" + $elt.BaseName.Substring(2) + "/"  + $elt.BaseName.Substring(0,2))).ToString("MM/01/yyyy 12:00:00")  

        continue;
    }
    #>

    if ($Exclude.Contains($elt.BaseName)) {
        write-host $("Excluded: " + $elt.BaseName);
        continue;
    }
    
    $dateStr = $elt.LastWriteTime.ToString("yyMM");
    if ($dateStr -ge $($(get-date).AddMonths($MinusMonth * -1)).ToString("yyMM") ) {
        write-debug $("No archive for current month: " +  $elt.BaseName);
        continue;
    }

    
    $pathTarget = $(join-path $pathArchiveTarget $dateStr);
    
    if (-not (Test-Path -Path $pathTarget -PathType Container )) {
        write-host $("Create folder " + $dateStr);
        if (-not($DryRun.IsPresent)) {
            mkdir -Path $pathTarget;
            Get-Item -Path $pathTarget | ForEach-Object { $_.LastWriteTime = $elt.CreationTime.ToString("MM/01/yyyy 12:00:00")  }
        } else {
            Write-Host ""
        }
    }

     
    if (-not($DryRun.IsPresent)) {
        $elt | Move-Item -Destination $pathTarget;
    } else {
        write-host $("Move {0}`n To {1}" -f $elt.FullName, $pathTarget);
    }
    $listDone.Add($elt);

    #Get-Item -Path $pathTarget | ForEach-Object { $([datetime]::Now.ToString("MM/01/yyyy 12:00:00")    }
}

if ($listDone.Count -gt 0) {
    write-host "Copied :";
    foreach($elt in $listDone) {
        write-host $("> " + $elt.BaseName);
    }
} else {
    write-host "Nothing archived";
}

#Read-Host

