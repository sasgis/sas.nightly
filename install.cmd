@ECHO OFF

SET WDIR=%~dp0

SET PATH=%systemroot%\system32;%WDIR%bin;%WDIR%bin\7zip;%WDIR%bin\curl;%PATH%
SET TEMP=%WDIR%tmp
SET TMP=%WDIR%tmp

cd %WDIR%

busybox.exe bash "%WDIR%script\install.sh" > "%WDIR%log\install.log" 2>&1
