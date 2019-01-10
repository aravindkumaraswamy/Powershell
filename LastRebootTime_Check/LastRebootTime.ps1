### Script to check the server status and the last reboot time

$serverlist = Get-Content .\Servers.txt
Foreach ($server in $serverlist)
{
if((Test-Connection -ComputerName $server -Count 4 -Quiet) -eq "True")
{
gwmi win32_operatingsystem -ComputerName $server | select csname, @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}
else
{
Write-Host "$server is down" -ForegroundColor Yellow
}
}