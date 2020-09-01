## TODO: fns found in fns should also be listed, but to only one level

function Display-Py-Function-In-Folder( [string] $name, [string] $folderPath ) {
	while ($folderPath.endsWith("\")) {
		$folderPath = $folderPath.substring(0, $folderPath.length - 1)
	}
	$pyfiles = Get-ChildItem -Path $folderPath -File -Exclude "reports","__*__" -Recurse -Filter "*.py"
	Foreach ($file in $pyfiles) {
		Display-Py-Function-In-File -filePath $file -name $name -truncPath $folderPath
	}
}

function Display-Py-Function-In-File( [string] $filePath, [string] $name, [string] $truncPath ) {
	$query = "(\s*)def +" + $name
	$lineno = 0
	$currentMatch = $false
	$afterFn = ""
	foreach($line in Get-Content $filePath -encoding UTF8) {
		$lineno++
		if($line -match $query){
			$truncpath = $filePath -replace [regex]::escape($truncPath)
			Write-Host -ForegroundColor Blue "`n~$($truncpath)"
			$currentMatch = $true
			Write-Host -ForegroundColor "Yellow" "$($lineno.ToString().PadLeft(5, " ")) $line"
			$afterFn = "^" + $Matches[1] + "\S"
		} elseif ($currentMatch) {
			if (($line -match "^\S") -or ($line -match $afterFn)) {
				$currentMatch = $false
			} else {
				Write-Host -ForegroundColor "Gray" "     $($line)"
			}
		}
	}
}