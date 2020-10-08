. "..\..\PsLib\PsUtil.ps1"
. "..\..\PsLib\PsIni.ps1"
. "..\..\PsLib\PsFiles.ps1"

. ".\Common.ps1"

function File-Search-Display( [string] $file, $config, [string] $query ) {
	$query = "@step\( *(.*$($query).*) *\)"
	foreach($line in Get-Content $file -encoding UTF8) {
		if($line -match $query){
			$res = $Matches[1]
			$res = $res -replace "^'",""
			$res = $res -replace "'$",""
			$res = $res -replace "{","<"
			$res = $res -replace "}'",">"
			# Write match lines
			Write-Line -lineno "" -line $res -highlight $true			
		}
	}
}

#Search config
$config = @{ contextlines = 0; contextlinesprev = 0; contextlinesnext = 0; srcpath = "C:\"; pyquery = ""; featurequery = "" }
$config = Read-Ini-File -configPath .\ListSentences.ini -config $config

While ($true) {
	Query-Config -config $config -configFileName .\ListSentences.ini
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
	
	Write-Host
	$pyfiles = Get-ChildItem -Path $config.srcpath -File -Exclude "reports","__*__" -Recurse -Filter "*.py"
	Foreach ($file in $pyfiles) {
		File-Search-Display -file $file -config $config -query $config.pyquery
	}
}
