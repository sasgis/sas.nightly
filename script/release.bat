cd ..\..\

SET BDS_VER=21.0

SET ROOT=%CD%
SET BDS=%ROOT%\bin\delphi\%BDS_VER%
SET PATH=%BDS%\bin;%PATH%
SET LIB=%ROOT%\tmp\lib
SET SRC=%ROOT%\tmp\src

SET FASTCODE=%SRC%\Includes\FastCode;%SRC%\Includes\FastCode\Non.RTL
SET SRCINC=%SRC%\Includes;%SRC%\Includes\RarProgressBar;%SRC%\Includes\Fundamentals;%SRC%\Includes\FastMM;%SRC%\Includes\BerkeleyDB;%SRC%\Includes\LibJpeg;%SRC%\Includes\FreeImage;%SRC%\Includes\LibPng;%SRC%\Includes\Compatibility;%SRC%\Includes\LibTiff;%SRC%\Includes\Proj4;%FASTCODE%

SET CLIPPER2=%LIB%\clipper2\Delphi\Clipper2Lib
SET GR32=%LIB%\graphics32\Source
SET TBX=%LIB%\Toolbar2000\Source;%LIB%\TBX\Source;%LIB%\TBX\Source\Themes
SET VSAGPS=%LIB%\vsagps\Public;%LIB%\vsagps\Runtime
SET SYNEDIT=%LIB%\SynEdit\Source
SET CCR=%LIB%\ccr-exif
SET EWB=%LIB%\EmbeddedWB\source
SET ALCINOE=%LIB%\Alcinoe-code\source
SET PASCALSCRIPT=%LIB%\PascalScript\Source
SET MORMOT=%LIB%\mORMot;%LIB%\mORMot\SQLite3

SET IPATH=%SRCINC%;%CLIPPER2%;%GR32%;%TBX%;%VSAGPS%;%SYNEDIT%;%CCR%;%EWB%;%ALCINOE%;%PASCALSCRIPT%;%MORMOT%
SET UPATH=%BDS%\lib\win32\release;%IPATH%

cd %SRC%\Resources
call Build.Resources.cmd 

cd %SRC%

SET ALIAS=Generics.Collections=System.Generics.Collections;Generics.Defaults=System.Generics.Defaults;WinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE

SET NAMESPASE=System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;System;Xml;Data;Datasnap;Web;Soap;Winapi;VclTee;

DCC32.EXE --no-config -B SASPlanet.dpr -CG -TX.exe -A%ALIAS% -NS%NAMESPASE% -E".bin" -N".dcu" -D"RELEASE" -I%IPATH% -U%UPATH% -O%MORMOT% -$C- -$D- -$L- -$Y- 