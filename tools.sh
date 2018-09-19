#!/bin/bash

function controller(){
    help_info
    handle_input
    if [ $? = 1 ]; then
        help_info
        handle_input
    else
        exit 0
    fi
}

function help_info(){
    echo "================================================================="
    echo The tools are as following:
    echo -e "[$NUM_UPDATE] update parafs"
    echo -e "[$NUM_ADDNODE] add node"
    echo -e "[$NUM_SYNCFILE] synchronize file"
    echo -e "[q] quit the tool"
}

function handle_input(){
    read -p "input the character:" input
        case $input in
            $NUM_UPDATE)
                case_hint "update_parafs"
                tool_update_parafs
                return 1
                ;;
            $NUM_ADDNODE)
                case_hint "add_node"
                read -p "input parameter,#1 ip:" ip 
                tool_add_node $ip
                return 1 
                ;;
            $NUM_SYNCFILE)
                case_hint "synchronize file"
                read -p "Pls input file full path (example: /opt/wotung/etc/para.cfg):" full_filepath
                tool_sync_file $full_filepath
                return 1
                ;;
            q)
                echo "quiting"
                return 0
                ;;
        esac
}

function case_hint(){
    local case_name=$1
    echo "------------${case_name}--------------"
}

function alert_msg(){
    local msg=$1
    echo "WARRING！${msg}.Please confirm and retry."
}

function tool_update_parafs(){
    local update_path="/opt/wotung/package/update"
    if [ -f $update_path/parafs*.rpm ]; then 
        cluster_update "parafs"
    elif [ -f $update_path/llog*.rpm ]; then
        cluster_update "llog"
    else
        alert_msg "No rpms of parafs or llog in ${update_path}"
        exit 1
    fi
}

function tool_add_node(){
    local node=$1
    local file_network=$SCRIPT_BASE_DIR/conf/networks
    local file_passwd=$SCRIPT_BASE_DIR/conf/passwd
    grep $node $file_network | grep -v '^#' > /dev/null
    local network_exist=$?
    grep $node $file_passwd | grep -v '^#' > /dev/null
    local passwd_exist=$?

    if [ $network_exist = 0 ] && [ $passwd_exist = 0 ]; then
        add_node_execute $node
    else
        alert_msg "$node doesn't exist in $file_network or $file_passwd"
        exit 1
    fi
}

function add_node_execute(){
    local node=$1

    cluster_check_filesystem
    cluster_root_authorize
    cluster_config_network
    cluster_alias_authorize
    cluster_check_internet
    cluster_close_firewalld

    # dist the parafs-install
    local_script_zip
    single_script_dist $node

    # parafs rpm install
    single_dist_rpm $node
    single_rpm_install $node

    # yum, pip install
    single_yum $node
    single_pip $node

    # single dist hadoop-system
    single_hadoop_dist $node

    # config
    cluster_config_bashrc
    cluster_chmod
    check_local_config_file
    cluster_update_hadoop
    cluster_update_spark
    cluster_update_zookeeper
    cluster_update_hbase
    cluster_update_hive
    cluster_update_azkaban
    cluster_update_kafka
    cluster_update_ycsb_hbase
    cluster_update_spark_bench_legacy     

    # after check
    cluster_install_clean

}

function tool_sync_file(){
    local full_filepath=$1
    if [ -f $full_filepath ]; then
        cluster_sync_file "$full_filepath"
    else
        alert_msg "the file $full_filepath doesn't exist"
        exit 1
    fi
}

###################################### main ######################################
. /opt/wotung/parafs-install/variable.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_tools.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_prepare.sh
. ${SCRIPT_BASE_DIR}/parafs/check_env.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_dist.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_install.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_config.sh

### declaration of global input number
NUM_UPDATE=1
NUM_ADDNODE=2
NUM_SYNCFILE=3

controller
