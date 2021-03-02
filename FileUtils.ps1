function winDirToUnix($winPath) {
    $retPath = "/mnt/";
    
    $ex = $winPath.Split("\");
    if ($ex[0].contains(":")) {
        $ex[0] = $ex[0].Substring(0,1).ToLower();
    }
    foreach ($p in $ex) {
        if ($p -ne "") {
            $retPath += $p + "/";
        }
    }

    if (-not $winPath.EndsWith("\")) {
        $retPath = $retPath.TrimEnd("/");

    }
    return $retPath;
}
