#!/bin/bash -ex

. ./script/config.sh

function check_state {

    cd $tmp

    if [ ! -d $sas_src ]; then
        git clone "$proj_src" $sas_src
    fi

    if [ ! -d $sas_bin ]; then
        hg clone "$proj_bin" $sas_bin
    fi

    if [ ! -d $sas_lib ]; then
        hg clone "$proj_lib" $sas_lib
    fi

    if [ ! -d $sas_lang ]; then
        git clone "$proj_lang" $sas_lang
    fi
    
    if [ ! -d $sas_maps ]; then
        git clone "$proj_maps" $sas_maps
    fi    
}

function print_curr_rev_info {

    local template="Current revision: {rev}:{node|short} [{branch}]\n\n"
    echo -e $(hg log --rev . --template "$template")
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

    cd $sas_lib
    echo -e "\nUpdate sas.requires:"
    hg update default -C
    hg pull -f -u --insecure "$proj_lib"
    print_curr_rev_info
    ReqRev=$(hg log --template "{rev}" -r .)
    ReqNode=$(hg log --template "{node}" -r .)

    cd $sas_bin
    echo -e "\nUpdate sas.release:"
    hg update default -C
    hg pull -f -u --insecure "$proj_bin"
    hg update default -C
    print_curr_rev_info

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
