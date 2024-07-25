<# 
.SYNOPSIS
This script is to check the freespace in the drives for multiple servers

.Description:
User can give the input data in a text file and the Script fetches the input from text file and provides the output in html

.INPUTS
servers.txt

.PARAMETER
    Output File(s):
    "results.html"

.NOTES
Author         : Aravind Kumarasamy (NAR Wintel)
File Name      :DiskSpace_Check.ps1
Date           :03/29/2023
Requires       :Any version of PowerShell

#>

$servers = Get-Content ./servers.txt

$results = foreach ($server in $servers)
{

$disks = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" -ComputerName $server | Where-Object{$_.DriveType -eq 3}

foreach ($disk in $disks)
{
    if ($disk.Size -gt 0)
    {
        $size = [math]::round($disk.Size/1GB, 0)
        $free = [math]::round($disk.FreeSpace/1GB, 0)
        [PSCustomObject]@{
            Server = $server
            Drive = $disk.Name
            Name = $disk.VolumeName
            "Total Disk Size" = "$size GB" 
            "Free Disk Size" = "{0:N0}GB ({1:P0})" -f $free, ($free/$size)
        }
    }
}
}

$Head = @'
<style type="text/css">
body {
 background-color:#FFFFFF;
 font-family: Verdana, Tahoma, "Times New Roman", Arial, Helvetica, sans-serif;
 font-size:10pt;
}

table td, th {
 border:0px solid black;
 border-collapse:collapse;
 border-bottom: 1px grey solid;
}

th {
 color:black;
 background-color:#c0f7f9;
}

table, tr, td, th { padding: 5px; margin: 0px;}
table tr:nth-child(odd){ background: lightgray; }
table { margin-left:25px; color:black; text-align:left; }
.danger {background-color: red}
.warn {background-color: yellow}
</style>
<title>Space Check</title>
<h3><font color=blue>Space Check Report</font></h3>
'@

$results | Select Server,Drive,Name,"Total Disk Size","Free Disk Size" | ConvertTo-Html -Head $Head | Out-file "results.html"
