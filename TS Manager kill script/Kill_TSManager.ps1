##============================================
##  Script to kill "TSManager.exe" Process
##============================================

Function CheckPing
{
	param(
	[string]$Server
	)
	if ( Test-Connection -ComputerName $server -Count 2 -ErrorAction SilentlyContinue )
	{
		KillProcess $Server
	}
	Else
	{
		$Check = "Server not reachable"
		Write-Output "$nl $Server" | Out-file -filepath $outfile -append
		$Check | Out-file -filepath $outfile -append
		Continue;
	}
}

Function KillProcess
{
	param(
	[string]$Server
	)

	$Check = TASKKILL /S $Server /F  /IM TSManager.exe
	Write-Output "$nl $Server" | Out-file -filepath $outfile -append
	$Check | Out-file -filepath $outfile -append
}

##============================================

Cls;
$Outfile = "result.log"
$nl = [Environment]::NewLine

foreach($Server in gc("servers.txt"))
{
	Write-host "Working on Server... $Server"
	CheckPing $Server
}

##============================================