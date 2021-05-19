. "..\..\PsLib\PsFiles.ps1"
. ".\config.ps1"

if (Is-File -file $args[0]) {
	. (Resolve-Path $args[0])
	Write-Host "Loaded $($args[0])"
	Start-Sleep -Seconds 2
} elseif (Is-File -file "$($args[0]).ps1") {
	. (Resolve-Path "$($args[0]).ps1")
	Write-Host "Loaded $($args[0]).ps1"
	Start-Sleep -Seconds 2
} else {
	Write-Host "Usage: build-utility utility.ps1"
	pause
	exit
}

function banner($msg, [switch] $cls) {
	if ($cls) {
		clear
	}
	$len = $msg.length
	$lenFull = $len + 10 # 5 chars left + 5 chars right
	$spcFull = $len + 4  # 2 spaces left + 2 spaces right (2 * 3 / chars also added)
	Write-Host
	Write-Host "        $("/" * $lenFull)"
	Write-Host "       ///$(" " * $spcFull)///"
	Write-Host "      //   $($msg)   //"
	Write-Host "     ///$(" " * $spcFull)///"
	Write-Host "    $("/" * $lenFull)"
	Write-Host
}


$FULL = 0
$BUILD = 1
$DEPLOY = 2
$STOP = 3
$RESTART = 4
$EXIT = 5
function Prompt-Command() {
	$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Full", "&Build", "&Deploy", "&Stop $($SERVER_NAME)", "&Restart $($SERVER_NAME)", "E&xit")
	return $host.UI.PromptForChoice("Select Option" , "" , $Options, 0)
}

banner -msg "$($SERVER_NAME) Utility" -cls
Write-Host "This tool restarts the Apache $($SERVER_NAME) service"
Write-Host "and only functions when started in admin mode"
Write-Host
get-server-processes
Write-Host "Completed: $(Get-Date)`n"



for ($opt = Prompt-Command; $opt -ne $EXIT; $opt = Prompt-Command) {
	if ($opt -eq $FULL) {
		rebuild-project
		stop-server
		deploy-project
		start-server
	}
	if ($opt -eq $BUILD) {
		rebuild-project
	}
	if ($opt -eq $DEPLOY) {
		deploy-project
	}
	if ($opt -eq $STOP) {
		stop-server
	}
	if ($opt -eq $RESTART) {
		stop-server
		start-server
	}
	
	banner -msg "$($SERVER_NAME) Utility" -cls
	get-server-processes
	Write-Host
	Write-Host "Completed: $(Get-Date)`n"
}
