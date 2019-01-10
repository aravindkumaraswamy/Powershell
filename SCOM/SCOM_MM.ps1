<# 
.SYNOPSIS
This script is to Set Maintenance Mode for the servers monitored with SCOM

.Description:
User can give the input data in hta file and the Script fetches the input from hta and Sets Maintenance Mode for the servers given in the list except for the SCOM Management servers

.INPUTS
SCOM_MM.hta

.PARAMETER
    Output File(s):
    "SCOM_MM_Logs_yyyy-MM-dd_hhmmsstt" - Contains the log for the script run

.NOTES
Author         :Sherajun Safira (NAR Wintel)
File Name      :SCOM_MM.ps1
Date           :11/11/2016
Requires       : Operations Manager Shell or Windows Powershell V3 or greater
Version        : 1.0.0


#>

Param([DateTime]$EndTime,[string]$Comment,[string]$filePath)
#decalring parameters from vbs

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Import-Module OperationsManager

$list = Get-Content $filepath

#1. function definition - Writelog -> creating logs
$OutputLog = “.\Logs\SCOM_MM_Logs_$((date).tostring(""yyyy-MM-dd_hhmmsstt"")).log"
function writelog
{
Param($logstring)
$dt = get-date -uformat "%D %r"
Add-Content -value "$dt : $logstring" -Path $OutputLog 
}

#To exclude SCOM Management servers from being set into Maintenance
writelog "========================SCRIPT STARTS================================="
writelog "Checking for Management servers in the input"
$scommanagementServers = (Get-SCOMManagementServer).displayName
foreach ($server in $list)
{
try{
$check = (Get-SCOMClassInstance -DisplayName "$($server)*") | select -first 1 | select -ExpandProperty Displayname 
}
catch {writelog $error[0]}
 for ($i=0; $i -lt $scommanagementServers.Length; $i++){
 
 if ($check -eq $scommanagementServers[$i])
 {
 $skip = $true
 Write-Host "SCOM Management server is present in the input. Maintenance Mode cannot be set for Management Server!!!" -ForegroundColor Yellow
 Write-Host "Script will continue if there are other servers given in the input" -ForegroundColor Green
 writelog "SCOM Management server is present in the input. Maintenance Mode cannot be set for Management Server!!!"
 writelog "Script will continue if there are other servers given in the input"
 }
 }

 #To set Maintenance for servers monitoring using SCOM
 if($skip -ne $true)
 {
 try{
$end = $EndTime
$start = Get-date -Format G
$a = New-TimeSpan -Start $start -End $end
$duration = $a.TotalMinutes
$Time = ((Get-Date).AddMinutes($duration))
}
catch {
writelog $error[0]}
 
    if(!(Get-SCOMMaintenanceMode -Instance (Get-SCOMClassInstance -DisplayName "$($server)*"))) 
    { 
      Write-Host "Setting Maintenance Mode for $server" -ForegroundColor Cyan
      writelog "Setting Maintenance Mode for $server"
      $serverClassIds = Get-SCOMClassInstance -DisplayName "$($server)*"
      foreach($classid in $serverClassIds) 
        { 
         try{
         $server1 = Get-SCOMClassInstance -id ($classid.id) | Where-Object{$_.DisplayName -match "$($server)*"} 
         }
         catch {
         writelog $error[0]
         }
         if(!(Get-SCOMMaintenanceMode -Instance $classid)) 
         {
         Try
         { 
          Start-SCOMMaintenanceMode -Instance $server1 -EndTime $Time -Reason PlannedOther -Comment $Comment -ErrorAction SilentlyContinue
         }
          catch {
          writelog $error[0]
          }
         }
        }
        Write-Host "Maintenance Mode has been set for the server $server upto $Time" -ForegroundColor Green
        writelog "Maintenance Mode has been set for the server $server upto $Time"
     
     Try{
     Get-SCOMMaintenanceMode -Instance (Get-SCOMClassInstance -DisplayName "$($server)*") | select-object User,StartTime,ScheduledEndTime | ft -AutoSize -ErrorAction SilentlyContinue
     }
     catch {
     writelog $error[0]
     }
     Write-Host "Maintenance mode is shown in GMT time format. Please refer the Operations Console for viewing MM in server time format"
    }
  
    else
    {
    Write-Host "The $server is already placed in Maintenance Mode" -ForegroundColor Yellow
    writelog "The $server is already placed in Maintenance Mode"
    try {
    Get-SCOMMaintenanceMode -Instance (Get-SCOMClassInstance -DisplayName "$($server)*") | select-object User,StartTime,ScheduledEndTime | ft -Autosize -ErrorAction SilentlyContinue
    Write-Host "Maintenance mode is shown in GMT time format. Please refer the Operations Console for viewing MM in server time format"
    }
    catch {
    writelog $error[0]
    }
    
    }
  }
  
 $skip = $false
 }
writelog "====================SCRIPT ENDS======================"