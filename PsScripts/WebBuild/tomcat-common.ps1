function is-server-running() {
	$count = @(get-server-processes).count
	return $count -ge 1
}

function rebuild-project() {
	while ($true) {
		banner -msg "Build $($DEPLOY_FILE)" -cls
		pushd $($SOURCE_HOME)
		ant clean build-war | Tee-Object -Variable "antbuild"
		popd
		if ($antbuild -Match "SUCCESSFUL") {
			Start-Sleep -Seconds 2
			break;
		}
		pause
	}
}

function deploy-project() {
	banner -msg "Copy ecdc.war" -cls
	
	Write-Host "Remove $($SERVER_HOME)\webapps\ecdc"
	Remove-Item "$($SERVER_HOME)\webapps\ecdc" -Recurse 2>$null
	
	Write-Host "Remove $($SERVER_HOME)\work\Catalina\localhost\ecdc"
	Remove-Item "$($SERVER_HOME)\work\Catalina\localhost\ecdc" -Recurse 2>$null
	
	Write-Host "Remove $($SERVER_HOME)\webapps\$($DEPLOY_FILE)"
	Remove-Item "$($SERVER_HOME)\webapps\$($DEPLOY_FILE)" 2>$null
	
	Write-Host "Copy $($SOURCE_HOME)\$($DEPLOY_FILE) -> $($SERVER_HOME)\webapps\$($DEPLOY_FILE)"
	Copy-Item -Path "$($SOURCE_HOME)\$($DEPLOY_FILE)" -Destination "$($SERVER_HOME)\webapps\$($DEPLOY_FILE)" -Force
	
	Start-Sleep -Seconds 2
}