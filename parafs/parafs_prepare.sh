#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function prepare_usage() {
    echo "cluster-create-user"
    echo "cluster-parauser-authorize"
    echo "cluster-config-hostname"
    echo "cluster-config-hosts"
    echo "cluster-check-nodes"
    echo "cluster-script-dist"
    echo "cluster-install-package-dist"
#    echo "cluster-check-install-package"
    echo "cluster-unzip-install-package"
#    echo "cluster-yum-source"
    echo "cluster-yum-install"
#    echo "cluster-pip-source"
    echo "cluster-pip-install"
}

####### 根据配置文件PASSWD_CONFIG_FILE ip,在机器上创建新用户user 
####+++ return : 
function cluster_create_user() {
    local filename=$PASSWD_CONFIG_FILE
#    useradd -g -u 
#    ssh_remote_exec.exp hostname passwd command
#    sed /etc/sudoer
#    passwd exp
    echo -e "\t\t cluster_create_user end"
    echo $?
}

####### 根据配置文件network ip,机器上parauser 相互免密 
####+++ return : 
function cluster_parauser_authorize() {
    local filename=$PASSWD_CONFIG_FILE
    echo -e "\t\t cluster_parauser_authorize end"
    echo $?
}

####### 根据配置文件network修改hostname
####+++ parater: network_config
####+++ 
function cluster_script_dist() {
    local filename=$PASSWD_CONFIG_FILE
    # tar czvf
    # scp
    # tar xzvf
    echo -e "\t\t cluster_script_dist end"
    echo $?
}

####### 根据配置文件network修改hostname
####+++ 
function cluster_config_hostname() {
    local filename=$PASSWD_CONFIG_FILE
    echo -e "\t\t cluster_config_hostname end"
    echo $?
}

####### 根据配置文件network修改hosts
####+++ return :
function cluster_config_hosts() {
    local filename=$PASSWD_CONFIG_FILE
    echo -e "\t\t cluster_config_hosts end"
    echo $?
}

####### 根据配置文件network所有本机到所有机器 root免密登陆
####+++ return : 检查失败输出到屏幕，并且停止进行
function cluster_check_node() {
    local filename=$PASSWD_CONFIG_FILE
    echo -e "\t\t cluster_check_node end"
    echo $0
}
####### 检查配置文件 network 是否存在并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function cluster_install_package_dist() {
    local ip_filename=
    local install_filename=
    # IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    ### 检查ips相同
    echo -e "\t\t cluster_install_package_dist done"
}

####### 检查配置文件 network 是否存在并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function cluster_check_install_package() {
    local ip_filename=
    local install_filename=
    #IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    ### 检查ips相同
    echo -e "\t\t cluster_check_install_package done"
}

####### 检查配置文件 network 是否存在并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function cluster_unzip_install_package() {
    local ip_filename=
    local install_filename=
    # IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    ### 检查ips相同
    echo -e "\t\t cluster_unzip_install_package done"
}
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
PREPARE_BASH_NAME=parafs_prepare.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/common/utils.sh
fi


###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
