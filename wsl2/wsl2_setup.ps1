Set-Location (Split-Path $script:myInvocation.MyCommand.path -parent)
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
$path = Resolve-Path .\wsl2_after-reboot.ps1
$commnd = 'powershell -ExecutionPolicy Unrestricted -File ' + $path
New-ItemProperty -LiteralPath 'HKCU:Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name 'wsl2_after-reboot' -PropertyType 'String' -Value $commnd -force
Restart-Computer
