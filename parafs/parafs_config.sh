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
    echo -e "\t\t cluster_config_bashrc begin"
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        update_bashrc $USER_NAME $ip $USER_NAME $USER_HOME $BASHRC_CONFIG_FILE
        if [ $? -ne 0 ] ; then
            echo -e "\033[31m\t\tfailed to config bashrc at $ip \033[0m"
            fault_ips="$config_ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure bashrc \033[0m"
    #    exit 1
    fi
    echo -e "\t\t cluster_config_bashrc end"
}

function cluster_update_hadoop() {
    echo -e "\t\t cluster_update_hadoop begin !!!!"

    __cluster_hadoop_slave
    
    __cluster_hadoop_xml

    echo -e "\t\t cluster_update_hadoop end"
}

function cluster_update_spark() {
    echo -e "\t\t cluster_update_spark begin"
    
    __cluster_spark_slave
    
    __cluster_spark_env

    echo -e "\t\t cluster_update_spark end"
}

function cluster_update_zookeeper () {
    echo -e "\t\t cluster_update_zookeeper begin"

    __cluster_zookeeper_conf

    __cluster_zookeeper_myid
    
    echo -e "\t\t cluster_update_zookeeper end"
}

function cluster_update_hbase() {
    echo -e "\t\t cluster_update_hbase begin"
    
    __cluster_hbase_regeionservers

    __cluster_hbase_xml

    echo -e "\t\t cluster_update_hbase end"
}

function cluster_update_hive() {
    echo -e "\t\t cluster_update_hive begin"

    __cluster_hive_xml
    
    echo -e "\t\t cluster_update_hive end"
}

function cluster_update_azkaban() {
    echo -e "\t\t cluster_update_azkaban begin"
    
    __cluster_azkaban_properties

    echo -e "\t\t cluster_update_azkaban end"
}

function cluster_update_kafka() {
    echo -e "\t\t cluster_update_kafka begin"

    __cluster_kafka_connect

    __cluster_kafka_broker_id

    echo -e "\t\t cluster_update_kafka end"
}
# ####### ParafsInstallation 
# ####+++ 逐台安装parafs和日志
# function cluster_ParafsInstallation() {
#    	echo -e "\t\t cluster_ParafsInstallation start"
# 		 source $SCRIPT_BASE_DIR/parafs/InstallALLParafs.sh
#     echo -e "\t\t cluster_parafs done"
# }
# 
# ####### cluster_SourceBashrc
# ####+++  设置环境变量
# function cluster_SourceBashrc() {
# 	  echo -e "\t\t cluster_SourceBashrc start"
# 	  	source $SCRIPT_BASE_DIR/parafs/InstallAllSourceBashrc.sh 
#     echo -e "\t\t cluster_SourceBashrc done"
# }
# 
# ####### cluster_ChangeConfigurationFile
# ####+++ 修改xml文件
# function cluster_ChangeConfigurationFile() {
#     echo -e "\t\t cluster_ChangeConfigurationFile start"
# 	  	source $SCRIPT_BASE_DIR/parafs/InstallAllChangeParaCfg.sh  
#     echo -e "\t\t cluster_ChangeConfigurationFile done"
# }
# 

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
