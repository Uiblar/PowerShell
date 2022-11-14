#Array of all DCs, FQDN will have better performance
$DCs = @(
	"DC-00004",
	"DC-00005",
	"DC-00006",
	"DC-00007",
	"DC-00008",
	"DC-00009",
	"DC-00010",
	"DC-00011"
)
Function ConvertTime{
    Param([Parameter(Mandatory)]$TimeNT)
    Process{
    $LocalZone = [System.TimeZoneInfo]::Local
    $Date = ([System.TimeZoneInfo]::ConvertTimeFromUtc(([DateTime]::FromFileTimeUTC($TimeNT)),$LocalZone))
    get-date $Date -Format "dd.MM.yyyy HH:mm:ss"
    }
}
Function NewLine{
	Write-Host "`n"
}
while($true){
    $LogonList = @()
    $user = ""
    #Get User
    while($user.length -eq 0){$user = Read-Host "Bitte Kürzel eingeben";NewLine}
    $ADUser = Get-ADUser -identity $user -Properties *
    #Check Last PW Change
    Write-Host "Letzter Passwortwechsel: $(ConvertTime -TimeNT $ADUser.pwdLastSet)"
    Write-Host "Letzter fehlgeschlagener Login: $(get-date $ADUser.LastBadPasswordAttempt -Format "dd.MM.yyyy HH:mm:ss")"
    #Check Account Lockout Status
    if ($ADUser.lockedout) {"Konto gesperrt"}
    else {"Konto nicht gesperrt"}
    #Check Account Active
    if ($ADUser.enabled) {"Konto aktiv"}
    else {"Konto deaktiviert"}
    #Check PW Life
    if ($ADUser.passwordexpired) {"Passwort abgelaufen"}
    else {"Passwort nicht abgelaufen"}
    #Return DN
    "Account befindet sich in OU: $($ADuser.DistinguishedName)"
    #Check on each DC
    foreach ($DC in $DCs){
        $tmpLogon = Get-ADUser -Identity $user -Server $DC -Properties *
        $LogonList += New-Object -Type PSObject -Property (@{
            "Server" = "$DC - "
            "Time" = $tmpLogon.LastLogon
        })
    }
    $LogonList = $LogonList | sort -Property Time
    foreach($Entry in $LogonList){
        $Entry.Time = ConvertTime -TimeNT $Entry.Time
    }
    Write-Host "Letzte Logins an DCs"
    $LogonList | ft -HideTableHeaders
    NewLine
}