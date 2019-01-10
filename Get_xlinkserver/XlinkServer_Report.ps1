<# 
.SYNOPSIS
This script is to pull the Memory,CPU, Disk space, SAP Adapter Engine and SQL service status for the xlink servers.

.Description:
User can give the input in servers.txt. The Script fetches the input and performs the check and provide the information in html report

.INPUTS
servers.txt

.PARAMETER
    Output File(s):
    XlinkServerReport.htm

.NOTES
Author         : (NAR Wintel)
File Name      : XlinkServer_Report.ps1
Date           : 01/02/2018
Requires       : Any version of PowerShell
Version        : 1.0.0 or greater

#>

$servers = Get-Content -Path .\servers.txt
$Result = @()
foreach ($server in $servers)
{

    $ServerStatus = ""
    $MemoryUtilization= ""
    $FreeMemory = ""
    $TotalGB = ""
    $FreeGB = ""
    $CPUUtilization = ""
    $DiskDetails = ""
    $SAPAdapterEngine = ""
    $sqlservice = ""

# Check if the server is reachable
 
 $Reply = Test-Connection -computername $server  -quiet -ErrorAction SilentlyContinue
 if($reply -eq $false) { $ServerStatus = "Not Reachable" } 
 else {$ServerStatus = "Online" }

 If($ServerStatus -eq "Online")
 {

#Memory Utilization and Details of RAM

$Memory = Get-WmiObject Win32_OperatingSystem -ComputerName $server
$UsedMemory = $Memory | Select CSName,@{Name = "MemoryUtilization"; Expression = {“{0:N2}” -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize) }}
$MemoryUtilization = $UsedMemory.MemoryUtilization+"%"
$FreeMemory = [math]::Round(($Memory.FreePhysicalMemory/$Memory.TotalVisibleMemorySize)*100,2)
$Total = $Memory | select @{Name = "TotalGB";Expression = {[int]($_.TotalVisibleMemorySize/1mb)}}
$TotalGB = $Total.TotalGB
$Free = $Memory | select @{Name = "FreeGB";Expression = {[math]::Round($_.FreePhysicalMemory/1mb,2)}}
$FreeGB = $Free.FreeGB


#CPU utlization in the remote server

$CPUValue = Get-WMIObject win32_processor -ComputerName $server  | select __Server, @{name="CPUStatus";expression ={“{0:N2}” -f(get-counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 2 -MaxSamples 5 | select -ExpandProperty countersamples | select -ExpandProperty cookedvalue | Measure-Object -Average).average}}
$CPUUtilization = $CPUValue.CPUStatus+"%"

#Disk Space Utilization

$disks = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" -ComputerName $server | Where-Object{$_.DriveType -eq 3}

foreach ($disk in $disks)
{
    if ($disk.Size -gt 0)
    {
        $size = [math]::round($disk.Size/1GB, 0)
        $free = [math]::round($disk.FreeSpace/1GB, 0)
        $TotalDiskSize = "$size GB" 
        $FreeDiskSize = "{0:N0}GB ({1:P0})" -f $free, ($free/$size)
     }
    $DiskDetails += "Drive:"+$disk.Name+"|"+"DriveName:"+$disk.VolumeName+"|"+"TotalDiskSize:"+$TotalDiskSize+"|"+"FreeDiskSize:"+$FreeDiskSize+"`n" 
            
        }

#Service Status - Xlink service

$sapstatus = Get-Service -ComputerName $server |Where-Object {$_.Name -contains 'SAPAdapterEngine0_64'}
if ($sapstatus)
{
$SAPAdapterEngine = $sapstatus.Status
}
else
{
$nosap = "No SAP service found"
$SAPAdapterEngine = $nosap
}

#Service Status - SQL services 

 $services=Get-Service -ComputerName $server *SQL* | ForEach-Object {if($_.Status -eq "Stopped"){$_.DisplayName + ";"+"`n"}}
if($services)
{$sqlservice = $services}
else
{
$sqlstatus = "No SQL instance Found"
$sqlservice = $sqlstatus }
}
# Hash table
   
$result += [PSCustomObject] @{  
        ServerName = "$server" 
        ServerStatus = $ServerStatus
        MemoryUtilization = $MemoryUtilization
        FreeMemory = $FreeMemory
        TotalGB_RAM = $TotalGB
        FreeGB_RAM = $FreeGB
        CPUUtilization = $CPUUtilization
        SAPAdapterEngine = $SAPAdapterEngine
        StoppedSQLServiceStatus = $sqlservice
        DiskDetails = $DiskDetails
                 
    } 

  #Convert the results into HTML
    $Outputreport = "<HTML><TITLE> XLink Server Resource Utilization Report </TITLE> 
                     <BODY background-color:goldenrod> 
                     <font color =""green"" face=""Microsoft Tai le""> 
                     <H4> XLink Server Resource Utilization Report </H4></font> 
                     <Table border=1 cellpadding=0 cellspacing=0> 
                     <TR bgcolor=lemonchiffon align=center> 
                       <TD><B>ServerName</B></TD> 
                       <TD><B>ServerStatus</B></TD>
                       <TD><B>MemoryUtilization</B></TD> 
                       <TD><B>FreeMemory</B></TD> 
                       <TD><B>TotalGB_RAM</B></TD> 
                       <TD><B>FreeGB_RAM</B></TD> 
                       <TD><B>CPUUtilization</B></TD>
                       <TD><B>SAPAdapterEngine</B></TD>
                       <TD><B>StoppedSQLServiceStatus</B></TD>
                       <TD><B>DiskDetails</B></TD>" 
                         
    Foreach($Entry in $Result)  
          {  
          if($Entry.ServerStatus -eq "Not Reachable")  
          {  
            $Outputreport += "<TR bgcolor=orange>"  
          }  
          else 
             { 
            $Outputreport += "<TR>"  
          } 
            $Outputreport += "<TD>$($Entry.Servername)</TD><TD align=center>$($Entry.ServerStatus)</TD><TD align=center>$($Entry.MemoryUtilization)</TD><TD align=center>$($Entry.FreeMemory)</TD><TD align=center>$($Entry.TotalGB_RAM)</TD><TD align=center>$($Entry.FreeGB_RAM)</TD><TD align=center>$($Entry.CPUUtilization)</TD><TD align=center>$($Entry.SAPAdapterEngine)</TD>><TD align=center>$($Entry.StoppedSQLServiceStatus)</TD><TD align=Left>$($Entry.DiskDetails)</TD></TR>"
          } 
            $Outputreport += "</Table></BODY></HTML>"  
          }
  
  
 
$Outputreport | out-file XlinkServerReport.htm