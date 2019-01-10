<#This script scans the Scheduled Tasks - By Hari. 
   Comma separated log file contain the Computername, Task name, UserID.
#>


$list =Get-Content servers.txt

$logfilepath = "TasksLog.csv"
#Remove-Item $Logfilepath
#$ErrorActionPreference = "SilentlyContinue"

foreach ($computername in $list)
{
    $path = "\\" + $computername + "\c$\Windows\System32\Tasks"
    $tasks = Get-ChildItem -Path $path -File

    if ($tasks)
    {
        Write-Verbose -Message "I found $($tasks.count) tasks for $computername"
    }

    foreach ($item in $tasks)
    {
        $AbsolutePath = $path + "\" + $item.Name
        $task = [xml] (Get-Content $AbsolutePath)
        [STRING]$check = $task.Task.Principals.Principal.UserId

        if ($task.Task.Principals.Principal.UserId)
        {
          Write-Verbose -Message "Writing the log file with values for $computername"           
          Add-content -path $logfilepath -Value "$computername,$item,$check"
        }

    }
}
