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
    ## 检查hostname /etc/hostname都对，否则设置hostname
    # sudo sed -i '$aABCDE' parafs_create_user192.168.138.70
    local remote_hostname="sudo hostname | grep $set_hostname || grep $set_hostname /etc/hostname
            || sudo hostname $set_hostname 
            && sudo cp /etc/hostname /etc/hostname.bak && sudo sed -i '\$a$set_hostname'  /etc/hostname.bak"
    echo "do config_hostname at $authorize_user"
    sudo su - $local_user  -c "ssh '$authorize_user@$authoriz_ip' '$remote_hostname'" >$temp_file
    return $?
} 

# ###
# config_check_host() {
#     local local_user=$1
#     local authoriz_ip=$2
#     local authorize_user=$3
#     local ip=$4
#     local hostname=$5
#     local alias=$6
# }

###
config_hosts() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3
    local ip=$4
    local hostname=$5
    local alias=$6

    local temp_file="/tmp/parafs_config_hosts$ip$hostname"
    local remote_hosts="sudo cat /etc/hosts |grep -v '^#' |grep $ip |grep $hostname |grep $alias 
        || sudo sed -i '\$a$ip $hostname $alias' /etc/hosts.bak "
    echo "do config_hosts at $authorize_user"
    sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$remote_hostname'" >$temp_file
}

# 
# config_hadoop() {
# }
# 
# config_bashrc() {
# }

