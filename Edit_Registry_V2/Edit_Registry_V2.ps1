<# 
.SYNOPSIS
This script is to delete the registry settings AUTHENTICATION_DOMAIN, USE_VXSS and Edit the Master server name in MultiString Value -Servers 

.Description:
User can give the input data in a excel file and the Script fetches the input from excel file and provides the output in the powershell console

.INPUTS
Input.csv

.PARAMETER
    Output File(s):

    Result will be displayed in the Powershell console
    

.NOTES
Author         :Aravind Kumarasamy (NAR Wintel)
File Name      :Edit_Registry_V2.ps1
Date           :09/20/2017
Requires       :Any version of PowerShell

#>


$csvdata=@(Import-Csv .\Input.csv)
$Computer="" 

Foreach ($data in $csvdata)
{
$Computer = $data.ComputerName
$Value1 = $data.MasterServer

If (test-connection -ComputerName $Computer -Count 1 -Quiet)
{
Try{

$session = New-PSSession -ComputerName $Computer

Invoke-Command -ComputerName $Computer -ArgumentList $Value1,$Computer -ScriptBlock{ 
Param ($Value1,$Computer)

If (Get-ItemProperty -Path 'HKLM:SOFTWARE\Veritas\NetBackup\CurrentVersion\Config' -Name 'AUTHENTICATION_DOMAIN' -ErrorAction SilentlyContinue)
{
Remove-ItemProperty -Path 'HKLM:SOFTWARE\Veritas\NetBackup\CurrentVersion\Config' -Name 'AUTHENTICATION_DOMAIN'
}
else
{
Write-Host "AUTHENTICATION DOMAIN property does not exist in $Computer" -ForegroundColor Yellow
}

If(Get-ItemProperty -Path 'HKLM:SOFTWARE\Veritas\NetBackup\CurrentVersion\Config' -Name 'USE_VXSS'-ErrorAction SilentlyContinue)
{
(Remove-ItemProperty -Path 'HKLM:SOFTWARE\Veritas\NetBackup\CurrentVersion\Config' -Name 'USE_VXSS')
}
else
{
Write-Host "USE_VXSS property does not exist for $Computer" -ForegroundColor Yellow
}

If(Get-ItemProperty -Path 'HKLM:SOFTWARE\Veritas\NetBackup\CurrentVersion\Config' -Name 'Server'-ErrorAction SilentlyContinue)
{
(Set-ItemProperty -Path 'HKLM:SOFTWARE\Veritas\NetBackup\CurrentVersion\Config' -Name 'Server' -Value $Value1.Split(';'))
Write-Host "Registry value edited successfully for $Computer" -ForegroundColor Green
}
else
{
Write-Host "Server property does not exist in $Computer" -ForegroundColor Yellow

}
}
}
catch {$Error[0]
}
Exit-PSSession
}

else
{
Write-Host "$Computer is not reachable" -ForegroundColor Yellow
}
}

