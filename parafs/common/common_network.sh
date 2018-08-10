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
    
    local temp_file="/tmp/parafs_config_hostname$authorize_ip"
    ## 检查hostname, /etc/hostname都对，否则设置hostname 修改/etc/hostname
    local command_condition_1="hostname | grep $set_hostname "
    local command_condition_2="grep $set_hostname /etc/hostname"
    local command_condition="$command_condition_1 || $command_condition_2"
    local command_set_hostname="hostname $set_hostname "
    local command_bak_hostname="cp /etc/hostname /etc/hostname.bak_para$authorize_ip"
    local command_update_hostname="echo $set_hostname |tee /etc/hostname "
    local remote_hostname="$command_condition || $command_set_hostname \
        && $command_bak_hostname && $command_update_hostname "
    echo "do config_hostname at $authorize_ip"
    sudo su - $local_user  -c "ssh '$authorize_user@$authorize_ip' '$remote_hostname'">$temp_file 
    #ssh "$authorize_user@$authorize_ip" "$remote_hostname" > $temp_file  
    return $?
} 

###### 远程设置hosts
### local_user
### authorize_ip
### authorize_user
### ip
### hostname
### alias
### 0 运行正常
### ret 0 成功配置 1 配置失败
function config_hosts() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local ip=$4
    local hostname=$5
    local alias=$6

    local temp_file="/tmp/parafs_config_hosts$authorize_ip$hostname"
    local command_condition="cat /etc/hosts |grep -v '^#' |grep $ip |grep $hostname |grep $alias"
    local command_bak_hosts="cp /etc/hosts /etc/hosts.bak_$alias"
    local command_update_hosts="echo '$ip $hostname $alias' |tee -a /etc/hosts"
    local remote_hosts="$command_condition || $command_bak_hosts && $command_update_hosts"
    echo "do config_hosts at $authorize_ip for $ip"
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_hosts'" >$temp_file
#    ssh "$authorize_user@$authorize_ip" "$remote_hosts" >$temp_file 

    return $?
    ### 验证配置情况 grep ip /etc/hosts 如果有两条认为有问题
#    ip_counts=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' 'cat /etc/hosts'" \
#        |grep -v '^#' |grep $ip |wc -l`
##    echo "ip_counts=$ip_counts"
#    test $((ip_counts)) -ne 1 && return 1 || return 0
}

# ###### 远程配置yum安装源
# function config_yum_source() {
#     local local_user=$1
#     local authorize_ip=$2
#     local authorize_user=$3
# 
#     local temp_file="/tmp/parafs_config_yum_source$authorize_ip"
#     local remote_command="ls -l"
#     sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >$temp_file
#     return $?
# }
# 
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

    echo "do config_ntpdate at $authorize_ip "
    local temp_file="/tmp/parafs_config_hosts$authorize_ip$hostname"
    local boot_script_file="/etc/rc.d/rc.local"
    local ntpdate_boot_condition="grep ntpdate /etc/rc.d/rc.local"
    local ntpdate_boot_append="echo 'ntpdate $ntp_hostname' | sudo tee -a /etc/rc.d/rc.local"
    local ntpdate_boot="$ntpdate_boot_condition || $ntpdate_boot_append"
    #sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$ntpdate_boot'" >$temp_file
    ssh '$authorize_user@$authorize_ip' '$ntpdate_boot'>$temp_file

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

    echo "do config_ntpdate at $authorize_ip "
    local temp_file="/tmp/parafs_config_hosts$authorize_ip$hostname"
    local ntpdate_cron_command="0 */1 *  *  * root  /usr/sbin/ntpdate -u $ntp_hostname "
    local ntpdate_cron_condition_1="test -f /etc/crontab"
    local ntpdate_cron_do_1="echo '$ntpdate_cron_command' |sudo tee /etc/crontab"
    local ntpdate_cron_condition_2="grep ntpdate /etc/crontab"
    local ntpdate_cron_do_2="echo '$ntpdate_cron_command' |sudo tee -a /etc/crontab"
    local ntpdate_cron="$ntpdate_cron_condition_1 || $ntpdate_cron_do_1 && $ntpdate_cron_condition_2 || $ntpdate_cron_do_2"
#    echo "sudo su - $local_user -c ssh '$authorize_user@$authorize_ip' '$ntpdate_cron'"
#    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$ntpdate_cron'" >$temp_file
    ssh '$authorize_user@$authorize_ip' '$ntpdate_cron'>$temp_file
    return $?
}


###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
NETWORK_BASH_NAME=common_network.sh
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# config_hostname parauser 192.168.138.71 parauser ht1.r1.x71
# echo $?
# config_hosts parauser 192.168.138.71 parauser 192.168.138.72 ht1.r2.n73 hia73
# echo $?
# config_ntpdate_boot parauser 192.168.138.71 parauser 192.168.1.151
# config_ntpdate_cron parauser 192.168.138.71 parauser 192.168.1.151
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
