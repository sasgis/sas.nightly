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
    
    rm -f $bin_ru_mo
    rm -f $bin_fr_mo
    rm -f $bin_uk_mo
    rm -f $bin_es_mo
    rm -f $bin_tr_mo
    
    cd $sas_uploads
    rm -f *.7z
    
    cd $sas_dcu
    rm -f *.dcu
    
    cd $sas_log
    rm -f *.7z
}

function clear_sas_bin {

    rm -f $sas_bin_release_exe_file
    rm -f $sas_bin_debug_exe_file
    rm -f $sas_bin_release_2007_exe_file
    rm -f $sas_bin_debug_2007_exe_file
    
    cd $sas_bin
    rm -rfv *.dll
}

function prepare_version_info {

    cd $sas_version_info_path

    local vi_year=$(echo $(date "+%y") | awk '{ gsub("^0",""); print }')
    local vi_month=$(echo $(date "+%m") | awk '{ gsub("^0",""); print }')
    local vi_day=$(echo $(date "+%d") | awk '{ gsub("^0",""); print }')
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
    
    cmd.exe /c "$bat" > "$log" 2>&1
    
    if [ -f "$sas_exe_file" ]; then
        cp -u -f "$sas_exe_file" "$compiled_exe_name"
        rm -f $sas_exe_file
        rm -f $sas_map_file
    fi
}

function compile_release {

    cd $sas_src
    compile_project "release.bat" "$release_log" "$sas_bin_release_exe_file"    
}

function compile_debug {

    cd $sas_src
    cp -f "$sas_eurekalog_pas" "$sas_src"
    sed -bi "s/^uses/uses EurekaLog,/i" "$sas_src/SASPlanet.dpr"
    compile_project "debug.bat" "$debug_log" "$sas_bin_debug_exe_file"
    
    sed -bi "s/^uses EurekaLog,/uses/i" "$sas_src/SASPlanet.dpr"
}

function make_commits_log {

    cd $sas_src
    git log > "$sas_bin/CommitsLog.txt"
}

function compile_lang {

    if [ ! -d "$sas_bin/lang" ]; then
        mkdir "$sas_bin/lang"
    fi
    
    cd $sas_lang
    
    PATH="$work_dir/bin/gnugettext:$PATH"

    msgfmt "$sas_ru_po" -o "$bin_ru_mo"
    msgfmt "$sas_fr_po" -o "$bin_fr_mo"
    msgfmt "$sas_uk_po" -o "$bin_uk_mo"
    msgfmt "$sas_es_po" -o "$bin_es_mo"
    msgfmt "$sas_tr_po" -o "$bin_tr_mo"
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

function add_dlls {

    local lib_ver lib_zip lib_url
    
    # common
    lib_ver="240219"
    lib_zip="common-win32-v${lib_ver}.7z"
    lib_url="https://github.com/sasgis/sas.planet.bin/releases/download/v.${lib_ver}-lib/${lib_zip}"
    
    fetch_and_extract_dlls "${work_dir}/cache/${lib_zip}" $lib_url
    
    # libxp
    lib_ver="240219"
    lib_zip="libxp-win32-v${lib_ver}.7z"
    lib_url="https://github.com/sasgis/sas.planet.bin/releases/download/v.${lib_ver}-lib/${lib_zip}"
    
    fetch_and_extract_dlls "${work_dir}/cache/${lib_zip}" $lib_url
    
    # lib32
    lib_ver="240219"
    lib_zip="lib32-lite-win32-v${lib_ver}.7z"
    lib_url="https://github.com/sasgis/sas.planet.bin/releases/download/v.${lib_ver}-lib/${lib_zip}"
    
    fetch_and_extract_dlls "${work_dir}/cache/${lib_zip}" $lib_url
}

function add_data {

	if [ -d "${work_dir}/data" ]; then
		cd "${work_dir}/data"
		cp -prfv "./" "$sas_bin"
	fi
}

function log_begin {

    echo "Start at: " $(date "+%Y-%m-%d %H:%M:%S")
}

function log_end {

    echo "Finish at: " $(date "+%Y-%m-%d %H:%M:%S")

    cd $sas_log
    if [ -f "main.log" ]; then
        cp -f "main.log" "$cur_log_folder"
    fi
        
    7z a -t7z -ms=on "${cur_log_folder}.7z" -r "${cur_log_folder}/*"
        
    rm -rf "$cur_log_folder"
}
