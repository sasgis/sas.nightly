#!/bin/bash -ex

work_dir=$1
work_type=$2
work_platform=$3

. ./script/config.sh
. ./script/repositories.sh
. ./script/tools.sh
. ./script/bitbucket.sh

log_begin

if [ $? -ne 0 ]; then
    echo -e "Error: Can't initialize scripts!"
    log_end
    exit $?
fi

create_folders
pull_changes

clear_tmp
clear_sas_bin

if [ $? -ne 0 ]; then
    echo -e "Error: Prepare steps failed!"
    log_end
    exit $?
fi
    
if [ "$work_type" = "NIGHTLY" ]; then
    build_type="Nightly"
elif [ "$work_type" = "RELEASE" ]; then
    build_type="Stable"
else
    build_type="Test"
fi

prepare_version_info "$UpdateRev"
prepare_build_info "1,$sas_date,$build_type,$UpdateRev,$UpdateNode,$ReqRev,$ReqNode"

echo "Compiling release build..."
compile_release
clear_tmp

echo "Compiling debug build..."
compile_debug

if [[ -f "$sas_bin_release_exe_file" && -f "$sas_bin_debug_exe_file" ]]; then
    
    compile_lang
    make_commits_log
    add_dlls
    add_data
    
    sas_arch="SAS.Planet.${build_type}.${sas_date}.${UpdateRev}.x${work_platform}.7z"
    
    echo "Creating archive: ${sas_arch}"
    make_archive "${sas_uploads}/${sas_arch}"
  
    if [ "$work_type" = "NIGHTLY" ]; then

        if [ $work_platform -eq 32 ]; then 
            sas_upload="SAS.Planet.${build_type}.${sas_date}.${UpdateRev}.7z"
            echo "Prepare temporary archive: ${sas_upload}"
            cp -f -v "${sas_uploads}/${sas_arch}" "${sas_uploads}/${sas_upload}"
        else
            sas_upload=$sas_arch
        fi
        
        echo "Uploading Nightly build..."
        bitbucket_upload "${sas_uploads}" "${sas_upload}" >> "${upload_log}" 2>&1
        
        if [ $work_platform -eq 32 ]; then
            echo "Remove temporary archive: ${sas_upload}"
            rm -f -v "${sas_uploads}/${sas_upload}"
        fi
    fi
  
    log_end
    exit 1
else
    echo -e "Compile error! See Compile log for details."
    log_end
    exit 2
fi
    
