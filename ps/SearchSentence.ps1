#Default values
$defsrcpath = "C:\Git\system_test_cases\system"
$defcontextlines = 0

function Clear-Array( [array] $array ) {
	for ($index=0; $index -lt $array.Length; $index++) {
		$array[$index] = ""
	}
}

function Add-To-Array( [array] $array, [string] $value ) {
	for ($index=0; $index -lt $array.Length - 1; $index++) {
		$array[$index] = $array[$index + 1]
	}
	$array[$array.Length - 1] = $value
}

function Write-Line( $lineno, $line, $highlight ) {
	if ($line -ne "") {
		$col = if ($highlight) {"Yellow"} else {"Gray"}
		Write-Host -ForegroundColor $col "$($lineno.ToString().PadLeft(5, " "))  $($line.trim())"
	}
}

function Write-Context-Lines( $array ) {
	for ($index=0; $index -lt $array.Length; $index++) {
		Write-Line -lineno "" -line $array[$index] -highlight $false
	}
}

function File-Search-Display( [string] $file, [string] $query, [string] $rootdir, [string] $contextlines ) {
	$filenameWritten = $false
	$lastMatch = -$contextlines
	$lineno = 0
	$query = [regex]::escape($query)
	$array = @("") * $contextlines
	foreach($line in Get-Content $file -encoding UTF8) {
		$lineno++
		if($line -match $query){
			# Write file name if needed
			if ($filenameWritten -eq $false) {
				$filenameWritten = $true
				$truncpath = $file -replace [regex]::escape($rootdir)
				Write-Host -ForegroundColor Blue "`n~$($truncpath)"
			}
			# Write previous valid context lines
			Write-Context-Lines -array $array
			
			# Write match lines
			Write-Line -lineno $lineno -line $line -highlight $true
			
			# Last match
			$lastMatch = $lineno
			
			# Clear Array
			Clear-Array -array $array
			
		} elseif ($lineno -le $lastMatch + $contextlines) {
			# Write current context line
			Write-Line -lineno "" -line $line -highlight $false
		} else {
			# Add context line
			Add-To-Array -array $array -value $line.trim()
		}
	}
}

function Convert-To-Feature( [string] $query ) {
	$conv = $query -replace "{","<"
	$conv = $conv -replace "}",">"
	return $conv
}

function Convert-To-Py( [string] $query ) {
	$conv = $query -replace "<","{"
	$conv = $conv -replace ">","}"
	return $conv
}

$srcpath = Read-Host -Prompt "Search Folder [$($defsrcpath)]"
if ($srcpath -eq "") {
	$srcpath = $defsrcpath
}

$contextlines = Read-Host -Prompt "Context Lines [$($defcontextlines)]"
if ($contextlines -eq "") {
	$contextlines = $defcontextlines
}

$query = Read-Host -Prompt "Search Query"

While ($query -ne "") {
	Clear-Host
	Write-Host
	Write-Host -ForegroundColor Green "===================================================================================================="
	Write-Host
	Write-Host -ForegroundColor Green "Search Folder : $($srcpath)"
	Write-Host -ForegroundColor Green "Search Query  : $($query)"
	Write-Host -ForegroundColor Green "Context Lines : $($contextlines)"
	Write-Host
	Write-Host -ForegroundColor Green "===================================================================================================="
	
	$pyquery = Convert-To-Py -query $query
	$pyfiles = Get-ChildItem -Path $srcpath -File -Exclude "reports","__*__" -Recurse -Filter "*.py"
	Foreach ($file in $pyfiles) {
		File-Search-Display -file $file -query $pyquery -rootdir $srcpath -contextlines $contextlines
	}
	
	$featurequery = Convert-To-Feature -query $query
	$featurefiles = Get-ChildItem -Path $srcpath -File -Exclude "reports","__*__" -Recurse -Filter "*.feature"
	Foreach ($file in $featurefiles) {
		File-Search-Display -file $file -query $featurequery -rootdir $srcpath -contextlines $contextlines
	}

	Write-Host
	$query = Read-Host -Prompt "Search Query"
}