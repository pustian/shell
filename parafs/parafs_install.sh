#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

function install_usage() {
    echo "cluster-yum"
    echo "cluster-pip"
    echo "cluster-rpm-install"
    echo "cluster-sudoer-chown"
}

###### 免密后yum 安装
function cluster_yum() {
    echo -e "cluster_yum begin"
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        yum_install $USER_NAME $ip $USER_NAME
        if [ $? -ne 0 ] ; then
            echo -e "\033[31m\t\tfailed to yum file at $ip \033[0m"
            fault_ips="$config_ip $fault_ips"
            # break;
        fi
    done
    echo -e "cluster_yum end\n"
}

###### 免密后pip 安装
function cluster_pip() {
    echo -e "cluster_pip begin"
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
    echo -e "cluster_pip end\n"
}

###### 免密后rpm 安装
function cluster_rpm_install() {
    echo -e "__cluster_install_rpm begin"
    for ip in $CLUSTER_IPS; do
        rpm_install $USER_NAME $ip $USER_NAME ${INSTALL_DIR}/$PARAFS_RPM
        rpm_install $USER_NAME $ip $USER_NAME ${INSTALL_DIR}/$LLOG_RPM
    done
    echo -e "__cluster_install_rpm end\n"
}

###### 免密，修改解压后的hadoop-parafs 用户
function cluster_sudoer_chown() {
    local dirpath=$1
    echo -e "\t\t cluster_sudoer_chown begin"
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        dirpath_sudoer_chown $USER_NAME $ip $USER_NAME ${HADOOP_PARAFS_HOME} $USER_NAME $USER_NAME
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

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
INSTALL_BASH_NAME=parafs_install.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . ../variable.sh
fi
if [ -z ${COMMON_BASH_NAME} ] ; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_parafs.sh
fi

###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
#set -x
# cluster_yum
# cluster_pip
# cluster_rpm_install
# cluster_sudoer_chown
# echo $?
#set +x
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
