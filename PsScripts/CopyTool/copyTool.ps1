
$opt = ""

function read-multiline($firstLine) {
    $str = $firstLine
    $lineSep = "`n"
    while ($true) {
        $line = Read-Host
        if ($line -eq "") {
            return $str
            
        } else {
            $str = "$($str)$($lineSep)$($line)"
        }
    }
}

function query-copy() {
    $items = @()
    while ($true) {
        $opt = Read-Host -Prompt "Add Config"
        if ($opt -ne "") {
            $ml = read-multiline -firstLine $opt
            $items += $ml
        } else {
            return $items
        }
    }
}

while ($opt -ne "X") {
    clear
    for ($i = 0; $i -lt $items.count; $i++) {
        Write-Host $i
        Write-Host $items[$i]
    }
    $opt = Read-Host -Prompt "Num: copy, c: config, x: exit"
    if ([bool]($opt -as [int] -is [int])) {
        [int] $index = $opt
        Write-Host "Index: $($index)"
        $value = $items.Get($index)
        Write-Host "Value: $($value)"
        Set-Clipboard -Value $value
    }
    if ($opt -eq "c") {
        $items = query-copy
    }
}