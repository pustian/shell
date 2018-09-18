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
    echo -e "[1] update parafs"
    echo -e "[2] add node"
    echo -e "[3] synchronize file"
    echo -e "[q] quit the tool"
}

function handle_input(){
    read -p "input the character:" input
        case $input in
            1)
                case_hint "update_parafs"
                tool_update_parafs
                return 1
                ;;
            2)
                case_hint "add_node"
                echo "请确认新节点信息已经加入conf/下的 [passwd]和 [networks]中"
                read -p "input parameter,#1 ip:" ip 
                tool_add_node $ip
                return 1 
                ;;
            3)
                case_hint "synchronize file"
                read -p "input parameter,#1 file_fullpath:" full_filepath
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
    lcoal msg=$1
    echo "警告！${msg}.请确认后重试}"
}

function tool_update_parafs(){
    local update_path="/opt/wotung/package/update"
    if [ -f $update_path/llog*.rpm ] && [ -f $update_path/parafs*.rpm ]; then 
        cluster_update_parafs
    else
        alert_msg "在${update_path}下缺少rpm包"
        exit 1
    fi
}

function tool_add_node(){
    local node=$1
    local file_network=$SCRIPT_BASE_DIR/conf/networks
    local file_passwd=$SCRIPT_BASE_DIR/conf/passwd
    grep $node $file_network | grep -v '^#'
    local network_exist=$?
    grep $node $file_passwd | grep -v '^#'
    local passwd_exist=$?

    if [ $network_exist = 0 ] && [ $passwd_exist = 0 ]; then
        add_node_execute $node
    else
        echo "警告！输入的ip在conf/passwd 或 conf/networks中不存在。请确认后重试。"
        exit 1
    fi
}

function add_node_execute(){
    lcoal node=$1
    cluster_root_authorize
    cluster_config_network
    cluster_close_firewalld

    # dist the parafs-install
    local_script_zip
    cluster_script_dist

    # parafs rpm install
    local_dist_rpm
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
        echo "警告！输入的文件全路径不存在。请确认后重试。"
        exit 1
    fi
}

### main ###
. /opt/wotung/parafs-install/variable.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_tools.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_prepare.sh
. ${SCRIPT_BASE_DIR}/parafs/check_env.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_dist.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_install.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_config.sh

controller
