## TODO: fns found in fns should also be listed, but to only one level

function Display-Py-Functions-In-Folder($fnList, [string] $folderPath) {
	$extraFnList = [System.Collections.ArrayList]@()
	foreach ($fn in $fnList) {
		Display-Py-Function-In-Folder -name $fn -folderPath $folderPath -extraFnList $extraFnList
	}
	
	$extraFnList = $extraFnList | select -Unique
	$level2FnList = [System.Collections.ArrayList]@()
	foreach ($fn in $extraFnList) {
		Display-Py-Function-In-Folder -name $fn -folderPath $folderPath -extraFnList $level2FnList
	}
}

function Display-Py-Function-In-Folder( [string] $name, [string] $folderPath, $extraFnList ) {
	while ($folderPath.endsWith("\")) {
		$folderPath = $folderPath.substring(0, $folderPath.length - 1)
	}
	$pyfiles = Get-ChildItem -Path $folderPath -File -Exclude "reports","__*__" -Recurse -Filter "*.py"
	foreach ($file in $pyfiles) {
		Display-Py-Function-In-File -filePath $file -name $name -truncPath $folderPath -extraFnList $extraFnList
	}
}

function Display-Py-Function-In-File( [string] $filePath, [string] $name, [string] $truncPath, $extraFnList  ) {
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
				# "   var_iable = potential_first_part.actual_fn_name (???)"
				# "\-/\-Match 1--/\-Match 2-----------/\-Match 3----/\----/"
				
				#                "/-\/-Match 1--------\/-Match 2-----\/-Match 3--\/------\"
				if ($line -match "^ *([a-zA-Z_]+ *= *)?([a-zA-Z_]+\.)?([a-zA-Z_]+) *\(.*\)") {
					$result = $Matches[3]
					$extraFnList.Add($result) | Out-Null
				}
			}
		}
	}
}

Class Func {
	[string] $name = ""
	[string] $path = ""
	[System.Collections.ArrayList] $lines = [System.Collections.ArrayList]@()
	
	[string] ToString() {
		$s = $this.name + "`r`n" + ($this.lines -join [Environment]::NewLine)
		return $s
	}
	
	[boolean] containsFn([string] $name) {
		return $false
	}
}

function Collect-Py-And-Step-Files-In-Folder( [string] $folderPath, [string] $truncPath ) {
	while ($folderPath.endsWith("\")) {
		$folderPath = $folderPath.substring(0, $folderPath.length - 1)
	}
	$pyfiles = Get-ChildItem -Path $folderPath -File -Exclude "reports","__*__" -Recurse -Filter "*.py"
	foreach ($file in $pyfiles) {
		Collect-Py-And-Step-Files-In-File -filePath $file -truncPath $truncPath
	}
}

function Collect-Py-And-Step-Files-In-File( [string] $filePath, [string] $truncPath, [switch] $listAll ) {
	$fns = @{}
	$fn = $null
	$annotation = ""
	$currentMatch = $false
	$defIndent = ""
	$query = "^(\s*)def +([a-zA-Z_]+)\(.*\)"
	$afterFn = ""
	
	foreach ($line in Get-Content $filePath -encoding UTF8) {
		if ($line -match $query) {
			$fn = [Func]::new()
			$defIndent = "^" + $Matches[1]
			$fn.name = $Matches[2]
			$currentMatch = $true
			$afterFn = "^" + $Matches[1] + "\S"
			$fns[$fn.name] = $fn
		} elseif ($currentMatch) {
			if (($line -match "^\S") -or ($line -match $afterFn)) {
				$currentMatch = $false
			} else {
				$line = $line -replace $defIndent
				$fn.lines.add($line) | Out-Null
			}
		}
	}
	if ($listAll) {
		foreach ($func in $fns.keys) {
			Write-Host $fns[$func].ToString()
		}
	}
	return $fns
}

function Py-Function-List-Info( $funcs ) {
	foreach ($func in $funcs.keys) {
		Write-Host Py-Function-Info -func $funcs[$func]
	}
}

function Py-Function-Info( $func ) {
	Write-Host -ForegroundColor "Yellow" $func.name
	foreach ($line in $func.lines) {
		Write-Host $line
	}
}
