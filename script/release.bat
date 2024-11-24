
:: ---------- Compiler version setup ----------

set BDS_VER=21.0

:: --------------------------------------------

cd ..\..\

set ROOT=%CD%
set NOTUSED="%1%"
set TARGET="%2%"

if %TARGET%=="64" (goto platform_x64) else (goto platform_x32)

:platform_x32
set PLATFORM=32
set DCC=dcc32.exe
goto platform_end

:platform_x64
set PLATFORM=64
set DCC=dcc64.exe
goto platform_end

:platform_end

set BDS=%ROOT%\bin\delphi\%BDS_VER%
set PATH=%BDS%\bin;%PATH%
set LIB=%ROOT%\tmp\lib
set SRC=%ROOT%\tmp\src

set FASTCODE=%SRC%\Includes\FastCode;%SRC%\Includes\FastCode\Non.RTL
set SRCINC=%SRC%\Includes;%SRC%\Includes\RarProgressBar;%SRC%\Includes\Fundamentals;%SRC%\Includes\FastMM;%SRC%\Includes\BerkeleyDB;%SRC%\Includes\LibJpeg;%SRC%\Includes\FreeImage;%SRC%\Includes\LibPng;%SRC%\Includes\Compatibility;%SRC%\Includes\LibTiff;%SRC%\Includes\Proj4;%FASTCODE%

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

set IPATH=%SRCINC%;%CLIPPER2%;%GR32%;%TBX%;%VSAGPS%;%SYNEDIT%;%CCR%;%EWB%;%ALCINOE%;%PASCALSCRIPT%;%MORMOT%
set UPATH=%BDS%\lib\win%PLATFORM%\release;%IPATH%

cd %SRC%\Resources
call Build.Resources.cmd 

cd %SRC%

set ALIAS=Generics.Collections=System.Generics.Collections;Generics.Defaults=System.Generics.Defaults;WinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE
set NAMESPASE=System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;System;Xml;Data;Datasnap;Web;Soap;Winapi;VclTee

%DCC% --no-config -B -CG -TX.exe -A"%ALIAS%" -NS"%NAMESPASE%" -E".bin" -N".dcu" -$C- -$D- -$L- -$Y- -D"RELEASE" -I"%IPATH%" -U"%UPATH%" -O"%MORMOT%" --peosversion:5.0 --pesubsysversion:5.0 SASPlanet.dpr
 