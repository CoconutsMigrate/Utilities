$defsrcpath = "C:\Git\system_test_cases\system"
# TODO: contextLines
$contextLines = $true

function File-Search-Display( [string] $file, [string] $query, [string] $rootdir ) {
	$content = ""
	$lineno = 0
	$query = [regex]::escape($query)
	foreach($line in Get-Content $file -encoding UTF8) {
		$lineno++
		if($line -match $query){
			$line = $line.trim()
			$content = "$($content)$($lineno) $($line)`n"
		}
	}
	if ($content -ne "") {
		$truncpath = $file -replace [regex]::escape($rootdir)
		Write-Host -ForegroundColor Blue "~$($truncpath)"
		Write-Host -ForegroundColor Yellow $content
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

$srcpath = Read-Host -Prompt "Mappa [$($defsrcpath)]"
if ($srcpath -eq "") {
	$srcpath = $defsrcpath
}

$query = Read-Host -Prompt "Keresett mondat"

While ($query -ne "") {
	Clear-Host
	Write-Host
	Write-Host -ForegroundColor Green "===================================================================================================="
	Write-Host
	Write-Host -ForegroundColor Green "Mappa           : $($srcpath)"
	Write-Host -ForegroundColor Green "Keresett mondat : $($query)"
	Write-Host
	Write-Host -ForegroundColor Green "===================================================================================================="
	Write-Host
	
	$pyquery = Convert-To-Py -query $query
	$pyfiles = Get-ChildItem -Path $srcpath -File -Exclude "reports","__*__" -Recurse -Filter "*.py"
	Foreach ($file in $pyfiles) {
		File-Search-Display -file $file -query $pyquery -rootdir $srcpath
	}
	
	$featurequery = Convert-To-Feature -query $query
	$featurefiles = Get-ChildItem -Path $srcpath -File -Exclude "reports","__*__" -Recurse -Filter "*.feature"
	Foreach ($file in $featurefiles) {
		File-Search-Display -file $file -query $featurequery -rootdir $srcpath
	}

	Write-Host
	$query = Read-Host -Prompt "Keresett mondat"
}