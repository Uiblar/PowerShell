clear-host
Write-Host "Script started"

$WShell = New-Object -com "WScript.shell"
$counter = 0
try{
	while ($true){
		$WShell.sendkeys("{SCROLLLOCK}")
		start-sleep -Milliseconds 100
		$WShell.sendkeys("{SCROLLLOCK}")
		$counter = $counter + 1
		Echo "deployed, $($counter)"
		start-sleep -Seconds 240
		}
	}
catch{
	Write-Host "Error occured"
}
