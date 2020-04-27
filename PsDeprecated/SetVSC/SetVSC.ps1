. "..\..\PsLib\PsUi.ps1"
. "..\..\PsLib\PsUtil.ps1"
. "..\..\PsLib\PsFiles.ps1"
. "..\..\PsLib\PsIni.ps1"

$config = @{}
$config = Read-Ini-File -configPath .\SetVSC.ini -config $config

Write-Host "$(Get-Content -Path $config.launch -Raw -Encoding UTF8)"

$filename = Browse-File -prompt "Select test case" -startFrom $config.systemDir -filter 'Feature files|*.feature'

if (Is-File $filename) {
	$testPath = ($filename -replace [regex]::escape($config.systemDir),"")
	$testPath = ($testPath -replace [regex]::escape("\"),"/")

	if (-Not (Test-Path $config.vscodeDir)) {
		New-Item -Path $config.rootDir -Name ".vscode" -ItemType "directory"
	}

	(Get-Content -path "Files\launch.json" -Raw) -replace 'FeaturePath',$testPath | Set-Content -Path $config.launch
	Copy-Item "Files\settings.json" -Destination $config.settings
	
	$content = Get-Content -path $filename -raw -encoding UTF8
	Display-Text-Dialog -title $filename -text $content
}
