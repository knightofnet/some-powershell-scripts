<#
.SYNOPSIS
    Lists the sub-elements of a path and stores them according to their last modification dates in folders with YYMM format.
 
.NOTES
    Name: rearrangeFolderWithYYMM.ps1
    Author: Aryx.knightofnet
    Version: 1.0

 
.EXAMPLE
    rearrangeFolderWithYYMM.ps1 -Path $path [-Exclude $elt1,$elt2,...] [-ArchiveRel = "Archives"] [-MinusMonth = 0] [-DryRun]
 
 
.LINK
    https://github.com/knightofnet/some-powershell-scripts/blob/main/detectBrokenShortcut.ps1
#>
[CmdletBinding()]
Param (    
    [Parameter(Mandatory=$true)]
    [string]$Path= ".",
    [string[]]$Exclude = @(),
    [string]$ArchiveRel = "Archives",
    [int]$MinusMonth = 0,
    [switch]$DryRun
);

# Inform user that dry-mode is active
if ($DryRun.IsPresent) {
    Write-Host "Dry mode: nothing will be moved; it's just for a try.";
}

# Create path string for Archives
$pathArchiveTarget = $(join-path $Path $ArchiveRel);

$listElt = Get-ChildItem -Path $Path;

$listDone = New-Object System.Collections.Generic.List[System.IO.FileSystemInfo];



foreach ($elt in $listElt) {
    
    if ($elt.FullName -eq $pathArchiveTarget) {
        Write-Verbose $("Is an archive Folder");
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
        Write-Verbose $("Excluded: " + $elt.BaseName);
        continue;
    }

    $dateStr = $elt.LastWriteTime.ToString("yyMM");
    if ( ($elt.PSIsContainer) -and ($dateStr -eq $elt.BaseName)) {
        continue;
    }

    if ($dateStr -ge $($(get-date).AddMonths($MinusMonth * -1)).ToString("yyMM") ) {
        Write-Verbose $("No archive for current month: " +  $elt.BaseName);
        continue;
    }

    
    $pathTarget = $(join-path $pathArchiveTarget $dateStr);
    
    # Keeps the info that we have created date YYMM folder.
    # if yes, and only if this case, we will set the lastWriteTime
    $isMkDir = $false;

    if (-not (Test-Path -Path $pathTarget -PathType Container )) {
        Write-Verbose $("Create folder " + $dateStr);
        if (-not($DryRun.IsPresent)) {
            mkdir -Path $pathTarget;          
            $isMkDir = $true; 
        } else {
            Write-Verbose ""
        }
    }
     
    if (-not($DryRun.IsPresent)) {
        $elt | Move-Item -Destination $pathTarget;
    } else {
        Write-Verbose $("Move {0}`n> To {1}" -f $elt.FullName, $pathTarget);
    }
    $listDone.Add($elt);

    if ($isMkDir) {
        # set LastWriteTime at first day of month
        Get-Item -Path $pathTarget | ForEach-Object { $_.LastWriteTime = $elt.CreationTime.ToString("MM/01/yyyy 12:00:00")}
    }    

}

if ($listDone.Count -gt 0) {
    write-host "Copied :"; 
  
    if ($VerbosePreference -eq "Continue") { 
        foreach($elt in $listDone) {
            write-host $("> " + $elt.BaseName);
        }
    } elseif($VerbosePreference -eq "SilentlyContinue") {
        write-host $(" > {0} elements" -f $listDone.Count);
    }
} else {
    write-host "Nothing archived";
}

#Read-Host

