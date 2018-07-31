#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
INSTALL_BASH_NAME=parafs_install.sh
function install_usage() {
#    echo "cluster-parafs"
    echo "cluster-parafs-client"
    echo "cluster-llog"
    echo "cluster-hadoop"
}

####### 检查配置文件 network 是否存在并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function cluster_parafs() {
    local ip_filename=
    local install_filename=
    # IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    ### 检查ips相同
    echo -e "\t\t cluster_parafs done"
}

####### 检查配置文件 network 是否存在并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function cluster_llog() {
    local ip_filename=
    local install_filename=
    # IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    ### 检查ips相同
    echo -e "\t\t cluster_llog done"
}

####### 检查配置文件 network 是否存在并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function cluster_parafs_client() {
    local ip_filename=
    local install_filename=
    # IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    ### 检查ips相同
    echo -e "\t\t cluster_parafs_client done"
}

function cluster_hadoop() {
    echo -e "\t\t cluster_hadoop done"
}
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
INSTALL_BASH_NAME=parafs_install.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/common/common_utils.sh
fi


###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
