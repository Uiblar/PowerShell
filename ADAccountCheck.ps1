Clear-Host
Function ConvertTime{
    Param([Parameter(Mandatory)]$TimeNT)
    Process{
    $LocalZone = [System.TimeZoneInfo]::Local
    $Date = ([System.TimeZoneInfo]::ConvertTimeFromUtc(([DateTime]::FromFileTimeUTC($TimeNT)),$LocalZone))
    get-date $Date -Format "dd.MM.yyyy HH:mm:ss"
    }
}
Function NewLine{
	Write-Host "`n" -NoNewline
}
$DCs = @()
$DCDiscovery = (Get-ADDomainController -Filter * | select name)
foreach($dc in $DCDiscovery){
    $DCs += $dc.name
}
while($true){
    $LogonList = @()
    $user = ""
    #Get User
    while($user.length -eq 0){$user = Read-Host "Bitte Benutzernamen eingeben";NewLine}
    try{$ADUser = Get-ADUser -identity $user -Properties *}
    catch{Write-Host "User not found" -ForegroundColor Red; continue}
    #Return DN
    Write-Host "$(try{$ADUser.DisplayName}catch{"USER HAS NO GIVEN NAME"})"
    NewLine
    Write-Host "Account befindet sich in OU: $(try{$ADuser.DistinguishedName}catch{"NOT FOUND"})"
    #Check Last PW Change
    Write-Host "Letzter Passwortwechsel: $(try{ConvertTime -TimeNT $ADUser.pwdLastSet}catch{"NOT FOUND"})"
    Write-Host "Letzter fehlgeschlagener Login: $(try{get-date $ADUser.LastBadPasswordAttempt -Format "dd.MM.yyyy HH:mm:ss"}catch{"NOT FOUND"})"
    #Check Account Lockout Status
    if ($ADUser.lockedout) {write-host "Konto gesperrt" -ForegroundColor Red}
    else {write-host "Konto nicht gesperrt" -ForegroundColor Green}
    #Check Account Active
    if ($ADUser.enabled) {write-host "Konto aktiviert" -ForegroundColor Green}
    else {write-host "Konto deaktiviert" -ForegroundColor Red}
    #Check PW Life
    if ($ADUser.passwordexpired) {write-host "Passwort abgelaufen" -ForegroundColor Red}
    else {write-host "Passwort nicht abgelaufen" -ForegroundColor Green}

    #Check on each DC
    Write-Host "Letzte Logins an DCs:"
    foreach ($DC in $DCs){
        try{
            $tmpLogon = Get-ADUser -Identity $user -Server $DC -Properties *
            $LogonList += New-Object -Type PSObject -Property (@{
                "Server" = "$DC - "
             "Time" = $tmpLogon.LastLogon
            })
        }
        catch{$LogonList += "UNAVAILABLE"}
    }
    $LogonList = $LogonList | sort -Property Time
    foreach($Entry in $LogonList){
        if($Entry.Time){
            try{$Entry.Time = ConvertTime -TimeNT $Entry.Time}
            catch{}
        }
    }
    $LogonList | ft -HideTableHeaders
    NewLine
}