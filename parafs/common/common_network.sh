#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###############################################################################
###### 以下指令执行指定ssh免密用户执行
###############################################################################
###### 远程设置hostname
### local_user
### authorize_ip
### authorize_user
### set_hostname 
### 0 运行正常
function config_hostname() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local set_hostname=$4
    
    ## 检查hostname, /etc/hostname都对，否则设置hostname 修改/etc/hostname
    local command_condition_1="hostname | grep $set_hostname "
    local command_condition_2="grep $set_hostname /etc/hostname"
    local command_condition="$command_condition_1 || $command_condition_2"
    local command_set_hostname="hostname $set_hostname "
    local command_bak_hostname="cp /etc/hostname /etc/hostname.bak_para$authorize_ip"
    local command_update_hostname="echo $set_hostname |tee /etc/hostname "
    local remote_hostname="$command_condition || $command_set_hostname \
        && ( $command_bak_hostname && $command_update_hostname ) "
    print_bgblack_fgwhite "function call .....config_hostname..... at $authorize_ip" $common_network_output_tabs
    print_msg "ssh '$authorize_user@$authorize_ip' '$remote_hostname'"
    ret=`sudo su - $local_user  -c "ssh '$authorize_user@$authorize_ip' '$remote_hostname'" `
    print_result "$ret"
    #ssh "$authorize_user@$authorize_ip" "$remote_hostname" > $temp_file  
    # return $?
} 

###### 增加comment
### local_user
### authorize_ip
### authorize_user
### comment
### 0 运行正常
### ret 0 成功配置 1 配置失败
function config_hosts_comment() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local comment=$4

    local command_condition="cat /etc/hosts |grep \"^$comment\""
    local command_update_hosts="echo \"$comment\" |tee -a /etc/hosts"
    local remote_hosts="$command_condition || $command_update_hosts"
    print_bgblack_fgwhite "function call .....config_hostname..... at $authorize_ip" $common_network_output_tabs
    print_msg "ssh '$authorize_user@$authorize_ip' '$remote_hosts'"
    ret=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_hosts'"`
    print_result "$ret"
    # return $?
}

## 单机配置/etc/hosts
#function local_config_hosts(){
#    # get array of whole_ip_long_short 
#    local array_ip=(`cat ${NETWORK_CONFIG_FILE} | grep -v '^#' | awk -F " " '{print $1}'`)
#    local array_long=(`cat ${NETWORK_CONFIG_FILE} | grep -v '^#' | awk -F " " '{print $2}'`)
#    local array_short=(`cat ${NETWORK_CONFIG_FILE} | grep -v '^#' | awk -F " " '{print $3}'`)
#
#    # concatnate these three
#    local size=${#array_ip[*]}
#    local array_whole=()
#    for(( i=0; i<$size; i++ ))
#    do
#        array_whole[$i]="${array_ip[$i]} ${array_long[$i]} ${array_short[$i]}"
#    done
#    
#    # if found ip, change this line with array_whole[i]
#    # if can't find ip, add array_whole[i]
#    local file_hosts=/etc/hosts
#    for(( i=0; i<$size; i++ ))
#    do
#        cat $file_hosts | grep ${array_ip[$i]} >> /dev/null
#        if [ $? = 0 ];then
#            # found ip 
#            local line_num=`grep ${array_ip[$i]} $file_hosts -n | awk -F ":" '{print $1}'`
#            sed -i "${line_num}c ${array_whole[$i]}" $file_hosts
#        else
#            # can't find ip
#            echo ${array_whole[$i]} | tee -a $file_hosts >> /dev/null
#        fi
#    done
#}


function config_hosts() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local ip=$4
    local hostname=$5
    local alias=$6

    local command_condition="cat /etc/hosts |grep -v '^#' |grep $ip |grep $hostname |grep $alias"
    local command_update_hosts="echo '$ip $hostname $alias' |tee -a /etc/hosts"
    local remote_hosts="$command_condition || $command_update_hosts"
    print_bgblack_fgwhite "function call .....config_hosts..... at $authorize_ip" $common_network_output_tabs
    print_msg "ssh '$authorize_user@$authorize_ip' '$remote_hosts'"
    ret=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_hosts'" `
    print_result "$ret"
