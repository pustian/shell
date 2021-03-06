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

###### 免密后yum 安装源切换
function cluster_config_yum_source() {
    print_bgblack_fggreen " cluster_config_yum_source begin" $inst_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        config_yum_source $USER_NAME $ip $USER_NAME
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Info Failed to config yum source at $ip "
            fault_ips="$config_ip $fault_ips"
            # break;
        fi
    done
    print_bgblack_fggreen "cluster_config_yum_source end" $inst_output_tabs

}
###### 免密后yum 安装
function cluster_yum() {
    print_bgblack_fggreen "cluster_yum begin" $inst_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        yum_install $USER_NAME $ip $USER_NAME
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to yum depdences at $ip "
            fault_ips="$config_ip $fault_ips"
            # break;
        fi
    done
    print_bgblack_fggreen "cluster_yum end" $inst_output_tabs
}

###### 免密后yum 单结点安装
function single_yum() {
    print_bgblack_fggreen "single_yum begin" $inst_output_tabs

    local ip=$1
    local fault_ips=""
    yum_install $USER_NAME $ip $USER_NAME
    if [ $? -ne 0 ] ; then
        print_bgblack_fgred "Failed to yum depdences at $ip "
        fault_ips="$config_ip $fault_ips"
        # break;
    fi
    print_bgblack_fggreen "single_yum end" $inst_output_tabs
}

###### 免密后pip 安装
function cluster_pip() {
    print_bgblack_fggreen "cluster_pip begin" $inst_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        pip_install $USER_NAME $ip $USER_NAME
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to pip install paramiko at $ip "
            fault_ips="$config_ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "make sure pip install paramiko at $fault_ips"
    #    exit 1
    fi
    print_bgblack_fggreen "cluster_pip end" $inst_output_tabs
}

###### 免密后pip 单结点安装
function single_pip() {
    print_bgblack_fggreen "single_pip begin" $inst_output_tabs
    local ip=$1
    local fault_ips=""
    pip_install $USER_NAME $ip $USER_NAME
    if [ $? -ne 0 ] ; then
        print_bgblack_fgred "Failed to pip install paramiko at $ip "
        fault_ips="$config_ip $fault_ips"
        # break;
    fi
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "make sure pip install paramiko at $fault_ips"
    #    exit 1
    fi
    print_bgblack_fggreen "single_pip end" $inst_output_tabs
}

###### 免密后rpm 安装
function cluster_rpm_install() {
    print_bgblack_fggreen "cluster_rpm_install begin" $inst_output_tabs
    for ip in $CLUSTER_IPS; do
        rpm_install $USER_NAME $ip $USER_NAME ${INSTALL_DIR}/$PARAFS_RPM
        rpm_install $USER_NAME $ip $USER_NAME ${INSTALL_DIR}/$LLOG_RPM
        cluster_cmd "cp /opt/wotung/etc/para.cfg.sample /opt/wotung/etc/para.cfg"
    done
    print_bgblack_fggreen "cluster_rpm_install end" $inst_output_tabs
}

###### 免密后rpm 单结点远程安装
function single_rpm_install() {
    print_bgblack_fggreen "single_rpm_install begin" $inst_output_tabs
    
    local ip=$1
    rpm_install $USER_NAME $ip $USER_NAME ${INSTALL_DIR}/$PARAFS_RPM
    rpm_install $USER_NAME $ip $USER_NAME ${INSTALL_DIR}/$LLOG_RPM

    print_bgblack_fggreen "cluster_rpm_install end" $inst_output_tabs
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
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi

. $SCRIPT_BASE_DIR/parafs/parafs_tools.sh

inst_output_tabs="2"
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
