@ECHO OFF

SET WDIR=%~dp0
SET WTYPE=RELEASE
SET PATH=%WDIR%bin;%WDIR%bin\7zip;%WDIR%bin\curl;%PATH%
SET TEMP=%WDIR%tmp
SET TMP=%WDIR%tmp
SET HOME=%USERPROFILE%

cd %WDIR%

busybox.exe bash "%WDIR%script\main.sh" "%WDIR:~0,-1%" %WTYPE% 32 > "%WDIR%log\main.log" 2>&1

busybox.exe bash "%WDIR%script\main.sh" "%WDIR:~0,-1%" %WTYPE% 64 > "%WDIR%log\main.log" 2>&1