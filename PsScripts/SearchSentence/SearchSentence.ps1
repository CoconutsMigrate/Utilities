. "..\..\PsLib\PsUtil.ps1"
. "..\..\PsLib\PsIni.ps1"
. "..\..\PsLib\PsFiles.ps1"

. ".\Common.ps1"

function Clear-Array( [array] $array ) {
	for ($index=0; $index -lt $array.Length; $index++) {
		$array[$index] = ""
	}
}

function Add-To-Array( [array] $array, [string] $value ) {
	if ($array.Length -eq 0) {
		return
	}
	for ($index=0; $index -lt $array.Length - 1; $index++) {
		$array[$index] = $array[$index + 1]
	}
	$array[$array.Length - 1] = $value
}

function Write-Context-Lines( $array ) {
	for ($index=0; $index -lt $array.Length; $index++) {
		Write-Line -lineno "" -line $array[$index] -highlight $false
	}
}

function File-Search-Display( [string] $file, $config, [string] $query ) {
	$filenameWritten = $false
	$lastMatch = -10
	$lineno = 0
	$array = @("") * $config.contextlinesprev
	foreach($line in Get-Content $file -encoding UTF8) {
		$lineno++
		if($line -match $query){
			# Write file name if needed
			if ($filenameWritten -eq $false) {
				$filenameWritten = $true
				$truncpath = $file -replace [regex]::escape($config.srcpath)
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
			
		} elseif ($lineno -le $lastMatch + $config.contextlinesnext) {
			# Write current context line
			Write-Line -lineno "" -line $line -highlight $false
		} else {
			# Add context line
			Add-To-Array -array $array -value $line.trim()
		}
	}
}

#Search config
$config = @{ contextlines = 0; contextlinesprev = 0; contextlinesnext = 0; srcpath = "C:\"; pyquery = ""; featurequery = "" }
$config = Read-Ini-File -configPath .\SearchSentence.ini -config $config

While ($true) {
	Query-Config -config $config
	Clear-Host
	Write-Host
	Write-Host -ForegroundColor Green "===================================================================================================="
	Write-Host
	Write-Host -ForegroundColor Green "Search Folder : $($config.srcpath)"
	Write-Host -ForegroundColor Green "Feature Query : $($config.featurequery)"
	Write-Host -ForegroundColor Green "Py Query      : $($config.pyquery)"
	Write-Host -ForegroundColor Green "Context Lines : $($config.contextlinesprev),$($config.contextlinesnext)"
	Write-Host
	Write-Host -ForegroundColor Green "===================================================================================================="
	
	$pyfiles = Get-ChildItem -Path $config.srcpath -File -Exclude "reports","__*__" -Recurse -Filter "*.py"
	Foreach ($file in $pyfiles) {
		File-Search-Display -file $file -config $config -query $config.pyquery
	}
	
	$featurefiles = Get-ChildItem -Path $config.srcpath -File -Exclude "reports","__*__" -Recurse -Filter "*.feature"
	Foreach ($file in $featurefiles) {
		File-Search-Display -file $file -config $config -query $config.featurequery
	}
}
