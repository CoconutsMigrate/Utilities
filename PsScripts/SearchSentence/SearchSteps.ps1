. "..\..\PsLib\PsUtil.ps1"
. "..\..\PsLib\PsIni.ps1"
. "..\..\PsLib\PsFiles.ps1"
. "..\..\PsLib\PsPy.ps1"

. ".\Common.ps1"

# Match @step("step name") followed by def
# Match def fn_name():
function File-Search-Display( [string] $file, $config, [string] $query, [switch] $showDetails ) {
	$filenameWritten = $false
	$lineno = 0
	# Match query as a function
	$defQuery = " *def +$($query) *\(.*\):"
	$defCurrentMatch = $false
	# Match query as a step
	$stepQuery = "@step.*$($query)"
	$stepCurrentMatch = $false
	foreach($line in Get-Content $file -encoding UTF8) {
		$lineno++
		if($line -match $stepQuery){
			# Write file name if needed
			if ($filenameWritten -eq $false) {
				$filenameWritten = $true
				$truncpath = $file -replace [regex]::escape($config.srcpath)
				Write-Host -ForegroundColor Blue "`n~$($truncpath)"
			}
			
			$line = $line -replace "@step",""
			$line = Convert-To-Feature -query $line
			$line = $line -replace "\( *'?",""
			$line = $line -replace "'? *\)",""
			$line = $line -replace " *#.*",""

			# Write match lines
			Write-Line -lineno $lineno -line $line -highlight $true
			$stepCurrentMatch = $true
		} elseif ($stepCurrentMatch -and $showDetails -and ($line -match "^def")) {
			Write-Line -line $line -highlight $false -trim $false
		} elseif (($stepCurrentMatch -or $defCurrentMatch) -and $showDetails) {
			if ($line -match "^\S") {
				$stepCurrentMatch = $false
				$defCurrentMatch = $false
			} else {
				Write-Line -line $line -highlight $false -trim $false
				if ($line -match "^ *([a-zA-Z_]*\.)?([a-zA-Z_]+)\(") {
					$result = $Matches[2]
					$fnList.Add($result) | Out-Null
				}
			}
		} elseif ($line -match $defQuery) {
			if ($filenameWritten -eq $false) {
				$filenameWritten = $true
				$truncpath = $file -replace [regex]::escape($config.srcpath)
				Write-Host -ForegroundColor Blue "`n~$($truncpath)"
			}
			Write-Line -lineno $lineno -line $line -highlight $true
			$defCurrentMatch = $true
		}
	}
}

function Def-Search-Display( [string] $file, $config, [string] $query ) {

}

#Search config
$config = @{ contextlines = 0; contextlinesprev = 0; contextlinesnext = 0; srcpath = "C:\"; pyquery = ""; featurequery = "" }
$config = Read-Ini-File -configPath .\SearchSteps.ini -config $config

While ($true) {
	Query-Config -config $config -configFileName .\SearchSteps.ini
	Clear-Host
	Write-Host
	Write-Host -ForegroundColor Green "===================================================================================================="
	Write-Host
	Write-Host -ForegroundColor Green "Search Folder : $($config.srcpath)"
	Write-Host -ForegroundColor Green "Py Query      : $($config.pyquery)"
	Write-Host -ForegroundColor Green "Context Lines : $($config.contextlinesprev),$($config.contextlinesnext)"
	Write-Host
	Write-Host -ForegroundColor Green "===================================================================================================="
	
	$pyfiles = Get-ChildItem -Path $config.srcpath -File -Exclude "reports","__*__" -Recurse -Filter "*.py"
	$details = $config.pyquery.length -ge 10
	$fnList = [System.Collections.ArrayList]@()
	Foreach ($file in $pyfiles) {	
		File-Search-Display -file $file -config $config -query $config.pyquery -showDetails:$details
	}
	
	$fnList = $fnList | select -Unique
	Display-Py-Functions-In-Folder -fnList $fnList -folderPath $config.srcpath
	#Foreach ($fn in $fnList) {
	#	Display-Py-Function-In-Folder -name $fn -folderPath $config.srcpath
	#}
}

