# Change First
$DriveLetter = "O"
$ConnectAFSDriveTask = "ConnectAzureFileShare_" + $DriveLetter

# Save the password so the drive will persist on reboot
<input the AFS Share Key cmd here>

function Test-Administrator {
    $User = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

$ScriptDirectory = $env:APPDATA + "\Intune"
# Check if directory already exists.
if (!(Get-Item -Path $ScriptDirectory)) {
    New-Item -Path $env:APPDATA -Name "Intune" -ItemType "directory"
}

# Logfile
$ScriptLogFilePath = $ScriptDirectory + "\ConnectAzureFileShare.log"

if (Test-Administrator) {
    # If running as administrator, create scheduled task as current user.
    Add-Content -Path $ScriptLogFilePath -Value ((Get-Date).ToString() + ": " + "Running as administrator.")

    $ScriptFilePath = $ScriptDirectory + "\ConnectAzureFileShare_" + $DriveLetter + ".ps1"

    $Script = '<input Azure File Share connection script between the ' '>'

    $Script | Out-File -FilePath $ScriptFilePath

    $PSexe = Join-Path $PSHOME "powershell.exe"
    $Arguments = "-file $($ScriptFilePath) -WindowStyle Hidden -ExecutionPolicy Bypass"
    $CurrentUser = (Get-CimInstance –ClassName Win32_ComputerSystem | Select-Object -expand UserName)
    $Action = New-ScheduledTaskAction -Execute $PSexe -Argument $Arguments
    $Principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance –ClassName Win32_ComputerSystem | Select-Object -expand UserName)
    $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $CurrentUser
    $Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal

    Register-ScheduledTask $ConnectAFSDriveTask -Input $Task
    Start-ScheduledTask $ConnectAFSDriveTask
}

Else {
    # Not running as administrator. Connecting directly with Azure script.
    Add-Content -Path $ScriptLogFilePath -Value ((Get-Date).ToString() + ": " + "Not running as administrator.")

    <input Azure File Share connection script>
}

If (Get-PSDrive -Name O) {
    Add-Content -Path $ScriptLogFilePath -Value ((Get-Date).ToString() + ": " + $DriveLetter + "-Drive mapped successfully.")
}

Else {
    Add-Content -Path $ScriptLogFilePath -Value ((Get-Date).ToString() + ": " + "Please verify installation.")
}
