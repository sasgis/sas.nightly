#!/bin/bash -ex

function create_folders {

    if [ ! -d "$sas_uploads" ]; then
        mkdir "$sas_uploads"
    fi

    if [ ! -d "$sas_log" ]; then
        mkdir "$sas_log"
    fi

    if [ -d "$sas_log" ]; then
        if [ ! -d "$cur_log_folder" ]; then
            mkdir "$cur_log_folder"
        fi
    fi
}

function clear_tmp {

    rm -f $sas_exe_file
    rm -f $sas_map_file
    
    cd "$sas_bin/lang" && rm -f *.mo

    cd $sas_dcu && rm -f *.dcu
}

function clear_uploads {

    cd $sas_uploads && rm -v -f SAS.Planet.*.7z
}

function clear_logs {

    cd $sas_log && rm -f *.7z
}

function clear_sas_bin {

    rm -f $sas_bin_release_exe_file
    rm -f $sas_bin_debug_exe_file
    
    cd $sas_bin && rm -rfv *.dll
}

function prepare_version_info {

    cd $sas_version_info_path

    local vi_year=$(echo $(date +"%y") | awk '{ gsub("^0",""); print }')
    local vi_month=$(echo $(date +"%m") | awk '{ gsub("^0",""); print }')
    local vi_day=$(echo $(date +"%d") | awk '{ gsub("^0",""); print }')
    local vi_rev=$(echo $1 | awk '{ gsub("^0",""); print }')

    local version_info=$vi_year","$vi_month","$vi_day","$vi_rev
    local rc=$(sed -r -e "s/FILEVERSION (.*?)/FILEVERSION $version_info/" "$sas_version_info_file")
    echo "$rc" > "$sas_version_info_file"

    version_info=$vi_year"."$vi_month"."$vi_day"."$vi_rev
    rc=$(sed -r -e "s/VALUE \"FileVersion\", (.*?)/VALUE \"FileVersion\", \"$version_info\\\000\"/" "$sas_version_info_file")
    echo "$rc" > "$sas_version_info_file"
}

function prepare_build_info(){

    cd $sas_build_info_path
    echo "$1" > "$sas_build_info_file"
}

function patch_lib {

    sed -i "s/DEFINE SYN_DirectWrite/UNDEF SYN_DirectWrite/i" $sas_lib/SynEdit/Source/SynEdit.inc
}

function compile_project {

    patch_lib
    
    local bat=$work_dir/script/$1
    local log=$2
    local compiled_exe_name=$3
    local debug_em=$4
    
    cmd.exe /c "$bat $debug_em $work_platform" 2>&1 | tee "$log"
    
    if [ -f "$sas_exe_file" ]; then
        cp -f "$sas_exe_file" "$compiled_exe_name"
        # cp -f "$sas_map_file" "${compiled_exe_name/.exe/.map}"
        
        rm -f $sas_exe_file
        rm -f $sas_map_file
    fi
}

function compile_release {

    cd $sas_src
    compile_project "release.bat" "$release_log" "$sas_bin_release_exe_file" "RELEASE"
}

function compile_debug_el {

    cd $sas_src
    cp -f "$sas_eurekalog_pas" "$sas_src"
    sed -bi "s/^uses/uses u_EurekaLog,/i" "$sas_src/SASPlanet.dpr"
    compile_project "debug.bat" "$debug_log" "$sas_bin_debug_exe_file" "EL"
    
    sed -bi "s/^uses u_EurekaLog,/uses/i" "$sas_src/SASPlanet.dpr"
}

function compile_debug_me {

    cd $sas_src
    cp -f "$sas_madexcept_pas" "$sas_src"
    sed -bi "s/^uses/uses u_MadExcept,/i" "$sas_src/SASPlanet.dpr"
    compile_project "debug.bat" "$debug_log" "$sas_bin_debug_exe_file" "ME"
    
    sed -bi "s/^uses u_MadExcept,/uses/i" "$sas_src/SASPlanet.dpr"
}

