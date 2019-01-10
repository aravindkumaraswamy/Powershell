<#This script scans Services- By Hari. 
   log file contain the Service Name, Account and Computer name
#>
$ErrorActionPreference = "SilentlyContinue"
get-content .\servers.txt | % { Get-CimInstance -Computer:$_ -Query "SELECT Name, StartName FROM Win32_Service WHERE StartName <> 'LocalSystem'" | ? { $_.StartName -notlike 'NT AUTHORITY*' -and $_.StartName -notlike 'NT SERVICE*' } | Select Name, StartName, PSComputerName } > servicesLog.csv
