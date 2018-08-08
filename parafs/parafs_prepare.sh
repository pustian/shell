#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function prepare_usage() {
    echo "cluster-create-user"
    echo "cluster-user-authorize"
    echo "cluster-config-network"
    echo "local-script-zip"
    echo "cluster-script-dist"
    echo "cluster-root-chown"
}

####### 根据配置文件PASSWD_CONFIG_FILE ip,在机器上创建新用户parauser 
####+++ return : 
function cluster_create_user() {
    echo -e "\t\t cluster_create_user begin"
    #__cluster_check_user $username $userhome
    # 检查没有创建过parauser用户
    __cluster_check_user $USER_NAME false

    __cluster_create_user $USER_NAME $USER_PASSWD_SSL $USER_HOME $USER_SHELL

    __cluster_config_sudoers $USER_NAME
    ## 检查用户创建成功
    __cluster_check_user $USER_NAME true

    echo -e "\t\t cluster_create_user end"
}

###### 用户免密  n*n ssh_user_authorize==>common_user.sh
function cluster_user_authorize() {
    echo -e "\t\t cluster_user_authorize begin"
    
    for outer_ip in $CLUSTER_IPS; do
        for inner_ip in $CLUSTER_IPS; do
            ssh_user_authorize ${outer_ip} ${USER_NAME} ${USER_PASSWD} ${USER_HOME} \
                ${inner_ip} ${USER_NAME} ${USER_PASSWD} ${USER_HOME}
        done
    done

    echo -e "\t\t cluster_user_authorize end"
}

####### 各机器上配置文件,/etc/hosts /etc/hostname
function cluster_config_network() {
    echo -e "\t\t cluster_config_network begin"

    __cluster_config_hostname
    
    __cluster_config_hosts

    echo -e "\t\t cluster_config_network end"
}

####### 各机器上配置文件,/etc/hosts /etc/hostname
function local_script_zip() {
    echo -e "\t\t local_script_zip begin"
    zip_dir $USER_NAME $CLUSTER_LOCAL_IP $USER_NAME $SCRIPT_BASE_DIR `dirname $SCRIPT_BASE_DIR`
    zip_file=`basename $SCRIPT_BASE_DIR`.tar.gz
    file_md5sum $USER_NAME $CLUSTER_LOCAL_IP $USER_NAME `dirname $SCRIPT_BASE_DIR`/$zip_file
    echo -e "\t\t local_script_zip end"
}

####### 分发安装脚本到各机器上,方便配置文件同步
function cluster_script_dist() {
    echo -e "\t\t cluster_script_dist begin"
#    local script_zip_file=parafs-install.tar.gz
#    local script_zip_md5_file=parafs-install.md5sum
    local script_basedir=`dirname $SCRIPT_BASE_DIR`
    local script_file=`basename $SCRIPT_BASE_DIR`.tar.gz
    local script_md5_file=${script_file}.md5sum
    echo $script_file $script_basedir $script_md5_file

    __cluster_file_dist $script_basedir $script_file $script_basedir

    __cluster_zipfile_check $script_md5_file $script_file $script_basedir

    __cluster_unzipfile $script_file $script_basedir

    echo -e "\t\t cluster_script_dist end"
}

###### 修改/opt/wotung 所有者为parauser
function cluster_root_chown() {
    echo -e "\t\t cluster_root_chown begin"
    local filename=$PASSWD_CONFIG_FILE

    local script_basedir=`dirname $SCRIPT_BASE_DIR`
    for ip in $CLUSTER_IPS; do
       passwd=`grep ${ip} $filename |awk '{print $2 }'`
       
       dirpath_root_chown $ip $DEFAULT_USER $passwd $INSTALL_DIR $USER_NAME $USER_NAME
       dirpath_root_chown $ip $DEFAULT_USER $passwd $script_basedir $USER_NAME $USER_NAME
       # dirpath_root_chown 192.168.1.99 parafs tianpusen /opt/wotung parafs parafs
    done
    echo -e "\t\t cluster_root_chown end" 
}


###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
PREPARE_BASH_NAME=parafs_prepare.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . ../variable.sh
fi
if [ -z ${USER_BASH_NAME} ] ; then 
    . ${SCRIPT_BASE_DIR}/parafs/common/common_user.sh
fi
if [ -z ${ZIP_BASH_NAME} ] ; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_zip.sh
fi
if [ -z ${COMMON_BASH_NAME} ] ; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_parafs.sh
fi
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
# cluster_create_user
# cluster_user_authorize
# cluster_config_network
# local_script_zip
# cluster_script_dist
 cluster_root_chown
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