#    ssh "$authorize_user@$authorize_ip" "$remote_hosts" >$temp_file 

    return $?
    ### 验证配置情况 grep ip /etc/hosts 如果有两条认为有问题
#    ip_counts=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' 'cat /etc/hosts'" \
#        |grep -v '^#' |grep $ip |wc -l`
##    echo "ip_counts=$ip_counts"
#    test $((ip_counts)) -ne 1 && return 1 || return 0
}

###### 远程配置yum安装源
function config_yum_source() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    print_bgblack_fgwhite "function call ..... config_yum_source at $authorize_ip" $common_network_output_tabs

    local cp_command="cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo`date +%y%m%d%H%M%S`"
    local curl_command="curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo"
    local yum_cache="yum makecache"
    local remote_command="$cp_command && $curl_command && $yum_cache"
    print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_command'\" "
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" 
    return $?
}

# ###### 远程配置yum安装源
# function config_pip_source() {
#     local local_user=$1
#     local authorize_ip=$2
#     local authorize_user=$3
# 
#     local temp_file="/tmp/parafs_config_pip_source$authorize_ip"
#     local remote_command="ls -l"
#     sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >$temp_file
#     return $?
# }

###### 远程设置启动时钟同步
### local_user=$1
### authorize_ip=$2
### authorize_user=$3
### ntp_hostname=$4
### ret 0 成功配置 1 配置失败
function config_ntpdate_boot() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local ntp_hostname=$4

    local temp_file="/tmp/parafs_config_hosts$authorize_ip$hostname"
    local boot_script_file="/etc/rc.d/rc.local"
    local ntpdate_boot_condition="grep ntpdate /etc/rc.d/rc.local"
    local ntpdate_boot_append="echo 'ntpdate $ntp_hostname' | sudo tee -a /etc/rc.d/rc.local"
    local ntpdate_boot="$ntpdate_boot_condition || $ntpdate_boot_append"
    #sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$ntpdate_boot'" >$temp_file
    print_bgblack_fgwhite "function call .....config_ntpdate_boot..... at $authorize_ip" $common_network_output_tabs
    ssh "$authorize_user@$authorize_ip" "$ntpdate_boot">$temp_file

    return $?
}

###### 远程设置时钟同步计划
### local_user=$1
### authorize_ip=$2
### authorize_user=$3
### ntp_hostname=$4
function config_ntpdate_cron() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local ntp_hostname=$4

    local temp_file="/tmp/parafs_config_hosts$authorize_ip$hostname"
    local ntpdate_cron_command="0 */1 *  *  * root  /usr/sbin/ntpdate -u $ntp_hostname "
    local ntpdate_cron_condition_1="test -f /etc/crontab"
    local ntpdate_cron_do_1="echo '$ntpdate_cron_command' |sudo tee /etc/crontab"
    local ntpdate_cron_condition_2="grep ntpdate /etc/crontab"
    local ntpdate_cron_do_2="echo '$ntpdate_cron_command' |sudo tee -a /etc/crontab"
    local ntpdate_cron="$ntpdate_cron_condition_1 || $ntpdate_cron_do_1 && $ntpdate_cron_condition_2 || $ntpdate_cron_do_2"
#    echo "sudo su - $local_user -c ssh '$authorize_user@$authorize_ip' '$ntpdate_cron'"
#    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$ntpdate_cron'" >$temp_file
    print_bgblack_fgwhite "function call .....config_ntpdate_cron..... at $authorize_ip" $common_network_output_tabs
    ssh "$authorize_user@$authorize_ip" "$ntpdate_cron">$temp_file
    return $?
}

###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
NETWORK_BASH_NAME=common_network.sh
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi
common_network_output_tabs="4"
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# config_hostname parauser 192.168.138.71 parauser ht1.r1.x71
# echo $?
# config_hosts parauser 192.168.138.71 parauser 192.168.138.72 ht1.r2.n73 hia73
# config_hosts root 192.168.1.15 root 192.168.138.72 ht1.r2.n73 hia73
# echo $?
# config_ntpdate_boot parauser 192.168.138.71 parauser 192.168.1.151
# config_ntpdate_cron parauser 192.168.138.71 parauser 192.168.1.151
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
