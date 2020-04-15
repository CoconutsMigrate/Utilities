

### Browse Folder

function Browse-Folder([string] $prompt, [string] $startFrom) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
		Description = $prompt
		SelectedPath = $startFrom
	}
	
    if ($foldername.ShowDialog() -ne "OK") {
		return $foldername.SelectedPath
    } else {
		return ""
    }
}




### Read int values

function Read-Int-Min-Max( [string] $prompt, [int] $min, [int] $max ) {
	while ($true) {
		try {
			[int] $value = Read-Host "$($prompt) [$($min)..$($max)]"
			if (($value -ge $min) -and ($value -le $max)) {
				return $value
			}
		} catch {}
	}
}
function Read-Int-Min( [string] $prompt, [int] $min ) {
	while ($true) {
		try {
			[int] $value = Read-Host "$($prompt) [$($min)..]"
			if ($value -ge $min) {
				return $value
			}
		} catch {}
	}
}
function Read-Int-Max( [string] $prompt, [int] $max ) {
	while ($true) {
		try {
			[int] $value = Read-Host "$($prompt) [..$($max)]"
			if ($value -le $max) {
				return $value
			}
		} catch {}
	}
}

