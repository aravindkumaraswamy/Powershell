
Import-Module ActiveDirectory

$Groups = Get-Content C:\Temp\Safie\Group.txt
Foreach ($Group in $Groups)
{
Try{
$a = Get-ADGroup -Identity "$Group" -ErrorAction SilentlyContinue
$a | Export-Csv -Path C:\Temp\Safie\result.csv -Append
}
Catch
{
Write-Host "$Group"
}
}
