<# 
.SYNOPSIS
This script is to find if Hyperthreading is enabled for the nodes.

.Description:
User can give the input in Clusters.txt. The Script fetches the input and performs the check and provide the information in csv report

.INPUTS
Clusters.txt

.PARAMETER
    Output File(s):
    Output.csv

.NOTES
File Name      : HyperThreading.ps1
Date           : 05/10/2018
#>



$Clusters = Get-Content -Path .\Clusters.txt
foreach ($Cluster in $Clusters)
{
$Nodes = (Get-Cluster -Name $Cluster | Get-ClusterNode).Name
   foreach ($Node in $Nodes)
   {
   $data1 = (Get-WmiObject –class Win32_processor).NumberOfCores

   $data2 = (Get-WmiObject –class Win32_processor).NumberOfLogicalProcessors

   if($data1 -eq $data2)
   {
   $Hyperthreading = "Disabled"
   }
   else
   {
   $Hyperthreading = "Enabled"
   }

   $result = New-Object -Type PSObject -Property @{
   ClusterName = $Cluster
   HyperVNodeName = $Node
   No_of_Cores = $data1
   No_of_Logical_processors = $data2
   Hyperthreading = $Hyperthreading
   } | select-object ClusterName,HyperVNodeName,No_of_Cores,No_of_Logical_processors,Hyperthreading
   $result | Export-csv .\Output.csv -notypeinformation -append
}
}