. "..\..\PsLib\PsUtil.ps1"
. "..\..\PsLib\PsIni.ps1"
. "..\..\PsLib\PsFiles.ps1"

#PS C:\> ((Get-Content -path C:\ReplaceDemo.txt -Raw) -replace 'brown','white') | Set-Content -Path C:\ReplaceDemo.txt
#PS C:\> Get-Content -path C:\ReplaceDemo.txt


function File-Filter-Replace( [string] $srcpath, [string] $filter, [string] $from, [string] $to ) {
	Get-ChildItem -Path $srcpath -Filter $filter -Recurse | 
	Foreach-Object {
		if ((Get-Item $_.FullName).length -ge 4) {
			$encoding = Get-File-Encoding -FilePath $_.FullName
			$content = Get-Content $_.FullName -Raw
			$fromregex = [regex]::escape($from)
			$newcontent = $content -replace $fromregex,$to
			if ($content -ne $newcontent) {
				$newcontent | Set-Content -Path $_.FullName -NoNewline
				Write-Host $_.FullName
			}
		}
	}
}

#    $encoding = Get-FileEncoding $textFile
#    $content = Get-Content -Encoding $encoding
#    $content | Set-Content -Path $textFile -Encoding $encoding


$config = @{ srcpath = "" }
$config = Read-Ini-File -configPath .\RenameSequence.ini -config $config
Write-Ini-File -configPath .\RenameSequence.ini -config $config
Write-Host $config.srcpath

Write-Host
Write-Host -ForegroundColor Yellow "/-----------------------\"
Write-Host -ForegroundColor Yellow "|                       |"
Write-Host -ForegroundColor Yellow "|  Search-Replace Step  |"
Write-Host -ForegroundColor Yellow "|                       |"
Write-Host -ForegroundColor Yellow "\-----------------------/"
Write-Host
Write-Host

Do {
	$origfeature = Read-Host -Prompt "Original    "
	$origfeature = $origfeature -replace "{","<"
	$origfeature = $origfeature -replace "}",">"

	$origstep = $origfeature
	$origstep = $origfeature -replace ">","}"
	$origstep = $origstep -replace "<","{"

	$newfeature = Read-Host  -Prompt "Replacement "
	$newfeature = $newfeature -replace "{","<"
	$newfeature = $newfeature -replace "}",">"

	$newstep = $newfeature
	$newstep = $newfeature -replace ">","}"
	$newstep = $newstep -replace "<","{"

	Write-Host
	Write-Host -ForegroundColor Yellow "Feature:"
	Write-Host -ForegroundColor Red "$($origfeature)"
	Write-Host -ForegroundColor Green "$($newfeature)"
	Write-Host
	Write-Host -ForegroundColor Yellow "Step:"
	Write-Host -ForegroundColor Red "$($origstep)"
	Write-Host -ForegroundColor Green "$($newstep)"
	Write-Host

	$bmod = Prompt-Boolean-Choice -title "Correct?"
	
	if($bmod -eq $true) {
		Write-Host "Searching..."
		File-Filter-Replace -srcpath $config.srcpath -filter *.feature -from $origfeature -to $newfeature
		File-Filter-Replace -srcpath $config.srcpath -filter *.py -from $origstep -to $newstep
	}
	$bopt = Prompt-Boolean-Choice -title "Replace again?"
} Until ($bopt -eq $false)
