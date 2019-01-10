<# 
.SYNOPSIS
This script is replace the old master server name with the new server name in folders , subfolders and in files inside the folders

.Description:
User can give the input in console. The Script fetches the input and replaces the old master server name with the new master server name.

.INPUTS
Read-Host

.PARAMETER
    Output File(s): Powershell console

.NOTES
Author         : Sherajun Safira
File Name      : ServerName_Replacement.ps1
Date           : 02/27/2018
Requires       : Any version of PowerShell
Version        : 1.0.0 or greater

#>

$current = Read-Host "Please enter the Current server name"
$new = Read-Host "Please enter the New server name to be updated"
$filepath = Read-Host "Please enter the path name"
$Files = Get-ChildItem -Path $filepath -Recurse | Where-Object {$_.Name -match 'info*'}
$Files1 = Get-ChildItem -Path $filepath -Recurse | Where-Object {$_.Directory -match 'Catalog' -and $_.Name -match 'clients'}
$OASIS = "OASIS"
$oasisfile = Get-ChildItem -Path $filepath -Recurse | Where-Object {$_.Name.EndsWith($OASIS)}
$Files2 = Get-ChildItem -Path $oasisfile.PSPath | Where-Object {$_.Name -match 'clients'}

foreach ($File in $Files)
{
(Get-Content $File.PSPath) | ForEach-Object {$_ -replace "$current","$new"} | Set-Content $File.PsPath
Write-Host "Content has been replaced in" $File.PSPath -ForegroundColor Green
}

foreach ($File1 in $Files1)
{
(Get-Content $File1.PSPath) | ForEach-Object {$_ -replace "$current","$new"} | Set-Content $File1.PsPath
Write-Host "Content has been replaced in" $File1.PSPath -ForegroundColor Green
}

foreach ($File2 in $Files2)
{
(Get-Content $File2.PSPath) | ForEach-Object {$_ -replace "$current","$new"} | Set-Content $File2.PsPath
Write-Host "Content has been replaced in" $File2.PSPath -ForegroundColor Green
}

If(Get-ChildItem -Path "$filepath" -Filter "*$current*")
{
Get-ChildItem -Path "$filepath" -Filter "*$current*"| Rename-Item -NewName {$_.name -replace $current,$new}
Write-Host "Folder names inside $filepath have been replaced" -ForegroundColor Green
}
else
{
Write-Host "Folder names inside $filepath have not been replaced" -ForegroundColor Yellow
}
