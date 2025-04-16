#!/bin/bash -ex

proj_url=https://github.com/sasgis

proj_bin=$proj_url/sas.planet.bin
proj_src=$proj_url/sas.planet.src
proj_lib=$proj_url/sas.requires
proj_lang=$proj_url/sas.translate

tmp=$work_dir/tmp

sas_date=$(date +"%y%m%d")
sas_src=$tmp/src
sas_bin=$tmp/bin
sas_bin_release_exe_file=$sas_bin/SASPlanet.exe
sas_bin_debug_exe_file=$sas_bin/SASPlanet.Debug.exe
sas_lang=$tmp/lang
sas_lib=$tmp/lib

sas_version_info_path=$sas_src/Resources/Version
sas_version_info_file=Version.rc
sas_build_info_path=$sas_src/Resources/BuildInfo
sas_build_info_file=BuildInfo.csv
sas_uploads=$work_dir/upload

sas_eurekalog_pas=$sas_src/Tools/Build/eurekalog/u_EurekaLog.pas
sas_madexcept_pas=$sas_src/Tools/Build/madexcept/u_MadExcept.pas

sas_log=$work_dir/log
log_date=$(date +"%Y-%m-%d_%H-%M-%S")
cur_log_folder=$sas_log/$log_date

release_log=$cur_log_folder/Compile.Release.log
debug_log=$cur_log_folder/Compile.Debug.log
upload_log=$cur_log_folder/Upload.log

sas_exe_file=$sas_src/.bin/SASPlanet.exe
sas_map_file=$sas_src/.bin/SASPlanet.map
sas_dcu=$sas_src/.dcu

# space-separated string of the language codes
sas_langs="es fa fr ru tr uk"
