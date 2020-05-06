#!/bin/bash -ex

. ./script/config.sh

function check_state {

    cd $tmp

    if [ ! -d $sas_src ]; then
        hg clone "$proj_src" $sas_src
    fi

    if [ ! -d $sas_bin ]; then
        hg clone "$proj_bin" $sas_bin
    fi

    if [ ! -d $sas_lib ]; then
        hg clone "$proj_lib" $sas_lib
    fi

    if [ ! -d $sas_lang ]; then
        hg clone "$proj_lang" $sas_lang
    fi
    
    if [ ! -d $sas_maps ]; then
        git clone "$proj_maps" $sas_maps
    fi    
}

function print_curr_rev_info {

    local template="Current revision: {rev}:{node|short} [{branch}]\n\n"
    echo -e $(hg log --rev . --template "$template")
}

function pull_changes {

    # Check root folders struct
    check_state

    # Pulling changes
    cd $sas_lang
    echo -e "\nUpdate sas.translate:"
    hg update default -C
    hg pull -f -u --insecure $proj_lang
    print_curr_rev_info

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

    cd $sas_maps
    echo -e "\nUpdate sas.maps"
    git fetch --all --verbose
    git clean -d -x --force
    git reset --hard origin/master
    
    cd $sas_src
    if [ "$work_type" = "NIGHTLY" ]; then
        echo -e "\nPull changes to sas.src:"
        hg pull -f "$proj_src"
        echo -e $(hg log --template "\nLocal revision: {rev}:{node|short} [{branch}]\n\n" -r .)
        LocalRev=$(hg log --template "{rev}" -r .)
        hg log --encoding utf8 -r .:
        echo -e "Apply changes to sas.src:"
        hg update default -C
        echo -e $(hg log --template "\nUpdate to revision: {rev}:{node|short} [{branch}]\n\n" -r .)
        UpdateRev=$(hg log --template "{rev}" -r .)
        UpdateNode=$(hg log --template "{node}" -r .)
    else
        echo -e "\nUpdate sas.src:"
        hg update default -C
        hg pull -f -u "$proj_src"
        print_curr_rev_info
        UpdateRev=$(hg log --template "{rev}" -r .)
        UpdateNode=$(hg log --template "{node}" -r .)
    fi
}
