#############################################################################

#                                                                           #

#  Perform Basic Health Check on list of servers                            #

#  and send an HTML report as the body of an email                          #

#  -Version 2.0 By Hari and Lenin                                           #

#   -Version 2.1 Safira                                                                        #

#############################################################################


$ServerListFile = "ServerList.txt" 
$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue 
$port = 3389  #RDP Port
$Result = @()  # Hash Table
$WMITimeout = 30           #Timeout after 30 seconds
$HealthStatus=@{"0"="Unknown";"5"="OK";"10"="Degraded";"15"="Minor";"20"="major";"25"="Critical";"30"="Non-Recoverable"}

ForEach($computername in $ServerList)  
{ 
    $ServerStatus = ""
    $RDPStatus= ""
    $services = ""
    $HW_Health = ""
    $LastReboot = ""
     
    
 
 # Check if the server is reachable
 
 $Reply = Test-Connection -computername $computername  -quiet
 if($reply -eq $false) { $ServerStatus = "Not Reachable" } else {$ServerStatus = "Online" }

 If ($Serverstatus -eq "Online")
  {
  $wmi_compsystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computername

 # Check if the server is Physical or virtual
  
  if (($wmi_compsystem.Manufacturer -eq "HP") -or ($wmi_compsystem.Manufacturer -like "Hewlett*")) 
 {   
 
 # Checking for Overall server health status including Array Battery and Memory status

 $HS = (Start-Job -ScriptBlock {Get-WmiObject -namespace root/HPQ -Class HP_WinComputerSystem -ComputerName $args[0] –ErrorAction SilentlyContinue} -ArgumentList $Computername|Wait-Job –Timeout $WMITimeout|Receive-Job).HealthState
 $HW_Health = $HealthStatus."$HS"
 if (-not $HS) {$HW_Health = "WMI Timeout"}
 }

 if ($wmi_compsystem.Manufacturer -like "VMware*")
 {
  $HW_Health = $wmi_compsystem.Model
 }
 
 # To get the automatic start-up type services that are stopped (filtering the services which does not require monitoring)

 $services = get-wmiobject -Computer $Computername -query "Select * from win32_service where startmode='auto' AND state !='running'" | select DisplayName
 $services = $services | % { if ($_ -notmatch 'NetBackup' -and $_ -notmatch 'Microsoft .NET' -and $_ -notmatch 'Software Protection') {$_.Displayname + "; "} }

 
 #Check RDP Status

 $socket = new-object System.Net.Sockets.TcpClient($computername,$port)
 If($socket.Connected)
 {
 $RDPStatus= "OK"
 $socket.Close() 
 }
 else
 {
  $RDPStatus= "Failed"
 If (($computername.Substring(5,1) -eq 'u') -or ($computername.Substring(5,1) -eq 'U')) {$RDPStatus = "ESX Host"}
 If (($computername.Substring(5,1) -eq 'r') -or ($computername.Substring(5,1) -eq 'R')) {$RDPStatus = "Store Virtual"}
 }
    
#Last Reboot Time

$LastBootUpTime = Get-WmiObject Win32_OperatingSystem -Computer $computername | Select -Exp LastBootUpTime
$LastReboot =  [System.Management.ManagementDateTimeConverter]::ToDateTime($LastBootUpTime)

}


#disk space report



$disks = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" -ComputerName $computername |Where-Object{$_.DriveType -eq 3}
$DiskDetails = ""
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
  



# Build hash table
   
$result += [PSCustomObject] @{  
        ServerName = "$computername" 
        ServerStatus = $ServerStatus
        RDP = $RDPStatus
        HardwareStatus = $HW_Health
        ServicesStopped = $services
        LastReboot = $LastReboot
        DiskDetails = $DiskDetails
                 
    } 
 
 #Convert the results into HTML
    $Outputreport = "<HTML><TITLE> Server Health Check Report </TITLE> 
                     <BODY background-color:peachpuff> 
                     <font color =""#99000"" face=""Microsoft Tai le""> 
                     <H4> Server Health Check Report </H4></font> 
                     <Table border=1 cellpadding=0 cellspacing=0> 
                     <TR bgcolor=lightblue align=center> 
                       <TD><B>ServerName</B></TD> 
                       <TD><B>ServerStatus</B></TD> 
                       <TD><B>RDP</B></TD> 
                       <TD><B>HardwareStatus</B></TD> 
                       <TD><B>ServicesStopped</B></TD> 
                       <TD><B>LastReboot</B></TD>
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
            $Outputreport += "<TD>$($Entry.Servername)</TD><TD align=center>$($Entry.ServerStatus)</TD><TD align=center>$($Entry.RDP)</TD><TD align=center>$($Entry.HardwareStatus)</TD><TD align=center>$($Entry.Servicesstopped)</TD><TD align=center>$($Entry.LastReboot)</TD><TD align=Left>$($Entry.DiskDetails)</TD></TR>" 
          } 
            $Outputreport += "</Table></BODY></HTML>"  
          }
           
  
 
$Outputreport | out-file HealthCheckReport.htm
#Invoke-Expression HealthCheckReport.htm
 
###Sending HealthCheck Report Email     
$smtpServer = "smtp.ams.nestle.com" 
$smtpFrom = "amsna.itwintel.wipro@nestle.com" 
$smtpTo = "amsna.itwintel.wipro@nestle.com" 
$messageSubject = "Servers Health Check Report" 
$message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto 
$message.Subject = $messageSubject 
$message.IsBodyHTML = $true 
$message.Body = "<head><pre>$style</pre></head>" 
$message.Body += Get-Content HealthCheckReport.htm 
$smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
$smtp.Send($message)