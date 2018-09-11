#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function env_usage() {
    echo "check-local-install-files"
    echo "check-address"
    echo "local-install-expect"
    echo "cluster-check-root-passwd"
    echo "cluster-check-nodes"
}

####### 配置文件相关检查已经在 需要安装文件在此处作检查
function check_local_install_files() {
    print_bgblack_fggreen "check_local_install_files begin" $check_env_output_tabs
    test ! -d $SOURCE_DIR && print_bgblack_fgred "$SOURCE_DIR is not exist"
    test ! -f $SOURCE_DIR/$PARAFS_RPM  && print_bgblack_fgred "$SOURCE_DIR/$PARAFS_RPM is not exist" && exit 1
    test ! -f $SOURCE_DIR/$PARAFS_MD5_RPM && print_bgblack_fgred "$SOURCE_DIR/$PARAFS_MD5_RPM is not exist" && exit 1
    test ! -f $SOURCE_DIR/$LLOG_RPM && print_bgblack_fgred "$SOURCE_DIR/$LLOG_RPM is not exist" && exit 1
    test ! -f $SOURCE_DIR/$LLOG_MD5_RPM && print_bgblack_fgred "$SOURCE_DIR/$LLOG_MD5_RPM is not exist" && exit 1
    test ! -f $SOURCE_DIR/$HADOOP_FILE && print_bgblack_fgred "$SOURCE_DIR/$HADOOP_FILE is not exist" && exit 1
    test ! -f $SOURCE_DIR/$HADOOP_MD5_FILE && print_bgblack_fgred "$SOURCE_DIR/$HADOOP_MD5_FILE is not exist" && exit 1
    print_bgblack_fggreen "check_local_install_files end" $check_env_output_tabs
}

####### 根据配置文件network检查ip连通状况
####+++ return : 检查失败输出到屏幕，并且停止进行
function check_address() {
    print_bgblack_fggreen "check_address begin" $check_env_output_tabs
    local fault_ips="" 
    for ip in $CLUSTER_IPS; do
        is_conn $ip
        if [ $? -eq 0 ] ; then
            print_bgblack_fgred "$ip connection error" $check_env_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done

    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "make sure the files $NETWORK_CONFIG_FILE and the networks" $check_env_output_tabs
        exit 1
    fi
    print_bgblack_fggreen "check_address end" $check_env_output_tabs
}

###集群检查internet连接
function cluster_check_internet(){
    print_bgblack_fggreen "cluster_check_internet begin" $check_env_output_tabs
    local fail_node=""
    
    for ip in $CLUSTER_IPS; do
        internet_conn $ip "www.baidu.com"
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "ERROR: $ip to internet connection error" $check_env_output_tabs
            fail_node="$ip $fail_node"
        fi
    done

    if [ ! -z "$fail_node" ]; then
        print_bgblack_fgred "check the internet connection of $fail_node" $check_env_output_tabs
        exit 1
    fi
    print_bgblack_fggreen "cluster_check_internet end" $check_env_output_tabs
}

###安装expect
function local_install_expect() {
    print_bgblack_fggreen "local_install_expect begin" $check_env_output_tabs
    
    print_msg "which expect"
    which expect
    if test $? -ne 0 ; then
        print_msg "rpm -ivh ${SCRIPT_BASE_DIR}/download/expect/*.rpm"
        ret=`rpm -ivh ${SCRIPT_BASE_DIR}/download/expect/*.rpm`
        print_result "$ret"
    fi
    print_bgblack_fggreen "local_install_expect end" $check_env_output_tabs
}



####### 根据配置文件PASSWD_CONFIG_FILE 检查用户密码,
####+++ return : 
function cluster_check_passwd() {
    print_bgblack_fggreen "cluster_check_passwd begin" $check_env_output_tabs
    local filename=$PASSWD_CONFIG_FILE
    
    fault_ips=""
    for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        #echo "ip=$ip DEFAULT_USER=$DEFAULT_USER passwd=******  DEFAULT_USER_HOME=$DEFAULT_USER_HOME"
        is_passwd_ok "$ip" "$DEFAULT_USER" "$passwd" "$DEFAULT_USER_HOME"
        if [ $? -ne 0 ]; then
            fault_ips="$ip $fault_ips"
            print_bgblack_fgred "ERROR: $ip $user passwd error" $check_env_output_tabs
            # break;
        fi 
    done

    if [ ! -z "$fault_ips" ] ; then
        print_bgblack_fgred "make sure the passwd file with $DEFAULT_USER at $fault_ips" $check_env_output_tabs
        exit 1;
    fi
    print_bgblack_fggreen "cluster_check_passwd end" $check_env_output_tabs
}

######
####### 检查/opt/wotung/node/0 目录，需要root免密登陆
####+++ return : 检查失败输出到屏幕，并且停止进行
function cluster_check_nodes() {
    print_bgblack_fggreen "cluster_check_nodes begin" $check_env_output_tabs
    local filename=$PASSWD_CONFIG_FILE

    fault_ips=""
    for ip in $CLUSTER_IPS; do
        if [ "x${ip}" = "x" ] ; then 
            break;
        fi
        passwd=`grep ${ip} $filename |awk '{print $2 }'`

        is_parafs_node_ok $ip $DEFAULT_USER $passwd
        if [ $? -eq 0 ]; then
            fault_ips="$ip $fault_ips"
            print_bgblack_fgred "ERROR: $ip /opt/wotung/node/0 error" $check_env_output_tabs
            # break;
        fi 
    done

    if [ ! -z "$fault_ips" ] ; then
        print_bgblack_fgred "make sure /opt/wotung/node/0 at $fault_ips" $check_env_output_tabs
        exit 1;
    fi
    print_bgblack_fggreen "cluster_check_nodes end" $check_env_output_tabs
}

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
CHECK_ENV_BASH_NAME=check_env.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . ../variable.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_utils.sh
fi
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi
check_env_output_tabs="2"
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# check_local_install_files
# cluster_check_passwd
# cluster_check_nodes
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
