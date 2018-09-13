#!/bin/bash

function help_info(){
    echo The tools are as following:
    echo -e "update parafs:\t\t tool_update_parafs"
    echo -e "add node:\t\t tool_add_node \"node_ip\""
    echo -e "synchronize file:\t tool_sync_file \"full_filepath\""
}   

function tool_update_parafs(){
    cluster_update_parafs
}

function tool_add_node(){
    local node=$1
    # before executing, configure the conf/network & conf/passwd
    cluster_add_node $node
    echo
}

function tool_sync_file(){
    local full_filepath=$1
    cluster_sync_file "$full_filepath"
}
### main ###
. /opt/wotung/parafs-install/parafs/parafs_tools.sh

help_info
