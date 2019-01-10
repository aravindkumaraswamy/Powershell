$servers = Get-Content -Path ".\servers.txt"

foreach ($server in $servers)
{
$status = (Get-Service -ComputerName $server -Name "CcmExec").StartType

if($status -eq "Disabled")
{
Try{
Set-Service -ComputerName $server -Name "CcmExec" -StartupType Automatic
Get-Service -ComputerName $server -Name "CcmExec" | Start-Service
Write-Host "Service started successfully.." -ForegroundColor Green
}
Catch{ $error[0]}
Try{
Get-Service -ComputerName $server -Name "CcmExec" | Select Name,DisplayName,Status,StartType | ft -AutoSize
}
catch {$error[0]}
}
else
{
Try{
pskill \\$server CcmExec
Get-Service -ComputerName $server -Name "CcmExec" | Stop-Service -WarningAction Ignore
Get-Service -ComputerName $server -Name "CcmExec" | Start-Service
Write-Host "Service restarted successfully.." -ForegroundColor Yellow
}
catch {$error[0]}
Try{
Get-Service -ComputerName $server -Name "CcmExec" | Select Name,DisplayName,Status,StartType | ft -AutoSize
}
catch {$error[0]}

}

}