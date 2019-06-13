#!/bin/bash -ex

function google_drive_download {

    local fid="$1"
    local fname="$2"
    local fcookie="$3"
        
    curl -c ${fcookie} -s -L "https://drive.google.com/uc?export=download&id=${fid}" -o ${fname}

    local confirm=$(awk '/download/ {print $NF}' ${fcookie})

    if [[ ! -z ${confirm} ]]; then
      echo "Confirm code recieved: ${confirm}"  
      curl -b ${fcookie} -s -L "https://drive.google.com/uc?export=download&confirm=${confirm}&id=${fid}" -o ${fname}
    fi
}
