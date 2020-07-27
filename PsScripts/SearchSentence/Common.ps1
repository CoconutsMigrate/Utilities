
function Write-Line( $lineno="", $line, $highlight ) {
	if ($line -ne "") {
		$col = if ($highlight) {"Yellow"} else {"Gray"}
		Write-Host -ForegroundColor $col "$($lineno.ToString().PadLeft(5, " "))  $($line.trim())"
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

function Query-Config( $config, [string] $configFileName ) {
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
			$enteredQuery = $true
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
		Write-Ini-File -configPath $configFileName -config $config
	} until ($enteredQuery)
}