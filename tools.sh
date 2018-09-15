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

# before executing, configure the conf/network & conf/passwd
function tool_add_node(){
    local node=$1
    cluster_root_authorize
    cluster_config_network
    cluster_close_firewalld

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
    cluster_sync_file "$full_filepath"
}

function test_f(){
    # single dist hadoop-system
    single_hadoop_dist "192.168.1.204"

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

}
### main ###
. /opt/wotung/parafs-install/variable.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_tools.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_prepare.sh
. ${SCRIPT_BASE_DIR}/parafs/check_env.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_dist.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_install.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_config.sh

help_info
