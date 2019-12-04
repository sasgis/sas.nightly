cd ..\..\

SET ROOT=%CD%
SET BDS=%ROOT%\bin\delphi\20.0
SET ECC=%ROOT%\bin\eurekalog
SET PATH=%BDS%\bin;%ECC%\bin;%PATH%
SET LIB=%ROOT%\tmp\lib
SET SRC=%ROOT%\tmp\src
SET ELOG=%ECC%\lib
SET SRCINC=%SRC%\Includes;%SRC%\Includes\RarProgressBar;%SRC%\Includes\Fundamentals;%SRC%\Includes\BerkeleyDB;%SRC%\Includes\LibJpeg;%SRC%\Includes\FreeImage;%SRC%\Includes\LibPng;%SRC%\Includes\Compatibility;%SRC%\Includes\LibTiff;%SRC%\Includes\Proj4

SET GR32=%LIB%\graphics32\Source
SET TBX=%LIB%\Toolbar2000\Source;%LIB%\TBX\Source;%LIB%\TBX\Source\Themes
SET VSAGPS=%LIB%\vsagps\Public;%LIB%\vsagps\Runtime
SET SYNEDIT=%LIB%\SynEdit\Source
SET CCR=%LIB%\ccr-exif
SET EWB=%LIB%\EmbeddedWB\source
SET ALCINOE=%LIB%\alcinoe-code\source
SET PASCALSCRIPT=%LIB%\PascalScript\Source
SET MORMOT=%LIB%\mORMot;%LIB%\mORMot\SQLite3

SET IPATH=%ELOG%;%SRCINC%;%GR32%;%TBX%;%VSAGPS%;%SYNEDIT%;%CCR%;%EWB%;%ALCINOE%;%PASCALSCRIPT%;%MORMOT%
SET UPATH=%BDS%\lib\win32\release;%IPATH%

cd %SRC%\Resources
call Build.Resources.cmd 

cd %SRC%

SET ALIAS=Generics.Collections=System.Generics.Collections;Generics.Defaults=System.Generics.Defaults;WinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE

SET NAMESPASE=System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;System;Xml;Data;Datasnap;Web;Soap;Winapi;

DCC32.EXE --no-config -B -TX.exe -A%ALIAS% -NS%NAMESPASE% -E".bin" -N".dcu" -GD -D"DEBUG;EUREKALOG;EUREKALOG_VER6" -I%IPATH% -U%UPATH% -O%MORMOT% SASPlanet.dpr
@echo.
ECC32.EXE --el_config"Tools\eurekalog\SASPlanet.eof" --el_alter_exe"SASPlanet.dpr"
