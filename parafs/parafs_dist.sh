#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

function dist_usage() {
    echo "cluster-dist-rpm"
    echo "cluster-dist-hadoop"
    echo "local-dist-rpm"
    echo "local-dist-hadoop"
}

####### 分发安装文件到各机器上,llog.rpm parafs.rpm
function cluster_dist_rpm() {
    print_bgblack_fggreen "cluster_dist_rpm begin" $dist_output_tabs
    
    __cluster_file_dist $SOURCE_DIR $PARAFS_RPM $INSTALL_DIR

    __cluster_zipfile_check $PARAFS_MD5_RPM $SOURCE_DIR $PARAFS_RPM $INSTALL_DIR

    __cluster_file_dist $SOURCE_DIR $LLOG_RPM $INSTALL_DIR

    __cluster_zipfile_check $LLOG_MD5_RPM $SOURCE_DIR $LLOG_RPM $INSTALL_DIR

    print_bgblack_fggreen "cluster_dist_rpm end" $dist_output_tabs
}

####### 分发安装文件到单台机器上,llog.rpm parafs.rpm
function single_dist_rpm() {
    print_bgblack_fggreen "single_dist_rpm begin" $dist_output_tabs
    local ip=$1
    
    __single_file_dist $SOURCE_DIR $PARAFS_RPM $INSTALL_DIR $ip

    __single_zipfile_check $PARAFS_MD5_RPM $SOURCE_DIR $PARAFS_RPM $INSTALL_DIR $ip

    __single_file_dist $SOURCE_DIR $LLOG_RPM $INSTALL_DIR $ip

    __single_zipfile_check $LLOG_MD5_RPM $SOURCE_DIR $LLOG_RPM $INSTALL_DIR $ip

    print_bgblack_fggreen "single_dist_rpm end" $dist_output_tabs
}

#######  分发生态文件到各机器上,
function cluster_hadoop_dist() {
    print_bgblack_fggreen "cluster_hadoop_dist begin" $dist_output_tabs

    __cluster_file_dist $SOURCE_DIR $HADOOP_FILE $INSTALL_DIR

    __cluster_zipfile_check $HADOOP_MD5_FILE $SOURCE_DIR $HADOOP_FILE $INSTALL_DIR

    __cluster_unzipfile $HADOOP_FILE $INSTALL_DIR
    
    print_bgblack_fggreen "cluster_hadoop_dist end" $dist_output_tabs
}

function single_hadoop_dist(){
    print_bgblack_fggreen "single_hadoop_dist begin" $dist_output_tabs
    local ip=$1

    __single_file_dist $SOURCE_DIR $HADOOP_FILE $INSTALL_DIR $ip

    __single_zipfile_check $HADOOP_MD5_FILE $SOURCE_DIR $HADOOP_FILE $INSTALL_DIR $ip

    __single_unzipfile $HADOOP_FILE $INSTALL_DIR $ip
    
    print_bgblack_fggreen "single_hadoop_dist end" $dist_output_tabs

}

function local_dist_rpm() {
    print_bgblack_fggreen "local_dist_rpm begin" $dist_output_tabs
    file_dist $USER_NAME ${CLUSTER_LOCAL_IP} ${USER_NAME} $SOURCE_DIR $PARAFS_RPM $INSTALL_DIR
    local md5=`cat $SOURCE_DIR/$PARAFS_MD5_RPM |awk '{print $1}'`
    check_zip_file $USER_NAME ${CLUSTER_LOCAL_IP} ${USER_NAME} $md5 $INSTALL_DIR $PARAFS_RPM 

    file_dist $USER_NAME ${CLUSTER_LOCAL_IP} ${USER_NAME} $SOURCE_DIR $LLOG_RPM $INSTALL_DIR
    local md5=`cat $SOURCE_DIR/$LLOG_MD5_RPM |awk '{print $1}'`
    check_zip_file $USER_NAME ${CLUSTER_LOCAL_IP} ${USER_NAME} $md5 $INSTALL_DIR $LLOG_RPM 
    print_bgblack_fggreen "local_dist_rpm end" $dist_output_tabs
}

function local_dist_hadoop() {
    print_bgblack_fggreen "local_dist_hadoop begin" $dist_output_tabs
    file_dist $USER_NAME ${CLUSTER_LOCAL_IP} ${USER_NAME} $SOURCE_DIR $HADOOP_FILE $INSTALL_DIR

    local md5=`cat $SOURCE_DIR/$PARAFS_MD5_RPM |awk '{print $1}'`
    check_zip_file $USER_NAME ${CLUSTER_LOCAL_IP} ${USER_NAME} $md5 $INSTALL_DIR $HADOOP_FILE 

    unzip_file $USER_NAME $CLUSTER_LOCAL_IP $USER_NAME $INSTALL_DIR $HADOOP_FILE 
    print_bgblack_fggreen "local_dist_hadoop end" $dist_output_tabs
}
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
DIST_BASH_NAME=parafs_dist.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . ../variable.sh
fi
if [ -z ${COMMON_BASH_NAME} ] ; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_parafs.sh
fi
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi

dist_output_tabs="2"
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
#set -x
# cluster_dist_rpm
# cluster_dist_hadoop
# local_dist_rpm
# local_dist_hadoop
# echo $?
#set +x
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
