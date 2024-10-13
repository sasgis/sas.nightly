cd ..\..\

set ROOT=%CD%
set EMANAGER="%1%"

set BDS_VER=21.0

if %EMANAGER%=="EL" (goto el) else (goto me)

:el
echo "Debug build with EurekaLog"
set EROOT=%ROOT%\bin\eurekalog\%BDS_VER%
set ERES=%EROOT%\lib\Common
set ELIB=%EROOT%\lib\Win32\Release\Studio27
set EDEF=EUREKALOG;EUREKALOG_VER7
goto start

:me
echo "Debug build with madExcept"
set EROOT=%ROOT%\bin\madexcept\%BDS_VER%
set ERES=%EROOT%\lib
set ELIB=%EROOT%\lib
set EDEF=MADEXCEPT
goto start

:start

set BDS=%ROOT%\bin\delphi\%BDS_VER%
set PATH=%BDS%\bin;%EROOT%\bin;%PATH%
set LIB=%ROOT%\tmp\lib
set SRC=%ROOT%\tmp\src
set INC=%SRC%\includes
set SRCINC=%INC%;%INC%\RarProgressBar;%INC%\Fundamentals;%INC%\BerkeleyDB;%INC%\LibJpeg;%INC%\FreeImage;%INC%\LibPng;%INC%\Compatibility;%INC%\LibTiff;%INC%\Proj4

set CLIPPER2=%LIB%\clipper2\Delphi\Clipper2Lib
set GR32=%LIB%\graphics32\Source
set TBX=%LIB%\Toolbar2000\Source;%LIB%\TBX\Source;%LIB%\TBX\Source\Themes
set VSAGPS=%LIB%\vsagps\Public;%LIB%\vsagps\Runtime
set SYNEDIT=%LIB%\SynEdit\Source
set CCR=%LIB%\ccr-exif
set EWB=%LIB%\EmbeddedWB\source
set ALCINOE=%LIB%\Alcinoe-code\source
set PASCALSCRIPT=%LIB%\PascalScript\Source
set MORMOT=%LIB%\mORMot;%LIB%\mORMot\SQLite3

set IPATH=%ELIB%;%SRCINC%;%CLIPPER2%;%GR32%;%TBX%;%VSAGPS%;%SYNEDIT%;%CCR%;%EWB%;%ALCINOE%;%PASCALSCRIPT%;%MORMOT%
set UPATH=%BDS%\lib\win32\release;%IPATH%
set OPATH=%MORMOT%
set RPATH=%ERES%

cd %SRC%\Resources
call Build.Resources.cmd 

cd %SRC%

set ALIAS=Generics.Collections=System.Generics.Collections;Generics.Defaults=System.Generics.Defaults;WinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE
set NAMESPASE=System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;System;Xml;Data;Datasnap;Web;Soap;Winapi;VclTee;

dcc32.exe --no-config -B -TX.exe -A"%ALIAS%" -NS"%NAMESPASE%" -E".bin" -N".dcu" -M -GD -$O- -$W+ -$D+ -D"DEBUG;%EDEF%" -I"%IPATH%" -U"%UPATH%" -O"%OPATH%" -R"%RPATH%" --peosversion:5.0 --pesubsysversion:5.0 SASPlanet.dpr

@echo.

if %EMANAGER%=="EL" (
  ecc32.exe --el_ide=27 --el_mode=Delphi "--el_config=.\Tools\eurekalog\SASPlanet.eof" "--el_alter_exe=SASPlanet.dpr;.\.bin\SASPlanet.exe"
) else (
  madExceptPatch.exe ".\.bin\SASPlanet.exe" ".\Tools\madexcept\SASPlanet.mes"
)
