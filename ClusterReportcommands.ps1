#To get the Nodes from Cluster

$VMNodes = Get-ClusterNode
$VMNodes.Name

#To get the total CPU allocated to VMs in a Node and #To get the total RAM of VMs in a Node

$VMs = Get-VM -ComputerName $Node;$VMCount = $VMs.Count;$vCPU = $VMs.ProcessorCount;$vCPUCount = 0;$vCPU | ForEach-Object {$vCPUCount += $_};$vmRAM = 0;$VMs = (Get-VM -ComputerName $Node).Name;foreach($VM in $VMs){$vminfo = Get-VM -Name $VM -ComputerName $Node;$RAM = $vminfo.MemoryAssigned;$vRAM = $RAM/1024MB;$vmRAM += $vRAM}
$vCPUCount,$vmRAM

#Logical Processors in a Node
$NodeName = (Get-VMHost $Node).Name
if($NodeName )
$LogicalProcessorCount = (Get-vmhost $Node).LogicalProcessorCount
$LogicalProcessorCount

#Total Memory of a Node
$TotalMem = (get-vmhostnumanode -ComputerName $Node).Memorytotal
$sum = 0
$TotalMem | ForEach-Object {$sum += $_}
$NodeTotalMemory = [math]::Round(($sum)/1024)
$NodeTotalMemory

#Available memory of a Node
$nodememory = (Get-WmiObject -ComputerName $Node Win32_PerfRawData_PerfOS_Memory).AvailableMBytes
$NodeAvailableMemory = [math]::Round(($nodememory)/1024)
$NodeAvailableMemory

#Count of total VMs in a node
$VMs = Get-VM -ComputerName $Node
$VMCount = $VMs.Count
$VMCount

#*********************************
#Available CPU = Logical CPU – Sum of CPU

$AvailableCPU = $LogicalProcessorCount-$vCPUCount

#Available Mem = Total Mem*0.9 – Sum of RAM

$AvailableMem = (($NodeTotalMemory)*0.9)-$vmRAM

#CPU Allocation % = Sum of CPU/ Logical CPU and apply % 

$CPUAllocation = ($vCPUCount/$LogicalProcessorCount).ToString("P")

#Mem Allocation % = Sum of RAM/ Total Mem and apply % 

$MemAllocation = ($vmRAM/$NodeTotalMemory).ToString("P")









