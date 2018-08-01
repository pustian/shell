#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function env_usage() {
    echo "check-config"
    echo "check-ips"
    echo "cluster-check-root-passwd"
    echo "cluster-check-nodes"
#    echo "cluster-config-hostname"
#    echo "cluster-config-hosts"
}

####### 检查配置文件 passwd network 是否存在并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function check_config() {
    if [ ! -f $PASSWD_CONFIG_FILE ] ; then
        echo -e "\033[31m\t\tconfig_file=$PASSWD_CONFIG_FILE not exists\033[0m"
        exit 1
    fi
    if [ ! -f $NETWORK_CONFIG_FILE ] ; then
        echo -e "\033[31m\t\tconfig_file=$PASSWD_CONFIG_FILE not exists\033[0m"
        exit 1
    fi
    ### 检查ips相同
    echo -e "\t\t check_config end"
}

####### 根据配置文件network检查ip连通状况
####+++ return : 检查失败输出到屏幕，并且停止进行
function check_ips() {
    local filename=$NETWORK_CONFIG_FILE
    
    local fault_ips="" 
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${ip}" = "x" ] ; then 
            break;
        fi
        is_conn $ip
        if [ $? -eq 0 ] ; then
            echo -e "\033[31m\t\t$ip connection error\033[0m"
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done

    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure that have fixed the network or modified the config file\033[0m"
        exit 1
    fi
    echo -e "\t\t check_ips end"
}

####### 根据配置文件PASSWD_CONFIG_FILE ip,在机器上创建新用户user 
####+++ return : 
function cluster_check_root_passwd() {
    local filename=$PASSWD_CONFIG_FILE
    
    fault_ips=""
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${ip}" = "x" ] ; then 
            break;
        fi
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        user='root'
        user_home='/root'
        $SSH_EXP_LOGIN $ip $user $passwd $user_home | grep "login $ip successfully"  >/dev/null
        if [ $? -ne 0 ]; then
            fault_ips="$ip $fault_ips"
            echo -e "\033[31m\t\t $ip $user passwd error\033[0m"
            # break;
        fi 
    done

    if [ ! -z "$fault_ips" ] ; then
        echo -e "\033[31m\t\tmake sure the passwd file\033[0m"
        exit 1;
    fi
    echo -e "\t\t cluster_check_root_passwd end"
}

######
###
####### 根据配置文件network所有本机到所有机器 root免密登陆
####+++ return : 检查失败输出到屏幕，并且停止进行

function cluster_check_nodes() {
    echo -e "\t\t cluster_check_nodes begin"
    local filename=$PASSWD_CONFIG_FILE
    
    fault_ips=""
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${ip}" = "x" ] ; then 
            break;
        fi
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        user='root'

        is_parafs_node_ok $ip $user $passwd
        if [ $? -eq 0 ]; then
            fault_ips="$ip $fault_ips"
            echo -e "\033[31m\t\t $ip /opt/wotung/node/0 error\033[0m"
            # break;
        fi 
    done

    if [ ! -z "$fault_ips" ] ; then
        echo -e "\033[31m\t\tmake sure /opt/wotung/node/0 \033[0m"
        exit 1;
    fi
    echo -e "\t\t cluster_check_nodes end"
}

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
CHECK_ENV_BASH_NAME=check-env.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/parafs/common/common_utils.sh
fi

###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# check_ips
# cluster_check_root_passwd
# cluster_check_nodes
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
