#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###############################################################################
###### 以下指令执行指定ssh免密用户执行
###############################################################################
###
config_hostname() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3
    local set_hostname=$4
    
    local temp_file="/tmp/parafs_config_hostname$authoriz_ip"
    ## 检查hostname, /etc/hostname都对，否则设置hostname 修改/etc/hostname
    # sudo sed -i '$aABCDE' parafs_create_user192.168.138.70
    # truncate -s 0 /etc/hostname 清空/etc/hostname
    local command_condition_1="sudo hostname | grep $set_hostname "
    local command_condition_2="grep $set_hostname /etc/hostname"
    local command_condition="$command_condition_1 || $command_condition_2"
    local command_set_hostname="sudo hostname $set_hostname "
    local command_bak_hostname="sudo cp /etc/hostname /etc/hostname.bak"
    local command_update_hostname="echo $set_hostname |sudo tee /etc/hostname "
    local remote_hostname="$command_condition || $command_set_hostname && $command_update_hostname "
    echo "do config_hostname at $authorize_user"
    set -x
    sudo su - $local_user  -c "ssh $authorize_user@$authoriz_ip '$remote_hostname' ">$temp_file 
    set +x
    return $?
} 

# ###
# config_check_host() {
#     local local_user=$1
#     local authoriz_ip=$2
#     local authorize_user=$3
#     local hostname=$4
#     local alias=$5
# }

###
config_hosts() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3
    local hostname=$4
    local alias=$5

    local temp_file="/tmp/parafs_config_hosts$authoriz_ip$hostname"
    local remote_hosts="sudo cat /etc/hosts |grep -v '^#' |grep $authoriz_ip |grep $hostname |grep $alias  \
        || sudo sed -i '\$a$authoriz_ip $hostname $alias' /etc/hosts.bak "
    echo "do config_hosts at $authorize_user"
    echo "sudo su - $local_user -c \"ssh '$authorize_user@$authoriz_ip' '$remote_hosts'\" >$temp_file"
    # sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$remote_hostname'" >$temp_file
}

# 
# config_hadoop() {
# }
# 
# config_bashrc() {
# }


###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
config_hostname parauser 192.168.138.71 parauser ht1.r1.n71
# config_hosts parauser 192.168.138.71 parauser ht1.r2.n71 hia71
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
