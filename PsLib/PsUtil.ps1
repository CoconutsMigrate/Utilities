
### Browse Folder

function Browse-Folder([string] $prompt="Browse Folder", [string] $startFrom) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
		Description = $prompt
		SelectedPath = $startFrom
	}
	if ($foldername.ShowDialog() -eq "OK") {
		return $foldername.SelectedPath
    } else {
		return $startFrom
    }
}

function Browse-File([string] $prompt="Browse File", [string] $startFrom, [string] $filter="*.*") {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
	
	$fileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
		Title = $prompt
		Multiselect = $false
		Filter = $filter
		InitialDirectory = $startFrom
	}
	if ($fileBrowser.ShowDialog() -eq "OK") {
		return $fileBrowser.FileName
    } else {
		return $startFrom
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

### Boolean question

function Prompt-Boolean-Choice( [string] $title ) {
	$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No")
	$opt = $host.UI.PromptForChoice($title , "" , $Options, 0)
	return $opt -eq 0
}

