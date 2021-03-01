sudo dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
sudo dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
$commnd = 'powershell -ExecutionPolicy Unrestricted -File C:\Users\Yudai\workspace\setting\wsl2setup\wsl2_after-reboot.ps1'
New-ItemProperty -LiteralPath 'HKCU:Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name 'wsl2_after-reboot' -PropertyType 'String' -Value $commnd -force
Restart-Computer
