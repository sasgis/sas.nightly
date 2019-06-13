@ECHO OFF

SET WDIR=%~dp0

SET WTYPE=NIGHTLY
SET PATH=%systemroot%\system32;%WDIR%bin;%WDIR%bin\7zip;%WDIR%bin\curl;%PATH%
SET TEMP=%WDIR%tmp
SET TMP=%WDIR%tmp

cd %WDIR%

busybox.exe bash "%WDIR%script\main.sh" "%WDIR:~0,-1%" %WTYPE% > "%WDIR%log\main.log" 2>&1
