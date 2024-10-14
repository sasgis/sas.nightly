#!/bin/bash -ex

function google_drive_download {

    local fid="$1"
    local fname="$2"
    local fcookie="$3"
        
    curl --ssl-no-revoke -L "https://drive.usercontent.google.com/download?id=${fid}&export=download&confirm=y" -o ${fname}
}
