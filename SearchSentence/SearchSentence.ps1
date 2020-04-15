. "..\PsLib\PsUtil.ps1"
. "..\PsLib\PsIni.ps1"

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

function File-Search-Display( [string] $file, [string] $query, [string] $rootdir, [string] $contextlines ) {
	$filenameWritten = $false
	$lastMatch = -$contextlines
	$lineno = 0
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

function Query-Config( $config ) {
	while ($config.srcpath -eq "") { # Make sure path is set
		$p = Browse-Folder -prompt "Search Folder" -startFrom $config.srcpath
		$config.srcpath = if ($p -ne "") {$p} else {$config.srcpath}
	}
	Write-Host
	do {
		Write-Host
		Write-Host -ForegroundColor Cyan "Specify query to search or options below"
		Write-Host -ForegroundColor Cyan "(empty)  Rerun previous query [$($config.query)]"
		Write-Host -ForegroundColor Cyan "---r     Specify regex query  [$($config.query)]"
		Write-Host -ForegroundColor Cyan "---c     Set context lines    [$($config.contextlines)]"
		Write-Host -ForegroundColor Cyan "---p     Set search path      [$($config.srcpath)]"
		Write-Host -ForegroundColor Cyan "---x     Exit"
		
		$query = Read-Host -Prompt "Search Query"
		if ($query -eq "") {
			# keep previous query
		} elseif ($query -eq "---r") {
			$config.query = Read-Host -Prompt "Regex Query"
		} elseif ($query -eq "---c") {
			$config.contextlines = Read-Int-Min-Max -prompt "Context Lines" -min 0 -max 10
		} elseif ($query -eq "---p") {
			$config.srcpath = Browse-Folder -prompt "Search Folder" -startFrom $config.srcpath
		} elseif ($query -eq "---x") {
			exit
		} else {
			$config.query = [regex]::escape($query)
		}
		Write-Ini-File -configPath .\SearchSequence.ini -config $config
	} until ($config.query -ne "")
}


#Search config
$config = @{ query = ""; contextlines = 0; srcpath = "" }
$config = Read-Ini-File -configPath .\SearchSequence.ini -config $config

While ($true) {
	Query-Config -config $config
	Clear-Host
	Write-Host
	Write-Host -ForegroundColor Green "===================================================================================================="
	Write-Host
	Write-Host -ForegroundColor Green "Search Folder : $($config.srcpath)"
	Write-Host -ForegroundColor Green "Search Query  : $($config.query)"
	Write-Host -ForegroundColor Green "Context Lines : $($config.contextlines)"
	Write-Host
	Write-Host -ForegroundColor Green "===================================================================================================="
	
	$pyquery = Convert-To-Py -query $config.query
	$pyfiles = Get-ChildItem -Path $config.srcpath -File -Exclude "reports","__*__" -Recurse -Filter "*.py"
	Foreach ($file in $pyfiles) {
		File-Search-Display -file $file -query $pyquery -rootdir $config.srcpath -contextlines $config.contextlines
	}
	
	$featurequery = Convert-To-Feature -query $config.query
	$featurefiles = Get-ChildItem -Path $config.srcpath -File -Exclude "reports","__*__" -Recurse -Filter "*.feature"
	Foreach ($file in $featurefiles) {
		File-Search-Display -file $file -query $featurequery -rootdir $config.srcpath -contextlines $config.contextlines
	}
}