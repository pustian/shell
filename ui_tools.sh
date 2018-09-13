#!/bin/bash

function help_info(){
    echo The tools are as following:
    echo -e "\033[40;37m Update parafs-----------------------------------------------------------------[u]\033[0m"
    echo -e "\033[40;37m Add node----------------------------------------------------------------------[a]\033[0m"
    echo -e "\033[40;37m Rebuild parafs----------------------------------------------------------------[r]\033[0m"

    echo "what do you want to do:"
}   

function switch_case(){
    read input
    case $input in
        u)
            ;;
        a)
            ;;
        r)
            ;;
    esac
}

### main ###
. /opt/wotung/parafs-install/parafs/parafs_tools.sh

help_info
switch_case
