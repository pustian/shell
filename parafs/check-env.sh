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
}

####### 检查配置文件 passwd network 是否存在, 并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function check_config() {
    if [ ! -f $PASSWD_CONFIG_FILE ] ; then
        echo -e "\033[31m\t\tconfig_file=$PASSWD_CONFIG_FILE not exists\033[0m"
        exit 1
    fi
    if [ ! -f $NETWORK_CONFIG_FILE ] ; then
        echo -e "\033[31m\t\tconfig_file=$NETWORK_CONFIG_FILE not exists\033[0m"
        exit 1
    fi

    local fault_ips="" 
    for ip in $CLUSTER_IPS ; do
        grep $ip $PASSWD_CONFIG_FILE >/dev/null
        if [ $? -ne 0 ] ; then
            echo -e "\033[31m\t\t$ip not eixst at ${PASSWD_CONFIG_FILE}\033[0m"
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure the files $NETWORK_CONFIG_FILE and $PASSWD_CONFIG_FILE \033[0m"
        exit 1
    fi
    echo -e "\t\t check_config end"
}

####### 根据配置文件network检查ip连通状况
####+++ return : 检查失败输出到屏幕，并且停止进行
function check_ips() {
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
    echo -e "\t\t check_ips end"
}

####### 根据配置文件PASSWD_CONFIG_FILE 检查用户密码,
####+++ return : 
function cluster_check_passwd() {
    echo -e "\t\t cluster_check_passwd begin"
    local filename=$PASSWD_CONFIG_FILE
    
    fault_ips=""
    for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        
        is_passwd_ok $ip $DEFAULT_USER $passwd $DEFAULT_USER_HOME
        if [ $? -ne 0 ]; then
            fault_ips="$ip $fault_ips"
            echo -e "\033[31m\t\t $ip $user passwd error\033[0m"
            # break;
        fi 
    done

    if [ ! -z "$fault_ips" ] ; then
        echo -e "\033[31m\t\tmake sure the passwd file with $DEFAULT_USER \033[0m"
        exit 1;
    fi
    echo -e "\t\t cluster_check_passwd end"
}

######
####### 根据配置文件network所有本机到所有机器 root免密登陆
####+++ return : 检查失败输出到屏幕，并且停止进行
function cluster_check_nodes() {
    echo -e "\t\t cluster_check_nodes begin"
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
# check_config
# check_ips
# cluster_check_passwd
# cluster_check_nodes
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
