#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function prepare_usage() {
    echo "cluster-create-user"
    echo "cluster-user-authorize"
    echo "cluster-wotung-chown"
    echo "cluster-script-dist"
    echo "cluster-config-network"
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
    __cluster_check_user $USER_NAME false

    __cluster_create_user $USER_NAME $USER_PASSWD_SSL $USER_HOME $USER_SHELL

    __cluster_config_sudoers $USER_NAME
    ## 检查用户创建成功
    __cluster_check_user $USER_NAME true

    echo -e "\t\t cluster_create_user end"
}


###### cluster_user
######
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
# 
###### 修改/opt/wotung 所有者为parauser
function cluster_wotung_chown() {
     echo -e "\t\t cluster_wotung_chown begin"
     local filename=$PASSWD_CONFIG_FILE

     for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        
        dirpath_chown $ip $DEFAULT_USER $passwd $INSTALL_DIR $USER_NAME $USER_NAME
        # dirpath_chown 192.168.1.99 parafs tianpusen /opt/wotung parafs parafs
     done
     echo -e "\t\t cluster_wotung_chown end" 
}

####### 分发安装脚本到各机器上,方便配置文件同步
function cluster_script_dist() {
    echo -e "\t\t cluster_script_dist begin"
#    local script_zip_file=parafs-install.tar.gz
#    local script_zip_md5_file=parafs-install.md5sum
    
    __cluster_file_dist $INSTALL_DIR $SCRIPT_FILE $INSTALL_DIR

    __cluster_zipfile_check $SCRIPT_MD5_FILE $SCRIPT_FILE $INSTALL_DIR

    __cluster_unzipfile $SCRIPT_FILE $INSTALL_DIR
    echo -e "\t\t cluster_script_dist end"
}

####### 各机器上配置文件,/etc/hosts /etc/hostname
function cluster_config_network() {
    echo -e "\t\t cluster_config_network begin"

    __cluster_config_hostname
    
    __cluster_config_hosts

    echo -e "\t\t cluster_config_network end"
}

####### 分发安装文件到各机器上,llog.rpm parafs.rpm
function cluster_parafs_rpm_dist() {
    echo -e "\t\t cluster_parafs_rpm_dist begin"
    
    __cluster_file_dist $INSTALL_DIR $PARAFS_RPM $INSTALL_DIR

    __cluster_zipfile_check $PARAFS_MD5_RPM $PARAFS_RPM $INSTALL_DIR

    __cluster_file_dist $INSTALL_DIR $LLOG_RPM $INSTALL_DIR

    __cluster_zipfile_check $LLOG_MD5_RPM $LLOG_RPM $INSTALL_DIR

    echo -e "\t\t cluster_parafs_rpm_dist end"
}
 
#######  分发生态文件到各机器上,
function cluster_parafs_hadoop_dist() {
    echo -e "\t\t cluster_hadoop_dist begin"

    __cluster_file_dist $INSTALL_DIR $HADOOP_FILE $INSTALL_DIR

    __cluster_zipfile_check $HADOOP_MD5_FILE $HADOOP_FILE $INSTALL_DIR

    __cluster_unzipfile $HADOOP_FILE $INSTALL_DIR
    
    echo -e "\t\t cluster_hadoop_dist end"
}
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
PREPARE_BASH_NAME=parafs_prepare.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/parafs/common/common_utils.sh
fi
if [ -z ${USER_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/parafs/common/common_user.sh
fi
if [ -z ${COMMON_BASH_NAME} ] ; then
    . /opt/wotung/parafs-install/parafs/common/common_parafs.sh
fi
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
# cluster_create_user
# cluster_user_authorize
# cluster_wotung_chown
# cluster_script_dist
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
