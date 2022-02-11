Set-Location (Split-Path $script:myInvocation.MyCommand.path -parent)
Invoke-WebRequest -UseBasicParsing -Uri http://aka.ms/wsl2kernelmsix64 -OutFile wsl_update_x64.msi
.\wsl_update_x64.msi
wsl --set-default-version 2
Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu2004.appx -UseBasicParsing
Add-AppxPackage -Path Ubuntu2004.appx
rm Ubuntu2004.appx
pause
rm .\wsl_update_x64.msi

# Setting msys2
mingw64 -c "sed -i -e '/db_home/c db_home: windows' /etc/nsswitch.conf"