function compile_debug {

    compile_debug_me
    #compile_debug_el
}

function make_commits_log {

    cd $sas_src
    git log > "$sas_bin/CommitsLog.txt"
}

function compile_lang {

    local lang_bin="$sas_bin/lang"
    
    if [ ! -d "${lang_bin}" ]; then
        mkdir "${lang_bin}"
    fi
    
    cd "${sas_lang}"
    
    PATH="${work_dir}/bin/gnugettext:$PATH"
    
    # do not surround $sas_langs with qoutes bellow!
    for lang in $sas_langs ; do
        echo "Compiling language file: ${lang}"
        msgfmt "${sas_lang}/${lang}.po" -o "${lang_bin}/${lang}.mo"
    done
}

function make_archive {

    cd $sas_bin
    7z a -t7z -mmt1 -mx9 -md=64m -mfb=273 -ms=on "$1" -r * -xr!".*"
}

function fetch_and_extract_dlls {

    local lib_zip=$1
    local lib_url=$2
    
    if [ ! -f $lib_zip ]; then
        curl --retry 3 -L $lib_url --output $lib_zip
    fi
    
    7z x -y $lib_zip -o"${sas_bin}"
}

function add_dlls_32 {

    local lib_ver lib_zip lib_url
    
    # common
    lib_ver="250505"
    lib_zip="common-win32-v${lib_ver}.zip"
    lib_url="https://github.com/sasgis/sas.planet.bin/releases/download/v.${lib_ver}/${lib_zip}"
    
    fetch_and_extract_dlls "${work_dir}/cache/${lib_zip}" $lib_url
    
    # libxp
    lib_ver="250505"
    lib_zip="libxp-win32-v${lib_ver}.zip"
    lib_url="https://github.com/sasgis/sas.planet.bin/releases/download/v.${lib_ver}/${lib_zip}"
    
    fetch_and_extract_dlls "${work_dir}/cache/${lib_zip}" $lib_url
    
    # lib32
    lib_ver="250505"
    lib_zip="lib32-lite-win32-v${lib_ver}.zip"
    lib_url="https://github.com/sasgis/sas.planet.bin/releases/download/v.${lib_ver}/${lib_zip}"
    
    fetch_and_extract_dlls "${work_dir}/cache/${lib_zip}" $lib_url
}

function add_dlls_64 {

    local lib_ver lib_zip lib_url
    
    # common
    lib_ver="250505"
    lib_zip="common-win64-v${lib_ver}.zip"
    lib_url="https://github.com/sasgis/sas.planet.bin/releases/download/v.${lib_ver}/${lib_zip}"
    
    fetch_and_extract_dlls "${work_dir}/cache/${lib_zip}" $lib_url
    
    # lib64
    lib_ver="250505"
    lib_zip="lib64-win64-v${lib_ver}.zip"
    lib_url="https://github.com/sasgis/sas.planet.bin/releases/download/v.${lib_ver}/${lib_zip}"
    
    fetch_and_extract_dlls "${work_dir}/cache/${lib_zip}" $lib_url
}

function add_dlls {
    
    if [ $work_platform -eq 64 ]; then
        add_dlls_64
    else
        add_dlls_32
    fi
}

function add_data {

    if [ -d "${work_dir}/data" ]; then
        cd "${work_dir}/data/common" && cp -prfv "./" "$sas_bin"
        cd "${work_dir}/data/win${work_platform}" && cp -prfv "./" "$sas_bin"
    fi
}

function log_begin {

    echo "Start at: $(date +"%Y-%m-%d %H:%M:%S")"
}

function log_end {

    echo "Finish at: $(date +"%Y-%m-%d %H:%M:%S")"

    cd $sas_log
    if [ -f "main.log" ]; then
        cp -f "main.log" "$cur_log_folder"
    fi
        
    7z a -t7z -ms=on "${cur_log_folder}_x${work_platform}.7z" -r "${cur_log_folder}/*"
        
    rm -rf "$cur_log_folder"
}
