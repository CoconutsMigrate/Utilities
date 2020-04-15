### Read / Write Config

function Read-Ini-File( [string] $configPath, $config ) {
	if (Test-Path $configPath) {
		Get-Content $configPath | 
		foreach-object -process {
			$k = [regex]::split($_,'=');
			if (($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $true)) {
				$config.Set_Item($k[0], $k[1])
			}
		}
		return $config
	} else {
		return $config
	}
}

function Write-Ini-File( [string] $configPath, $config ) {
	"[config]" | Out-File -FilePath $configPath -encoding UTF8
	foreach ($c in $config.GetEnumerator()) {
		"$($c.Name)=$($c.Value)" | Out-File -FilePath $configPath -Append -encoding UTF8 
	}
}
