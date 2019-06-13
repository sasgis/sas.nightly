#!/bin/bash -ex

# initialize

work_dir=$1
work_type=$2

. ./script/config.sh
. ./script/repositories.sh
. ./script/tools.sh
. ./script/bintray.sh

log_begin

if [ $? -ne 0 ]; then
    echo -e "Error: Cant't initialize Helper"
    log_end
    exit 2
fi

# Prepare self folders
create_folders

# Update repositories
pull_changes

# Clear all tempary data
clear_tmp
clear_sas_bin

if [ $? -eq 0 ]; then
    if [ "$work_type" = "NIGHTLY" ]; then
        if [ "$LocalRev" -eq "$UpdateRev" ]; then
            echo -e "Hint: No updates found\n"
        else
            prepare_version_info "$UpdateRev"
            prepare_build_info "1,$sas_date,Nightly,$UpdateRev,$UpdateNode,$ReqRev,$ReqNode"
            compile_release
            clear_tmp
            compile_debug
            if [[ -f "$sas_bin_release_exe_file" && -f "$sas_bin_debug_exe_file" ]]; then
              compile_lang
              make_commits_log
              sas_arch="${sas_uploads}/SAS.Planet.Nightly.${sas_date}.${UpdateRev}.7z"
              make_archive "$sas_arch"
              bintray_upload "$sas_arch" "SAS.Planet.Nightly.$sas_date.$UpdateRev.7z" "$sas_date.$UpdateRev" >> "$upload_log" 2>&1
              log_end
              exit 1
            else
              echo -e "Compile error! For details see compile log."
              log_end
              exit 2
            fi
        fi
    else
        if [ "$work_type" = "RELEASE" ]; then
            prepare_version_info "$UpdateRev"
            prepare_build_info "1,$sas_date,Stable,$UpdateRev,$UpdateNode,$ReqRev,$ReqNode"
            compile_release
            clear_tmp
            compile_debug
            if [[ -f "$sas_bin_debug_exe_file" && -f "$sas_bin_release_exe_file" ]]; then
              compile_lang
              make_commits_log
              make_archive "${sas_uploads}/SAS.Planet.${sas_date}.7z"
              log_end
              exit 1
            else
              echo -e "Compile error! For details see compile log."
              log_end
              exit 2
            fi
        fi
    fi
fi

log_end

exit $?
