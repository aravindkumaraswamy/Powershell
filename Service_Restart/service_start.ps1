$servers = Get-Content -Path ".\servers.txt"

foreach ($server in $servers)
{
pskill \\$server CcmExec
Get-Service -ComputerName $server -Name "CcmExec" | Stop-Service -WarningAction Ignore
Get-Service -ComputerName $server -Name "CcmExec" | Start-Service
Write-Host "Service restarted successfully.." -ForegroundColor Yellow
}