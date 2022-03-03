#!/bin/bash -ex

. ./script/gdrive_dl.sh

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
            echo $(date "+%y%m%d") > "${txt}"
            echo -e "\nInstalled: ${fver}"
        else
            echo -e "\nDownload failed: ${fver}"
        fi
    else
        echo -e "\nOk: ${fver}"
    fi
}

function install_delphi {
    
    local fid="12PudD427Rx6THTMYxvXclEcwk7lhB_Bh"
    local fver="d21.220303"
    
    install_bin $fid $fver
}

function install_el {
    
    local fid="1Hf_xVItd5iyp4FNLzeudza0NWCnKA49o"
    local fver="el6.190613"
    
    install_bin $fid $fver
}

function install_gettext {
    
    local fid="1UtWPFDiaabAH55nWunJZFqhsKj1urwZi"
    local fver="ggt.190713"
    
    install_bin $fid $fver
}

install_delphi
install_el
install_gettext
