function List-Vars() {
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [array]
        $VarValues,
  
        [Parameter(Mandatory=$true)]
        [array]$VarNames
    )


    if (($VarNames.Length -eq 0) -or ($VarValues.Length -eq 0) ) {
        throw [Exception] "VarNames or VarValues must not be empty";
    } elseif (($VarNames.Length -ne $VarValues.Length)) {
        throw [Exception] "VarNames or VarValues must have same lenght";
    }

    for ($i = 0; $i -lt $VarNames.Length ; $i++) {
        Set-Variable -Name $VarNames[$i] -Value $VarValues[$i] -Scope Global
    }
}

function List-Vars() {
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [hashtable]
        $hash
       
    )



    foreach($elt in $hash.GetEnumerator()) {
        Set-Variable -Name $elt.Key -Value $elt.Value -Scope Global
    }
}


Export-ModuleMember -Function List-Vars;