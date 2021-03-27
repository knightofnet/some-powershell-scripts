function Get-HumanReadableTime([int]$Seconds) {

    if ($Seconds -eq 0) {
        return [String]::Empty;
    }

    if ($Seconds -lt 60) {
        return "{0}s" -f $Seconds;
    }

    if ($Seconds -lt (3600)) {
        $minutes = [System.Math]::Truncate($Seconds / 60);
        return "{0}min {1}" -f $minutes, $(Get-HumanReadableTime -Seconds $($Seconds % 60 ))
    }

    if ($Seconds -lt (3600 * 24)) {
        $hours = [System.Math]::Truncate($Seconds / 3600 );
        return "{0}h {1}" -f $hours, $(Get-HumanReadableTime -Seconds $($Seconds % 3600 ))
    }

    $days = [System.Math]::Truncate($Seconds / (3600 * 24) )

    return "{0}d {1}" -f $days, $(Get-HumanReadableTime -Seconds $($Seconds % (3600 * 24) ))

}

function Start-VisualSleep([int]$Seconds=0, [int]$Minutes=0, [int]$Hours=0, [string]$Message="Waiting") {

    $sleepSec = $Seconds +  ($Minutes * 60) + ($Hours * 3600);


    for ($i = 1; $i -le $sleepSec; $i++) {
        Start-Sleep -Seconds 1;
        
        Write-Progress -Activity $Message -Status $($(Get-HumanReadableTime -Seconds $($sleepSec - $i)) + " - [$i/$sleepSec]") -PercentComplete $($i / $sleepSec * 100);
    }

}

function Start-SleepBis([int]$Seconds=0, [int]$Minutes=0, [int]$Hours=0) {

    $sleepSec = $Seconds +  ($Minutes * 60) + ($Hours * 3600);
    Start-Sleep -Seconds $sleepSec;
}

function Start-Hibernate([int]$Seconds=0, [int]$Minutes=0, [int]$Hours=0, [switch]$ShowTimer) {
    if ($ShowTimer.IsPresent) {
        Start-VisualSleep -Message "Waits before hibernate :: CTRL+C to cancel" -Seconds $Seconds -Minutes $Minutes -Hours $Hours;
    } else {
        Start-SleepBis -Seconds $Seconds -Minutes $Minutes -Hours $Hours;
    }

    Start-Process -FilePath shutdown -ArgumentList "/h";

}

function Read-HostMultiple() {
    Param(
        [Parameter(Mandatory=$true)]
        [string[]]
        $Prompts,
        [string]
        $ToPreviousPhrase=""
    );

    $retArray=@();
    $i = 0;
    while ($i -lt $Prompts.Length)  {

        $prompt = $Prompts[$i];
        $rh = Read-Host -Prompt $prompt ;
        if (($ToPreviousPhrase -ne "") -and ($rh -eq $ToPreviousPhrase)) {
            $i--;
            if ($i -lt 0) {
                return @();
            }
        } else {
            if ($retArray.Length -gt $i) {
                $retArray[$i] = $rh;
            } else {
                $retArray += $rh;
            }
            $i++;
        }

    }

    return $retArray;
}

function Beep([switch]$Legacy) {
    if ($Legacy.IsPresent) {
        [console]::Beep(1000,500);
    } else {
        [System.Media.SystemSounds]::Beep.Play();
    }
}

Export-ModuleMember -Function Beep, Read-HostMultiple, Start-VisualSleep, Get-HumanReadableTime, Start-SleepBis, Start-Hibernate;