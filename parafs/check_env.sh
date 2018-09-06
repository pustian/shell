#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function env_usage() {
    echo "check-local-install-files"
    echo "check-ips"
    echo "cluster-check-root-passwd"
    echo "cluster-check-nodes"
}

####### 配置文件相关检查已经在 需要安装文件在此处作检查
function check_local_install_files() {
    echo -e "check_local_install_files begin"
    if [ ! -d $SOURCE_DIR ] || [ ! -f $SOURCE_DIR/$PARAFS_RPM ] || [ ! -f $SOURCE_DIR/$PARAFS_MD5_RPM ] \
        || [ ! -f $SOURCE_DIR/$LLOG_RPM ] || [ ! -f $SOURCE_DIR/$LLOG_MD5_RPM ] \
        || [ ! -f $SOURCE_DIR/$HADOOP_FILE ] || [ ! -f $SOURCE_DIR/$HADOOP_MD5_FILE ] ; then 
        echo -e "\t\t \033[31m check local install file at $SOURCE_DIR and config at $MISC_CONF_FILE \033[0m"
        exit 1
    fi
    echo -e "check_local_install_files end\n"
}

####### 根据配置文件network检查ip连通状况
####+++ return : 检查失败输出到屏幕，并且停止进行
function check_address() {
    echo -e "check_address begin"
    local fault_ips="" 
    for ip in $CLUSTER_IPS; do
        is_conn $ip
        if [ $? -eq 0 ] ; then
            echo -e "\033[31m\t\t$ip connection error\033[0m"
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done

    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure the files $NETWORK_CONFIG_FILE and the networks\033[0m"
        exit 1
    fi
    echo -e "check_address end\n"
}

###集群检查internet连接
function cluster_check_internet(){
    echo -e "check_internet begin"
    local fail_node=""
    
    for ip in $CLUSTER_IPS; do
        internet_conn $ip "baidu.com"
        if [ $? -ne 0 ] ; then
            echo -e "\033[31m\t\t$ip to internet connection error\033[0m"
            fail_node="$ip $fail_node"
        else
            echo "internet connected at $ip"
        fi
    done

    if [ ! -z "$fail_node" ]; then
        echo -e "\033[31m\t\tcheck the internet connection of $fail_node\033[0m"
        exit 1
    fi

    echo -e "check_internet end\n"
}

####### 根据配置文件PASSWD_CONFIG_FILE 检查用户密码,
####+++ return : 
function cluster_check_passwd() {
    echo -e "cluster_check_passwd begin"
    local filename=$PASSWD_CONFIG_FILE
    
    fault_ips=""
    for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        #echo "ip=$ip DEFAULT_USER=$DEFAULT_USER passwd=******  DEFAULT_USER_HOME=$DEFAULT_USER_HOME"
        is_passwd_ok "$ip" "$DEFAULT_USER" "$passwd" "$DEFAULT_USER_HOME"
        if [ $? -ne 0 ]; then
            fault_ips="$ip $fault_ips"
            echo -e "\033[31m\t\tERROR: $ip $user passwd error\033[0m"
            # break;
        fi 
    done

    if [ ! -z "$fault_ips" ] ; then
        echo -e "\033[31m\t\tmake sure the passwd file with $DEFAULT_USER \033[0m"
        exit 1;
    fi
    echo -e "cluster_check_passwd end\n"
}

######
####### 检查/opt/wotung/node/0 目录，需要root免密登陆
####+++ return : 检查失败输出到屏幕，并且停止进行
function cluster_check_nodes() {
    echo -e "cluster_check_nodes begin"
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
            echo -e "\033[31m\t\tERROR: $ip /opt/wotung/node/0 error\033[0m"
            # break;
        fi 
    done

    if [ ! -z "$fault_ips" ] ; then
        echo -e "\033[31m\t\tmake sure /opt/wotung/node/0 \033[0m"
        exit 1;
    fi
    echo -e "cluster_check_nodes end\n"
}

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
CHECK_ENV_BASH_NAME=check_env.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . ../variable.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_utils.sh
fi

###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# check_local_install_files
# cluster_check_passwd
# cluster_check_nodes
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
