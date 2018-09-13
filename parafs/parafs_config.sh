#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

function install_usage() {
    echo "cluster-config-bashrc"
    echo "cluster-update-hadoop"
    echo "cluster-update-spark"
    echo "cluster-update-zookeeper"
    echo "cluster-update-hbase"
    echo "cluster-update-hive"
    echo "cluster-update-azkaban"
    echo "cluster-update-kafka"
#    echo "cluster-update-ycsb"
}

###### 免密，且文件script 分发后bashrc配置
function cluster_config_bashrc() {
    print_bgblack_fggreen "cluster_config_bashrc begin" $config_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        update_bashrc $USER_NAME $ip $USER_NAME $USER_HOME $BASHRC_CONFIG_FILE
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config bashrc at $ip" $config_output_tabs
            fault_ips="$config_ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "Make sure bashrc at $fault_ips" $config_output_tabs
    #    exit 1
    fi
    print_bgblack_fggreen "cluster_config_bashrc end" $config_output_tabs
}

###### 赋予hadoop-system下的bin/和sbin/ 执行权限
function cluster_chmod() {
    print_bgblack_fggreen "cluster_chmod hadoop-system begin" $config_output_tabs
	bin_cmd="find /opt/wotung/hadoop-system -name bin |xargs chmod -R +x"
	sbin_cmd="find /opt/wotung/hadoop-system -name sbin |xargs chmod -R +x"
	local_user="root"
	remote_user="root"
	for each_ip in $CLUSTER_IPS; do
		remote_excute_cmd $local_user $remote_user $each_ip "$bin_cmd"
		remote_excute_cmd $local_user $remote_user $each_ip "$sbin_cmd"
	done
    print_bgblack_fggreen "cluster_chmod hadoop-system end" $config_output_tabs
}

function cluster_update_hadoop() {
    print_bgblack_fggreen "cluster_update_hadoop begin" $config_output_tabs

    __cluster_hadoop_slave
    
    __cluster_hadoop_xml

    print_bgblack_fggreen "cluster_update_hadoop end" $config_output_tabs

}

function cluster_update_spark() {
    print_bgblack_fggreen "cluster_update_spark begin" $config_output_tabs
    
    __cluster_spark_slave
    
    __cluster_spark_env

    __cluster_spark_hive_xml

    print_bgblack_fggreen "cluster_update_spark end" $config_output_tabs
}

function cluster_update_zookeeper () {
    print_bgblack_fggreen "cluster_update_zookeeper begin" $config_output_tabs

    __cluster_zookeeper_conf

    __cluster_zookeeper_myid
    
    print_bgblack_fggreen "cluster_update_zookeeper end" $config_output_tabs
}

function cluster_update_hbase() {
    print_bgblack_fggreen "cluster_update_hbase begin" $config_output_tabs
    
    __cluster_hbase_regeionservers

    __cluster_hbase_xml

    __cluster_hbase_backup

    print_bgblack_fggreen "cluster_update_hbase end" $config_output_tabs
}

function cluster_update_hive() {
    print_bgblack_fggreen "cluster_update_hive begin" $config_output_tabs
    
    __cluster_hive_xml
    
    print_bgblack_fggreen "cluster_update_hive end" $config_output_tabs
}

function cluster_update_azkaban() {
    print_bgblack_fggreen "cluster_update_azkaban begin" $config_output_tabs
    
    __cluster_azkaban_properties

    print_bgblack_fggreen "cluster_update_azkaban end" $config_output_tabs
}

function cluster_update_kafka() {
    print_bgblack_fggreen "cluster_update_kafka begin" $config_output_tabs

    __cluster_kafka_broker_id

    __cluster_kafka_connect

    print_bgblack_fggreen "cluster_update_kafka end" $config_output_tabs
}

function cluster_update_spark_bench_legacy() {
    print_bgblack_fggreen "cluster_update_spark_bench_legacy begin" $config_output_tabs
    
    __cluster_spark_bench_legacy_env
    
    print_bgblack_fggreen "cluster_update_spark_bench_legacy end" $config_output_tabs
}
function cluster_update_ycsb_hbase() {
    print_bgblack_fggreen "cluster_update_ycsb_hbase begin" $config_output_tabs
    
    __cluster_ycsb_hbase_xml

    print_bgblack_fggreen "cluster_update_ycsb_hbase end" $config_output_tabs
}
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
CONFIG_BASH_NAME=parafs_config.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . ../variable.sh
fi
if [ -z ${COMMON_BASH_NAME} ] ; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_parafs.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . ${SCRIPT_BASE_DIR}/parafs/common/common_utils.sh
fi
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi

config_output_tabs="2"

###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
#set -x
# cluster_config_bashrc
# cluster_update_hadoop
# cluster_update_spark
# cluster_update_zookeeper
# echo $?
#set +x
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
