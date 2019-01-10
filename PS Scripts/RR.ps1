$csvdata=@(Import-Csv C:\Temp\Safie\RRpolicy.csv)

Foreach ($data in $csvdata)
{
$CurrentHostName = $data.HostName
$DatastoreName = $data.Datastore
$CanName = $data.CanonicalName

Get-VMHost -Datastore $DatastoreName -Name $CurrentHostName | Get-ScsiLun -CanonicalName $CanName |Set-ScsiLun -MultipathPolicy RoundRobin | fl
Write-Host "RR policy is set for $DatastoreName Successfully in $CurrentHostName" -foregroundcolor Green
}


#Get-VMHost -Datastore usalpr0000_usalp-c0002_oasis_ds01 -Name usalpu0002.ams.nestle.com | Get-ScsiLun -CanonicalName "naa.6000eb35eb67971a00000000000002f2" | fl