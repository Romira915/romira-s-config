Set-Location (Split-Path $script:myInvocation.MyCommand.path -parent)

& $env:USERPROFILE\scoop\shims\git.exe clone https://github.com/mzyy94/RictyDiminished-for-Powerline.git
Invoke-WebRequest -UseBasicParsing -Uri https://github.com/microsoft/cascadia-code/releases/download/v2102.25/CascadiaCode-2102.25.zip -OutFile CascadiaCode-2102.25.zip
Invoke-WebRequest -UseBasicParsing -Uri https://github.com/yuru7/PlemolJP/releases/download/v1.2.3/PlemolJP_NF_v1.2.3.zip -OutFile PlemolJP_NF_v1.2.3.zip


# Fonts install