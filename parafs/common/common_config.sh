#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###############################################################################
###### 以下指令执行指定ssh免密用户执行
###############################################################################
###### 远程设置hostname
### zip_file_dir 解压指定目录
### zip_file
### local_user
### authorize_ip
### authorize_user
### 0 运行正常
function config_hostname() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local set_hostname=$4
    
    local temp_file="/tmp/parafs_config_hostname$authorize_ip"
    ## 检查hostname, /etc/hostname都对，否则设置hostname 修改/etc/hostname
    local command_condition_1="sudo hostname | grep $set_hostname "
    local command_condition_2="grep $set_hostname /etc/hostname"
    local command_condition="$command_condition_1 || $command_condition_2"
    local command_set_hostname="sudo hostname $set_hostname "
    local command_bak_hostname="sudo cp /etc/hostname /etc/hostname.bak_para$authorize_ip"
    local command_update_hostname="echo $set_hostname |sudo tee /etc/hostname "
    local remote_hostname="$command_condition || $command_set_hostname \
            && $command_bak_hostname && $command_update_hostname "
    echo "do config_hostname at $authorize_ip"
    sudo su - $local_user  -c "ssh $authorize_user@$authorize_ip '$remote_hostname' ">$temp_file 
    return $?
} 

# ###
# config_check_host() {
#     local local_user=$1
#     local authorize_ip=$2
#     local authorize_user=$3
#     local hostname=$4
#     local alias=$5
# }

###
### ret 0 成功配置 1 配置失败
function config_hosts() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local ip=$4
    local hostname=$5
    local alias=$6

    local temp_file="/tmp/parafs_config_hosts$authorize_ip$hostname"
    local command_condition="sudo cat /etc/hosts |grep -v '^#' |grep $ip |grep $hostname |grep $alias"
    local command_bak_hosts="sudo cp /etc/hosts /etc/hosts.bak_$alias"
    local command_update_hosts="echo '$ip $hostname $alias' |sudo tee -a /etc/hosts"
    local remote_hosts="$command_condition || $command_bak_hosts && $command_update_hosts"
    echo "do config_hosts at $authorize_ip for $ip"
    # echo "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_hosts'\" >$temp_file"
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_hosts'" >$temp_file
    ### 验证配置情况 grep ip /etc/hosts 如果有两条认为有问题
    ip_counts=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' 'cat /etc/hosts'" \
        |grep -v '^#' |grep $ip |wc -l`
#    echo "ip_counts=$ip_counts"
    test $((ip_counts)) -ne 1 && return 1 || return 0
}

# 
# function config_hadoop() {
# }
# 
# function config_bashrc() {
# }


###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
CONFIG_BASH_NAME=common_config.sh
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# config_hostname parauser 192.168.138.71 parauser ht1.r1.x71
# echo $?
# config_hosts parauser 192.168.138.71 parauser 192.168.138.72 ht1.r2.n73 hia73
# echo $?
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
