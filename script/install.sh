#!/bin/bash -ex

function google_drive_download {

    local fid="$1"
    local fname="$2"
    local fcookie="$3"

    curl --ssl-no-revoke -L "https://drive.usercontent.google.com/download?id=${fid}&export=download&confirm=y" -o ${fname}
}

function install_bin {
    
    local fid="$1"
    local fver="$2"
    
    local out="./bin/"
    local txt="./info/${fver}.txt"
    local fname="./cache/${fver}.7z"
    
    if [ ! -f "${txt}" ]; then
        if [ ! -f "${fname}" ]; then
            google_drive_download ${fid} ${fname} "./info/${fver}.cookie.txt"
        fi
        if [ -f "${fname}" ]; then
            7z x -y -p"sasgis" ${fname} -o"${out}"
            echo $(date +"%y%m%d") > "${txt}"
            echo -e "\nInstalled: ${fver}"
        else
            echo -e "\nDownload failed: ${fver}"
        fi
    else
        echo -e "\nOk: ${fver}"
    fi
}

function install_delphi {
    
    local fid="1CVWMgsQLXjs17P3QQu-k3hrdVTiC2DSc"
    local fver="d21.241124"
    
    install_bin $fid $fver
    
    local fid="1yQH4UseHKoWP6vtJadNsnuX3h0IXH30y"
    local fver="d37.250923"
    
    install_bin $fid $fver
}

function install_el {
    
    local fid="1s43wgdmRP-Bf-9V0puYWEFlWl5KzGqlB"
    local fver="el713.d21.241124"
    
    install_bin $fid $fver
}

function install_me {
    
    local fid="1GxkAzprYHtI4D-8y3mb928J_tko3T3ah"
    local fver="me520.d21.250923"
    
    install_bin $fid $fver
    
    local fid="1GHrbdgc5LhVfVYQDpMdD4wqH5TXnZRU8"
    local fver="me520.d37.250923"
    
    install_bin $fid $fver
}

function install_gnugettext {
    
    local fid="1xwhBUSfVGHcxA76LuK51Jc6CfWJhgSxh"
    local fver="ggt225.241124"
    
    install_bin $fid $fver
}

install_delphi
install_me
install_el
install_gnugettext
