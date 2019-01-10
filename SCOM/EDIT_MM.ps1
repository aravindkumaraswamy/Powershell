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
writelog "Checking for Active Maintenance mode entries of the server"

 try{
$end = $EndTime
$start = Get-date -Format G
$a = New-TimeSpan -Start $start -End $end
$duration = $a.TotalMinutes
$Time = ((Get-Date).AddMinutes($duration))
}
catch {
writelog $error[0]}
 foreach ($server in $list)
 {
    if(Get-SCOMClassInstance -DisplayName "$($server)*" | Where-object {$_.InMaintenanceMode -like "True"}) 
    { 
      Write-Host "Setting Maintenance Mode for $server" -ForegroundColor Cyan
      writelog "Active MM entries found..Editing Maintenance Mode for $server"
      $serverClassIds = Get-SCOMClassInstance -DisplayName "$($server)*"
      foreach($classid in $serverClassIds) 
        { 
         try{
         $server1 = Get-SCOMClassInstance -id ($classid.id) | Where-Object{$_.DisplayName -match "$($server)*"}
         $MMEntry = Get-SCOMMaintenanceMode -Instance $server1 -ErrorAction SilentlyContinue
         }
         catch {
         writelog $error[0]
         } 
         
         Try
         { 
          Set-SCOMMaintenanceMode -MaintenanceModeEntry $MMEntry -EndTime $Time -Comment $Comment -ErrorAction SilentlyContinue
          }
          #Writelog "Setting Maintenance Mode for the server $server"
         
          catch {
          writelog $error[0]
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
    Write-Host "There is no active Maintenance Mode found for $server. Hence Maintenance cannot be edited" -ForegroundColor Yellow
    writelog "There is no active Maintenance Mode found for $server. Hence Maintenance cannot be edited"  
    }
  }
   
writelog "====================SCRIPT ENDS======================"