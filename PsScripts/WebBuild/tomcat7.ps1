. ".\tomcat-common.ps1"

$SOURCE_HOME = $ECDC_SOURCE_HOME
$DEPLOY_FILE = $ECDC_DEPLOY_FILE
$SERVER_NAME = $TOMCAT7_SERVER_NAME
$SERVER_HOME = $TOMCAT7_SERVER_HOME

function get-server-processes() {
	return Get-Process | Where-Object { $_.MainWindowTitle -eq 'Tomcat' } | Format-Table -Property id,name,@{Label="Title"; Expression={$_.MainWindowTitle}}
}

function stop-server() {
	if (is-server-running) {
		banner -msg "Stop $($SERVER_NAME)" -cls
		pushd "$($SERVER_HOME)\bin"
		.\shutdown.bat
		popd
		Start-Sleep -Seconds 2
	}
}

function start-server() {
	banner -msg "Start $($SERVER_NAME)" -cls
	pushd "$($SERVER_HOME)\bin"
	.\startup.bat
	popd
	Start-Sleep -Seconds 2
}
