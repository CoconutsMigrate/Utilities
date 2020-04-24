Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
function Display-Text-Dialog( [string] $title, [string] $text) {
	$form = New-Object System.Windows.Forms.Form
	$form.Text = $title
	$form.Size = New-Object System.Drawing.Size(1036,630)
	$form.StartPosition = 'CenterScreen'
	$form.FormBorderStyle = 'FixedDialog'

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(10,550)
	$OKButton.Size = New-Object System.Drawing.Size(75,23)
	$OKButton.Text = 'OK'
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	$textBox = New-Object System.Windows.Forms.TextBox
	$textBox.Location = New-Object System.Drawing.Point(10,10)
	$textBox.Size = New-Object System.Drawing.Size(1000,520)
	$textBox.Multiline = $true
	$textBox.Scrollbars = "Both"
	$textBox.Text = $text

	$form.Controls.Add($textBox)

	$form.Topmost = $true

	$form.Add_KeyDown({
		Write-Host $_
		if ($_.KeyCode -eq "Escape") {
			$form.Close()
		}
	})

	$result = $form.ShowDialog()
}

#Display-Text-Dialog -title "Info" -text "text"