#!/bin/bash -ex

work_dir=$1
work_type=$2

source "${work_dir}/script/config.sh"
source "${work_dir}/script/tools.sh"
source "${work_dir}/script/repositories.sh"

function do_build {
    
    work_platform=$1
    
    if [ $? -ne 0 ]; then
        echo -e "Error: Can't initialize scripts!"
        log_end
        exit $?
    fi

    pull_changes

    clear_tmp
    clear_sas_bin

    if [ $? -ne 0 ]; then
        echo -e "Error: Prepare steps failed!"
        log_end
        exit $?
    fi

    # Determine build type based on work_type
    local build_type
    if [ "$work_type" = "NIGHTLY" ]; then
        build_type="Nightly"
    elif [ "$work_type" = "RELEASE" ]; then
        build_type="Stable"
    else
        build_type="Test"
    fi

    prepare_version_info "$UpdateRev"
    prepare_build_info "1,$sas_date,$build_type,$UpdateRev,$UpdateNode,$ReqRev,$ReqNode"

    echo "x${work_platform}: Compiling release build..."
    compile_release
    clear_tmp

    echo "x${work_platform}: Compiling debug build..."
    compile_debug

    if [[ -f "$sas_bin_release_exe_file" && -f "$sas_bin_debug_exe_file" ]]; then
        
        compile_lang
        make_commits_log
        add_dlls
        add_data
        
        local sas_arch
        if [ $work_platform -eq 32 ]; then
            sas_arch="SAS.Planet.${build_type}.${sas_date}.${UpdateRev}.7z"
            ARCHIVE_32=$sas_arch
        else
            sas_arch="SAS.Planet.${build_type}.${sas_date}.${UpdateRev}.x${work_platform}.7z"
            ARCHIVE_64=$sas_arch
        fi
        
        echo "x${work_platform}: Creating archive: ${sas_arch}"
        make_archive "${sas_uploads}/${sas_arch}"
    else
        echo -e "x${work_platform}: Compile error! See Compile log for details."
        log_end
        exit 2 # Compilation error
    fi
}

function do_upload {

    if [ -f "${sas_uploads}/${ARCHIVE_32}" ] && [ -f "${sas_uploads}/${ARCHIVE_64}" ]; then
        
        # Bitbucket
        # A workspace on a Free plan does not support uploading or downloading files
        #echo "Uploading Nightly builds to Bitbucket..."
        #source "${work_dir}/script/upload-nightly-bitbucket.sh"
        #bitbucket_upload "${sas_uploads}" "${ARCHIVE_64}" >> "${upload_log}" 2>&1
        #bitbucket_upload "${sas_uploads}" "${ARCHIVE_32}" >> "${upload_log}" 2>&1
        
        # GitHub
        echo "Uploading Nightly builds to GitHub..."
        cd $sas_src
        if git rev-parse --quiet --verify "refs/tags/nightly" >/dev/null 2>&1; then
            source "${work_dir}/script/upload-nightly-github.sh"
            publish_nightly_release "${sas_uploads}/${ARCHIVE_32}" "${sas_uploads}/${ARCHIVE_64}" >> "${upload_log}" 2>&1
        else
            echo -e "Error: nightly tag not found!"
        fi
    else
        echo -e "Error: One or both archives not found!"
    fi
}

log_begin

create_folders

clear_logs
clear_uploads

do_build 32
do_build 64

if [ "$work_type" = "NIGHTLY" ]; then
  do_upload
fi

log_end 

