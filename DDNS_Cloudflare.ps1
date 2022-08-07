Invoke-RestMethod -uri "https://ifconfig.io/ip" | Set-Content -Path "YourPath\querried_ip.txt"
$LastIP = ((gc "YourPath\last_ip.txt") | ? {$_.trim() -ne "" })
$QuerriedIP = ((gc "YourPath\querried_ip.txt") | ? {$_.trim() -ne "" })

if ($LastIPHome -ne $QuerriedIPHome){
    Set-Content -Path "YourPath\last_ip.txt" -Value $QuerriedIP
    $hostname = "hostname.your.domain"
    $zoneid = "Your_Zone_ID"
    $token = "Your_Token"
    $url = "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records" 

    # Fetch the record information
    $record_data = Invoke-RestMethod -Method get -Uri "$url/?name=$hostname" -Headers @{
    "Authorization" = "Bearer $token"
    } 

    # Modify the IP from the fetched record
    $record_ID = $record_data.result[0].id
    $record_data.result[0].content = Invoke-RestMethod -uri "YourPath\querried_ip.txt"

    $body = $record_data.result[0] | ConvertTo-Json

    # Update the record
    $result = Invoke-RestMethod -Method put -Uri "$url/$record_ID" -Headers @{"Authorization" = "Bearer $token"} -Body $body -ContentType "application/json"
    Add-Content -Path "YourPath\log.log" -Value "$(Get-Date -Format yyyy/dd/MM-HH:mm:ss) DNS Record updated to $($QuerriedIPHome)"
}