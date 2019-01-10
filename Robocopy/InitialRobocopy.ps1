<# 
.SYNOPSIS
This script is to perform initial robocopy for folder migrations

.Description:
User can give the source and destination. The Script fetches the input and performs robocopy and send email to Team mailbox

.INPUTS
$source and $destination

.PARAMETER
    Output File(s):
    ".\Logs-InitialRobocopy.log"
    Email to amsna.itwintel.wipro@nestle.com 	

.NOTES
Author         :Sherajun Safira (NAR Wintel)
File Name      :Initial_Robocopy.ps1
Date           :05/11/2017
Requires       : Any version of PowerShell
Version        : 1.0.0 or greater

#>

#Give Source and Destination in the input

$source = (Read-Host "Enter the source path")
$destination = (Read-Host "Enter the destination path")
$TIMESTAMP = get-date -uformat "%Y-%m%-%d"
$LOGFILE = ".\"
$ROBOCOPYLOG = "/LOG:$LOGFILE`Logs-InitialRobocopy`.log"

##Sending Initial email     
$smtpServer = "smtp.ams.nestle.com" 
$smtpFrom = "amsna.itwintel.wipro@nestle.com" 
$smtpTo = "amsna.itwintel.wipro@nestle.com" 
$messageSubject = "Initial Robocopy Status Report" 
$message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto 
$message.Subject = $messageSubject 
$messageBody = "Initial Robocopy is in progress: `nSource: $source `nDestination: $destination. `nAn email with logs will be received once the robocopy completes"
$message.Body = $messageBody
$smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
$smtp.Send($message)


#Execution of Initial Copy
Robocopy $source $destination /E /COPY:DATS /XO /NP /R:1 /W:1 $ROBOCOPYLOG


##Sending Robocopy Status mail     
$smtpServer = "smtp.ams.nestle.com" 
$smtpFrom = "amsna.itwintel.wipro@nestle.com" 
$smtpTo = "amsna.itwintel.wipro@nestle.com" 
$messageSubject = "Initial Robocopy Status Report" 
$message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto 
$message.Subject = $messageSubject 
$logs = Get-Content ".\Logs-InitialRobocopy.log"
foreach ($log in $logs)
{
$message.Body = $message.Body + $log + "`n`r"
}
$smtp = New-Object Net.Mail.SmtpClient($smtpServer) 
$smtp.Send($message)

