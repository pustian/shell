#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function prepare_usage() {
    echo "cluster-create-user"
    echo "cluster-user-authorize"
    echo "script-zip"
    echo "cluster-yum-pip"
    # echo "cluster-check-nodes"

#    echo "cluster-config-hostname"
#    echo "cluster-config-hosts"
#    echo "cluster-install-package-dist"
#    echo "cluster-check-install-package"
#    echo "cluster-unzip-install-package"
#    echo "cluster-yum-source"
#    echo "cluster-yum-install"
#    echo "cluster-pip-source"
#    echo "cluster-pip-install"
}

####### 根据配置文件PASSWD_CONFIG_FILE ip,在机器上创建新用户parauser 
####+++ return : 
function cluster_create_user() {
    echo -e "\t\t cluster_create_user begin"

    #__cluster_check_user $username $userhome
    __cluster_check_user $USER_NAME

    __cluster_create_user $USER_NAME $USER_PASSWD_SSL $USER_HOME $USER_SHELL

    __cluster_config_sudoers $USER_NAME

    echo -e "\t\t cluster_create_user end"
}


###### cluster_user
######
function cluster_user_authorize() {
    echo -e "\t\t cluster_user_authorize begin"
    
    for outer_ip in $CLUSTER_IPS; do
        if [ "x${outer_ip}" = "x" ] ; then
            break;
        fi
        for inner_ip in $CLUSTER_IPS; do
            if [ "x${inner_ip}" = "x" ] ; then
                break;
            fi
            ssh_user_authorize ${outer_ip} ${USER_NAME} ${USER_PASSWD} ${USER_HOME} \
                ${inner_ip} ${USER_NAME} ${USER_PASSWD} ${USER_HOME}
        done
    done

    echo -e "\t\t cluster_user_authorize end"
}

####### 根据配置文件network修改hostname
####+++ parater: network_config
####+++ 
function cluster_script_dist() {
    scipt_zip_file=$1
    echo -e "\t\t cluster_script_dist begin"
    # 考虑到通用性使用zip 打包 unzip 解压
    zip_dir $BASE_DIR
    for ip in $CLUSTER_IPS ; do
        __cluster_file_dist $scipt_zip_file $BASE_DIR
    done

    echo -e "\t\t cluster_script_dist end"
    echo $?
}

####### 根据配置文件network修改hostname
####+++ 
function cluster_config_hostname() {
    local filename=$NETWORK_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
#    for ip in $IPS; do
#    done
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
    . /opt/wotung/parafs-install/parafs/common/common_utils.sh
fi
if [ -z ${COMMON_BASH_NAME} ] ; then
    . /opt/wotung/parafs-install/parafs/common/common_parafs.sh
fi
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
# cluster_create_user
# cluster_user_authorize
#cluster_script_dist
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
