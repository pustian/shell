#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
####### 检查该ip/hostname 是否可连通，通过ping 作
####+++ parater: hostname/ip 
####+++ return : 1 检查通过 0 ping不通
function is_conn() {
    local hostname=$1
    pass_pattern="4 packets transmitted, 4 received, 0% packet loss"
    ret=`ping $hostname -c 4 | grep "$pass_pattern"`
    test x = x"$ret" && return 0 || return 1
}

####### hostname修改 /etc/hostname
####+++ parater: ip 
####+++ parater: hostname 
####+++ return : 1成功 0 失败
function set_hostname() {
    local ip=$1
    local hostname=$2

}

####### hostname修改 /etc/hosts
####+++ parater: ip
####+++ parater: hostname 机器hostname
####+++ parater: alias 机器短名
####+++ return : 1成功 0 失败
function set_hosts() {
    local ip=$1
    local hostname=$2
    local alias=$3

}

####### arr is stop same
####+++ 数组1
####+++ 数组2
####+++ return : 1成功 0 失败
function is_same_arr() {
    return 1
}

####### 检查/opt/wotung/node/0 目录已被ext4文件挂在并且大小>30G
####+++ return : 1通过成功 0 失败
function is_parafs_node_OK() {
    local node_dir="/opt/wotung/node/0"
    local format="ext4"
    # local _30G=30831524
    local _30G=30831525
    capcity=`df -T |grep ${node_dir} |grep ${format} |awk '{print $3}' `
    if [ ! -z ${capcity} ] && [ $((capcity)) -gt  $((_30G)) ] ; then
        return 1
    else
        return 0
#         echo -e "\033[31m\t\t\tcheck that mount /dev/XXX /opt/wotung/node/0 with ext4 format\033[0m"
#     else
#         if [ $((capcity)) -lt  $((_30G)) ] ; then
#             echo -e "\033[31m\t\t\tcheck that the capcity of /opt/wotung/node/0 must be more than 30G\033[0m"
#        fi
    fi
}

####### 检查 parafs-hadoop.tar.gz 文件是否存在, 并且md5sum 正确。
####+++ parater: md5sum_filepath
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function is_parafs_hadoop_eixst {
    echo $0
}

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
UTILS_BASH_NAME=common_utils.sh

# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# read_ips /home/parafs/parafs-install/config/passwd
# is_connectable "ht1.r1.n72"
# is_parafs_node_OK
# echo $?
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
