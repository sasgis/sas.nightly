#!/bin/bash -ex

. ./script/config.sh

function check_state {

    cd $tmp

    if [ ! -d $sas_src ]; then
        git clone "$proj_src" $sas_src
    fi

    if [ ! -d $sas_bin ]; then
        git clone "$proj_bin" $sas_bin
    fi

    if [ ! -d $sas_lib ]; then
        git clone "$proj_lib" $sas_lib
    fi

    if [ ! -d $sas_lang ]; then
        git clone "$proj_lang" $sas_lang
    fi
    
    if [ ! -d $sas_maps ]; then
        git clone "$proj_maps" $sas_maps
    fi    
}

function update_git_repo {
    
    local repo_path=$1
    
    cd ${repo_path}
    
    git fetch --all --verbose
    git clean -d -x --force
    git reset --hard origin/master
}

function pull_changes {

    # Check root folders struct
    check_state

    # Pulling changes
    echo -e "\nUpdate sas.translate:"
    update_git_repo $sas_lang
    
    echo -e "\nUpdate sas.requires:"
    update_git_repo $sas_lib
    cd $sas_lib
    ReqRev=$(git rev-list master --count)
    ReqNode=$(git rev-parse master)

    echo -e "\nUpdate sas.release:"
    update_git_repo $sas_bin

    echo -e "\nUpdate sas.maps:"
    update_git_repo $sas_maps
        
    echo -e "\nUpdate sas.src:"
    if [ "$work_type" = "NIGHTLY" ]; then
        cd $sas_src
        LocalRev=$(git rev-list master --count)
        LocalNode=$(git rev-parse master)
    fi
    update_git_repo $sas_src
    cd $sas_src
    UpdateRev=$(git rev-list master --count)
    UpdateNode=$(git rev-parse master)
}
