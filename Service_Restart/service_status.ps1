$servers = Get-Content -Path .\servers.txt
foreach ($server in $servers)
{
Try
{
Get-Service -ComputerName $server -Name "CcmExec" | Select MachineName,Name,DisplayName,Status,StartType | ft -AutoSize
}
catch {$error[0]}
}