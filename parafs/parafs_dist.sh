#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

function install_usage() {
    echo "cluster-dist-rpm"
    echo "cluster-dist-hadoop"
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

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
DIST_BASH_NAME=parafs_dist.sh_
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
 cluster_dist_rpm
# cluster_dist_hadoop
# cluster_yum
# cluster_pip
# cluster_config_bashrc
# cluster_sudoer_chown /opt/wotung/hadoop-parafs
# cluster_update_hadoop
 echo $?
#set +x
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
