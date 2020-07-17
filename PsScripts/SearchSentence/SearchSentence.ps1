. "..\..\PsLib\PsUtil.ps1"
. "..\..\PsLib\PsIni.ps1"
. "..\..\PsLib\PsFiles.ps1"

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

function Convert-To-Feature( [string] $query, [switch] $convertRegex ) {
	$conv = $query -replace "{","<"
	$conv = $conv -replace "}",">"
	if ($convertRegex) {
		$conv = [regex]::escape($conv)
	}
	return $conv
}

function Convert-To-Py( [string] $query, [switch] $convertRegex ) {
	$conv = $query -replace "<","{"
	$conv = $conv -replace ">","}"
	if ($convertRegex) {
		$conv = [regex]::escape($conv)
	}
	return $conv
}

function Query-Config( $config ) {
	while ($config.srcpath -eq "") { # Make sure path is set
		$p = Browse-Folder -prompt "Search Folder" -startFrom $config.srcpath
		$config.srcpath = if ($p -ne "") {$p} else {$config.srcpath}
	}
	Write-Host
	$enteredQuery = $false
	do {
		Write-Host
		Write-Host -ForegroundColor Cyan "Specify query to search or options below"
		Write-Host -ForegroundColor Cyan "(empty)        Rerun previous query [$($config.featurequery)]"
		Write-Host -ForegroundColor Cyan "-r             Specify regex query  [$($config.pyquery)]"
		Write-Host -ForegroundColor Cyan "-c -cp -cn     Set (both, prev, next) context lines    [$($config.contextlinesprev), $($config.contextlinesnext)]"
		Write-Host -ForegroundColor Cyan "-p             Set search path      [$($config.srcpath)]"
		Write-Host -ForegroundColor Cyan "-x             Exit"
		
		$query = Read-Host -Prompt "Search Query or Command"
		if ($query -eq "") {
			# keep previous query
			$enteredQuery = $true
		} elseif ($query -like "-r*") {
			$query = $query -replace "-r *"
			while ($query -eq "") {
				$query = Read-Host -Prompt "Regex Query"
			}
			$config.pyquery = Convert-To-Py -query $query
			$config.featurequery = Convert-To-Feature -query $query
		} elseif ($query -like "-cp*") {
			$query = $query -replace "-cp *"
			$config.contextlinesprev = Get-Int-With-Initial -prompt "Prev Context Lines" -initial $query -min 0 -max 10
		} elseif ($query -like "-cn*") {
			$query = $query -replace "-cn *"
			$config.contextlinesnext = Get-Int-With-Initial -prompt "Next Context Lines" -initial $query -min 0 -max 10
		} elseif ($query -like "-c*") {
			$query = $query -replace "-c *"
			$config.contextlines = Get-Int-With-Initial -prompt "Context Lines" -initial $query -min 0 -max 10
			$config.contextlinesprev = $config.contextlines
			$config.contextlinesnext = $config.contextlines
		} elseif ($query -like "-p*") {
			$query = $query -replace "-p *"
			if (Is-Folder -file $query) {
				$config.srcpath = $query
			} else {
				$config.srcpath = Browse-Folder -prompt "Search Folder" -startFrom $config.srcpath
			}
		} elseif ($query -like "-x*") {
			exit
		} else {
			$config.pyquery = Convert-To-Py -query $query -convertRegex
			$config.featurequery = Convert-To-Feature -query $query -convertRegex
			$enteredQuery = $true
		}
		Write-Ini-File -configPath .\SearchSentence.ini -config $config
	} until ($enteredQuery)
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
