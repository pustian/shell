#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

function install_usage() {
    echo "cluster-dist-rpm"
    echo "cluster-dist-hadoop"
    echo "cluster-yum"
    echo "cluster-pip"
    echo "cluster-rpm-install"
    echo "cluster-sudoer-chown"
    echo "cluster-config-bashrc"
    echo "cluster-update-hadoop"
    echo "cluster-update-spark"
    echo "cluster-update-zookeeper"
    echo "cluster-update-hive"
    echo "cluster-update-hbase"
    echo "cluster-update-kafka"
    echo "cluster-update-azkaban"
    echo "cluster-update-ycsb"
}

####### 分发安装文件到各机器上,llog.rpm parafs.rpm
function cluster_dist_rpm() {
    echo -e "\t\t cluster_parafs_rpm_dist begin"
    
    __cluster_file_dist $INSTALL_DIR $PARAFS_RPM $INSTALL_DIR

    __cluster_zipfile_check $PARAFS_MD5_RPM $PARAFS_RPM $INSTALL_DIR

    __cluster_file_dist $INSTALL_DIR $LLOG_RPM $INSTALL_DIR

    __cluster_zipfile_check $LLOG_MD5_RPM $LLOG_RPM $INSTALL_DIR

    echo -e "\t\t cluster_parafs_rpm_dist end"
}
 
#######  分发生态文件到各机器上,
function cluster_dist_hadoop() {
    echo -e "\t\t cluster_hadoop_dist begin"

    __cluster_file_dist $INSTALL_DIR $HADOOP_FILE $INSTALL_DIR

    __cluster_zipfile_check $HADOOP_MD5_FILE $HADOOP_FILE $INSTALL_DIR

    __cluster_unzipfile $HADOOP_FILE $INSTALL_DIR
    
    echo -e "\t\t cluster_hadoop_dist end"
}

###### 免密后yum 安装
function cluster_yum() {
    echo -e "\t\t cluster_yum begin"
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        yum_install $USER_NAME $ip $USER_NAME
        if [ $? -ne 0 ] ; then
            echo -e "\033[31m\t\tfailed to pip install paramiko at $ip \033[0m"
            fault_ips="$config_ip $fault_ips"
            # break;
        fi
    done
    echo -e "\t\t cluster_yum end"
}

###### 免密后pip 安装
function cluster_pip() {
    echo -e "\t\t cluster_pip begin"
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        pip_install $USER_NAME $ip $USER_NAME
        if [ $? -ne 0 ] ; then
            echo -e "\033[31m\t\tfailed to pip install paramiko at $ip \033[0m"
            fault_ips="$config_ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure pip install paramiko \033[0m"
    #    exit 1
    fi
    echo -e "\t\t cluster_pip end"
}

###### 免密后rpm 安装
function cluster_rpm_install() {
    echo -e "\t\t __cluster_install_rpm begin"
    for ip in $CLUSTER_IPS; do
        rpm_install $USER_NAME $ip $USER_NAME $PARAFS_RPM
        rpm_install $USER_NAME $ip $USER_NAME $LLOG_RPM
    done
    echo -e "\t\t __cluster_install_rpm end"
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

###### 免密，修改解压后的hadoop-parafs 用户
function cluster_sudoer_chown() {
    local dirpath=$1
    echo -e "\t\t cluster_sudoer_chown begin"
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        dirpath_sudoer_chown $USER_NAME $ip $USER_NAME $dirpath $USER_NAME $USER_NAME
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
    echo -e "\t\t cluster_sudoer_chown end"
}

function cluster_update_hadoop() {
    echo -e "\t\t cluster_update_hadoop begin"

    __cluster_hadoop_slave
    
    __cluster_hadoop_xml

    echo -e "\t\t cluster_update_hadoop begin"
}
# ####### ParafsInstallation 
# ####+++ 逐台安装parafs和日志
# function cluster_ParafsInstallation() {
#    	echo -e "\t\t cluster_ParafsInstallation start"
# 		 source $BASE_DIR/parafs/InstallALLParafs.sh
#     echo -e "\t\t cluster_parafs done"
# }
# 
# ####### cluster_SourceBashrc
# ####+++  设置环境变量
# function cluster_SourceBashrc() {
# 	  echo -e "\t\t cluster_SourceBashrc start"
# 	  	source $BASE_DIR/parafs/InstallAllSourceBashrc.sh 
#     echo -e "\t\t cluster_SourceBashrc done"
# }
# 
# ####### cluster_ChangeConfigurationFile
# ####+++ 修改xml文件
# function cluster_ChangeConfigurationFile() {
#     echo -e "\t\t cluster_ChangeConfigurationFile start"
# 	  	source $BASE_DIR/parafs/InstallAllChangeParaCfg.sh  
#     echo -e "\t\t cluster_ChangeConfigurationFile done"
# }
# 

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
INSTALL_BASH_NAME=parafs_install.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z ${COMMON_BASH_NAME} ] ; then
    . ${BASE_DIR}/parafs/common/common_parafs.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/common/common_utils.sh
fi


###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
#set -x
# cluster_dist_rpm
# cluster_dist_hadoop
# cluster_yum
# cluster_pip
# cluster_config_bashrc
# cluster_sudoer_chown /opt/wotung/hadoop-parafs
# cluster_update_hadoop
 echo $?
#set +x
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
