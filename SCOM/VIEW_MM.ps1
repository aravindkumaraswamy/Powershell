<# 
.SYNOPSIS
This script is to View the Maintenance Mode for the servers monitored with SCOM

.Description:
User can give the input data in hta file and the Script fetches the input from hta and Sets Maintenance Mode for the servers given in the list except for the SCOM Management servers

.INPUTS
SCOM_MM.hta

.PARAMETER
    Output File(s):
    "SCOM_MM_Logs_yyyy-MM-dd_hhmmsstt" - Contains the log for the script run

.NOTES
Author         :Sherajun Safira (NAR Wintel)
File Name      :SCOM_MM.hta
Date           :05/04/2017
Requires       : Operations Manager Shell or Windows Powershell V3 or greater
Version        : 1.0.0


#>
Param([DateTime]$EndTime,[string]$Comment,[string]$filePath)
#declaring parameters from vbs

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Import-Module OperationsManager

$list = Get-Content $filePath

#1. function definition - Writelog -> creating logs
$OutputLog = “.\Logs\SCOM_MM_Logs_$((date).tostring(""yyyy-MM-dd_hhmmsstt"")).log"
function writelog
{
Param($logstring)
$dt = get-date -uformat "%D %r"
Add-Content -value "$dt : $logstring" -Path $OutputLog 
}

#2. Script to view the Maintenance mode for the servers given in the input
foreach ($server in $list)

{

Try{
     Write-Host "Viewing Maintenance mode for $server" -ForegroundColor Yellow  
     Get-SCOMMaintenanceMode -Instance (Get-SCOMClassInstance -DisplayName "$($server)*") | select-object User,StartTime,ScheduledEndTime,Comments | ft -AutoSize  
     Write-Host "Maintenance mode is shown in GMT time format. Please refer the Operations Console for viewing MM in server time format"
     }
     catch {
     writelog $error[0]
     }
     
  }