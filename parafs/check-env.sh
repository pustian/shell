#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function env_usage() {
    echo "check-config"
    echo "check-ips"
    echo "cluster-check-root-passwd"
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
#    local filename=$NETWORK_CONFIG_FILE
#    IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
#    unconnected_exist=false
#    for ip in $IPS; do
#        is_conn $ip
#        if [ $? = "0" ] ; then
#            echo -e "\033[31m\t\t$ip connection error\033[0m"
#            unconnected_exist=true
#        fi
#    done
#    if [ x${unconnected_exist} = x"true" ]; then
#        echo -e "\033[31m\t\tmake sure that have fixed the network or modified the config file\033[0m"
#        exit 1
#    fi
    echo -e "\t\t check_ips end"
}

####### 根据配置文件PASSWD_CONFIG_FILE ip,在机器上创建新用户user 
####+++ return : 
function cluster_check_root_passwd() {
    local filename=$PASSWD_CONFIG_FILE
    cat $filename | grep -v '^#' | while read readline
    do
        ip=`echo "$readline" |awk '{print $1 }'`
        passwd=`echo "$readline" |awk '{print $2 }'`
        user='root'
        user_home='/root'
#        echo "ip=$ip passwd=$passwd"
#        $SSH_EXP_LOGIN $ip $user $passwd $user_home |grep "$user login $ip successfully"
#        if [ $? != "0" ]; then
#            echo -e "\033[31m\t\tconfig_file=$PASSWD_CONFIG_FILE not exists\033[0m"
#        fi 
    done
    echo -e "\t\t cluster_check_root_passwd end"
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
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
