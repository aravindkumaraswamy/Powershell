
$computerName = (Read-Host "Enter Computer Name")

gwmi -Class Win32_LogicalDisk -ComputerName $computerName | % {"Drive $($_.DeviceID) has $($_.Freespace/1GB) GB Free"}

