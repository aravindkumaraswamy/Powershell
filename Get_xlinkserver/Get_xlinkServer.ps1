$servers = Get-Content "F:\PS-NAR\Scripts\Get_xlinkserver\servers.txt"

foreach ($server in $servers)
{
Get-Service -ComputerName $server | Where-Object{$_.Name -contains "SAPAdapterEngine0_64"} | Select MachineName,Name,Status | Export-Csv -Path "F:\PS-NAR\Scripts\Get_xlinkserver\SAPServers.csv" -NoTypeInformation -Append
} 


