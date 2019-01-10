$Cluster = Read-Host "Please Enter the ClusterName"

$servers = Get-Cluster $Cluster | Get-VMHost


$result = @()
Foreach ($server in $servers)
{

$hbalist = Get-VMHostHba -VMHost $server
$Model = Get-VMHostHba -VMHost $server | Select-Object Model

 foreach($hba in $hbalist)
{
     
     $target = ((Get-View $hba.VMhost).Config.StorageDevice.ScsiTopology.Adapter | where {$_.Adapter -eq $hba.Key}).Target
     $luns = Get-ScsiLun -Hba $hba
     $nrPaths = ($target | %{$_.Lun.Count} | Measure-Object -Sum).Sum
     $hbamodel = $hba.Model

$obj = New-Object PSObject -Property @{
'Host' = $server
'HBAName' = $hba.Device
'HBAType' = $hba.Type
'Targets' = $target.Count
'Devices' = $luns.Count
'Paths' = $nrPaths
'Model' = $hbamodel
}


$obj = $obj | Select-Object Host,HBAName,HBAType,Targets,Devices,Paths,Model 
$result += $obj 
$result | Export-csv -path .\Output.csv -NoTypeInformation

}

}
Write-Host "The details are exported to Output.csv"