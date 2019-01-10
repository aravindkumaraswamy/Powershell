$array= @() 
$folder = Read-Host "Enter the Folder Path" 
Get-ChildItem -Recurse $folder | Where-Object { $_.PSIsContainer } | 
ForEach-Object { 
    $obj = New-Object PSObject  
     
     
    $Size = [Math]::Round((Get-ChildItem -Recurse $_.FullName | Measure-Object Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB, 2) 
        $obj |Add-Member -MemberType NoteProperty -Name "Path" $_.FullName 
         
        $obj |Add-Member -MemberType NoteProperty -Name "SizeMB" $Size 
        $obj |Add-Member -MemberType NoteProperty -Name "DateModified" $_.LastWritetime 
                $array +=$obj 
    } 
 
$array | select Path,SizeMB,DateModified  | export-csv -notypeinformation -delimiter '|' -path Foldersize.csv

#<
***To get the Files with Lastwrite time and length ***
$mb=@{Name=”MB”;Expression={($_.length/1MB)}}
$size = 1MB
Get-ChildItem C:\Temp -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddYears(-1)) -and ($_.Length -ge $size)}| Select-object FullName, LastWriteTime,$mb | export-csv -notypeinformation -delimiter '|' -path C:\Temp\FilesSize.csv>#