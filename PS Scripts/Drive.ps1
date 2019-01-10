$computerName = (Read-Host "Enter Computer Name")

gwmi -Class Win32_LogicalDisk -ComputerName $computerName | % {"Drive $($_.DeviceID) has " + "{0:N0}" -f($_.Freespace/1GB) + 'GB Free's}
