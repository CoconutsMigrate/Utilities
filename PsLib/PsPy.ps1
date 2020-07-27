

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
	$query = "def +" + $name + ".*\(.*\):"
	$lineno = 0
	$currentMatch = $false
	foreach($line in Get-Content $filePath -encoding UTF8) {
		$lineno++
		if($line -match $query){
			$truncpath = $filePath -replace [regex]::escape($truncPath)
			Write-Host -ForegroundColor Blue "`n~$($truncpath)"
			$currentMatch = $true
			Write-Host "$($lineno.ToString().PadLeft(5, " ")) $line"
		} elseif ($currentMatch) {
			if ($line -match "^\S") {
				$currentMatch = $false
			} else {
				Write-Host -ForegroundColor "Gray" "     $($line)"
			}
		}
	}
}