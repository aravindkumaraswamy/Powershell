
$a = $a = get-eventlog -LogName System | Where-Object {$_.EventID -eq 6008 -AND $_.timegenerated -gt (get-date).adddays(-30)}|select message
if(($a.Message.Count) -gt 2)
{
Write-Host "2"
}
else
{
Write-Host "0"
}
