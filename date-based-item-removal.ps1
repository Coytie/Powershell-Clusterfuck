$Path = "C:\Temp\" -- Change Location
$Daysback = "-31" -- Change Days Ago
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item
