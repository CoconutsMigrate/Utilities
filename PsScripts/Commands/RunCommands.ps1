. "..\..\PsLib\PsUtil.ps1"
. "..\..\PsLib\PsIni.ps1"
. "..\..\PsLib\PsFiles.ps1"

function Query-Config( $config, [string] $configFileName ) {
	Write-Host
	do {
		Write-Host
		Write-Host -ForegroundColor Cyan "Specify query to search or options below"
		Write-Host -ForegroundColor Cyan "(empty)        Rerun previous query [$($cmd)]"
		foreach ($c in $config.Keys) {
			Write-Host -ForegroundColor Cyan "${c}    $($config.Item($c))"
		}
		Write-Host -ForegroundColor Cyan "-x             Exit"
		
		$query = Read-Host -Prompt "Search Query or Command"
		if ($query -eq "") {
			# keep previous query
		} elseif ($config.ContainsKey($query)) {
			$cmd = $config[$query]
		} elseif ($query -like "-x*") {
			exit
		}
	} until ($cmd -ne "")
	return $cmd
}

function Perform-Command( $cmd ) {
	foreach ($c in $cmd) {
		Write-Host -ForegroundColor Yellow $c
		Invoke-Expression $c
	}
}

#Search config
$config = @{ "t0" = "net stop tomcat9"; "t1" = "net start tomcat9"; "tr" = @("net stop tomcat9"; "net start tomcat9") }
#$config = Read-Ini-File -configPath .\RunCommands.ini -config $config
$cmd = ""


While ($true) {
	$cmd = Query-Config -config $config -configFileName .\SearchSentence.ini
	Clear-Host
	Perform-Command -cmd $cmd
}