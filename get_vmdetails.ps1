$Nodes = Get-Content -Path .\Nodes.txt
foreach ($Node in $Nodes)
{
Get-VMHost -Name "$Node" | Get-VM | Select-Object VMHost,Name,PowerState,NumCpu,MemoryGB | Export-Csv -Path .\VMdetails.csv -NoTypeInformation -Append
}