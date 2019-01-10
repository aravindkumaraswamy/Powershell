$computer = Read-Host ("Enter the computerName ")
Get-WmiObject win32_processor -ComputerName $computer | select-object SystemName,LoadPercentage,NumberOfLogicalProcessors,NumberOfCores,Status | Format-List
