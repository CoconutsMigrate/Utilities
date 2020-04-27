# File encoding

function Get-File-Encoding( [string] $FilePath ) {
    [byte[]] $byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $FilePath

    if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )
        { $encoding = 'UTF8' }  
    elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
        { $encoding = 'BigEndianUnicode' }
    elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe)
         { $encoding = 'Unicode' }
    elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
        { $encoding = 'UTF32' }
    elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76)
        { $encoding = 'UTF7'}
    else
        { $encoding = 'ASCII' }
    return $encoding
}

function Is-File( [string] $file ) {
	return (($file -ne "") -and (Test-Path $file) -and ((Get-Item $file) -is [System.IO.FileInfo]))
}

function Is-Folder( [string] $file ) {
	return (($file -ne "") -and (Test-Path $file) -and ((Get-Item $file) -is [System.IO.DirectoryInfo]))
}

function Does-Not-Exist( [string] $file ) {
	return (($file -eq "") -or (Test-Path $file) -eq $false)
}

