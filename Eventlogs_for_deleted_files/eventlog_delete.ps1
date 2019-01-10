<# 
.SYNOPSIS
This script is to pull the event logs for the deleted files. The script can be copied over to the source server and run to get the output in a text file

.Description:
User can give the start and end time. The Script fetches the input and pull the event details of all the deleted files within the timeframe given

.INPUTS
$start time and $endtime

.PARAMETER
    Output File(s):
    ".\Eventlog_$((date).tostring(""yyyy-MM-dd"")).txt"
    

.NOTES
Author         :Sherajun Safira (NAR Wintel)
File Name      :eventlog_delete.ps1
Date           :10/21/2017
Requires       : Any version of PowerShell
Version        : 1.0.0 or greater

#>


$Start = Read-host "Please enter the Start Date in (mm/dd/yy hh:mm:ss)" 
$End = read-host "Please enter the End Date in (mm/dd/yy hh:mm:ss)"

Write-Host "Please wait while the events are being collected...this may take few minutes" -ForegroundColor Cyan

$allevent=Get-WinEvent -FilterHashtable @{logname='Security';ID='4663';StartTime=$Start;EndTime=$End}

$i = 0

foreach($event in $allevent)
{
$i++
Write-Progress -Activity 'Collecting the Eventlogs' -Status 'Once completed your result will be saved in a text file' -PercentComplete (($i / $allevent.count) * 100)
    if($event.message.Contains("DELETE"))
    {
    
        $event | fl | Out-File ".\Eventlog_output.txt" -Append
    }
 }
