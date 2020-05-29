#!/bin/bash -ex

proj_url=https://github.com/sasgis

proj_bin=$proj_url/sas.planet.bin
proj_src=$proj_url/sas.planet.src
proj_lib=$proj_url/sas.requires
proj_maps=$proj_url/sas.maps
proj_lang=$proj_url/sas.translate

tmp=$work_dir/tmp

sas_date=$(date "+%y%m%d")
sas_src=$tmp/src
sas_bin=$tmp/bin
sas_bin_release_2007_exe_file=$sas_bin/SASPlanet.NonUnicode.exe
sas_bin_debug_2007_exe_file=$sas_bin/SASPlanet.NonUnicode.Debug.exe
sas_bin_release_exe_file=$sas_bin/SASPlanet.exe
sas_bin_debug_exe_file=$sas_bin/SASPlanet.Debug.exe
sas_maps=$sas_bin/Maps/sas.maps
sas_lang=$tmp/lang
sas_lib=$tmp/lib

sas_version_info_path=$sas_src/Resources/Version
sas_version_info_file=Version.rc
sas_build_info_path=$sas_src/Resources/BuildInfo
sas_build_info_file=BuildInfo.csv
sas_uploads=$work_dir/upload

sas_eurekalog_pas=$sas_src/Tools/eurekalog/EurekaLog.pas

sas_log=$work_dir/log
log_date=$(date "+%Y-%m-%d %H-%M-%S")
cur_log_folder=$sas_log/$log_date

release_log=$cur_log_folder/Compile.Release.log
debug_log=$cur_log_folder/Compile.Debug.log
release_2007_log=$cur_log_folder/Compile.2007.Release.log
debug_2007_log=$cur_log_folder/Compile.2007.Debug.log
upload_log=$cur_log_folder/Upload.log

sas_exe_file=$sas_src/.bin/SASPlanet.exe
sas_map_file=$sas_src/.bin/SASPlanet.map
sas_dcu=$sas_src/.dcu

sas_ru_po=$sas_lang/ru.po
sas_fr_po=$sas_lang/fr.po
sas_uk_po=$sas_lang/uk.po
sas_es_po=$sas_lang/es.po

bin_ru_mo=$sas_bin/lang/ru.mo
bin_fr_mo=$sas_bin/lang/fr.mo
bin_uk_mo=$sas_bin/lang/uk.mo
bin_es_mo=$sas_bin/lang/es.mo
