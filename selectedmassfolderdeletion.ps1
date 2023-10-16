#this script is to delete folders in a location from date A to date B
#you'll need to know how long ago the days were

$filepath = "<path>"
$fromdate = (Get-Date).AddDays(-27)
$todate = (Get-Date).AddDays(-26)

get-childitem -path $filepath | where-object {$_.LastWriteTime -gt $fromdate -and $_.LastWriteTime -lt $todate} | remove-item -force -recurse -confirm$false
