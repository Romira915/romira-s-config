Set-Location (Split-Path $script:myInvocation.MyCommand.path -parent)
Invoke-WebRequest -UseBasicParsing -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi
.\wsl_update_x64.msi
wsl --install -d Ubuntu