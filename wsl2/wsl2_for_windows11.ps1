Set-Location (Split-Path $script:myInvocation.MyCommand.path -parent)
Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu2004.appx -UseBasicParsing
Add-AppxPackage -Path Ubuntu2004.appx
rm Ubuntu2004.appx
pause