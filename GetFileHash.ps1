Function Get-FileName($initialDirectory) {
	$dialog = [System.Windows.Forms.OpenFileDialog]::new()
	$dialog.InitialDirectory = $initialDirectory
	$dialog.RestoreDirectory = $true
	$result = $dialog.ShowDialog()
	
	if($result -eq [System.Windows.Forms.DialogResult]::OK){
		return $dialog.FileName
	}
}
Function NewLine{
	Write-Host "`n"
}
$Hash = @()
$Selection = @(
	"SHA1",
	"SHA256",
	"SHA384",
	"SHA512",
	"MD5",
	"MACTripleDES",
	"RIPEMD160",
	"Select new File",
	"Exit"
)
$FileName = Get-FileName
Write-Host "$FileName"
NewLine
while($true){
	$counter = 0
	write-host "Select Algorithm"
	NewLine
	foreach($Option in $Selection){
		write-host "($($counter)) $($Option)"
		$counter = $counter + 1
	}
	[string]$InputSelection = Read-Host
	switch ($InputSelection){
		{$_ -eq "0"}{$Hash = Get-FileHash -Path "$FileName" -Algorithm SHA1}
		{$_ -eq "1"}{$Hash = Get-FileHash -Path "$FileName" -Algorithm SHA256}
		{$_ -eq "2"}{$Hash = Get-FileHash -Path "$FileName" -Algorithm SHA384}
		{$_ -eq "3"}{$Hash = Get-FileHash -Path "$FileName" -Algorithm SHA512}
		{$_ -eq "4"}{$Hash = Get-FileHash -Path "$FileName" -Algorithm MD5}
		{$_ -eq "5"}{$Hash = Get-FileHash -Path "$FileName" -Algorithm MACTripleDES}
		{$_ -eq "6"}{$Hash = Get-FileHash -Path "$FileName" -Algorithm RIPEMD160}
		{$_ -eq "7"}{$FileName = Get-FileName}
		{$_ -eq "8"}{exit}
	}
	Start-Sleep -Seconds 1
	NewLine
	write-host "$($Hash.Hash)"
	NewLine
}
