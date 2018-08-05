#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###### check-env.sh
###############################################################################
####### 检查该ip/hostname 是否可连通，通过ping 作
####+++ parater: hostname/ip 
####+++ return : 1 检查通过 0 ping不通
function is_conn() {
    local hostname=$1
    echo "do is_conn at $hostname"
    pass_pattern="4 packets transmitted, 4 received, 0% packet loss"
    ret=`ping $hostname -c 4 | grep "$pass_pattern"`
    test x = x"$ret" && return 0 || return 1
}

####### 检查该conf/passwd中配置的操作用户 密码正确性,
####### 操作用户可以设置在 conf/user_passwd
####### 操作用户只能是root 或是 sudo可以免密执行的用户
function is_passwd_ok() {
    local ip=$1
    local username=$2
    local userpasswd=$3
    local userhome=$4

    local temp_file="/tmp/parafs_${usernamer}_passwd_$ip"
    echo "do is_passwd_ok at $ip"

    $SSH_EXP_LOGIN $ip $username $userpasswd $userhome >$temp_file
    cat $temp_file| grep "login $ip successfully"  >/dev/null
    return $?
}

####### 检查/opt/wotung/node/0 目录已被ext4文件挂在并且大小>=30G
####+++ return : 1通过成功 0 失败
function is_local_parafs_node_OK() {
    local node_dir="/opt/wotung/node/0"
    local format="ext4"
    local _30G=30831523
    # local _30G=30831525
    echo "do is_local_parafs_node_OK "
    local capcity=`df -T |grep ${node_dir} |grep ${format} |awk '{print $3}' `
    if [ ! -z ${capcity} ] && [ $((capcity)) -gt  $((_30G)) ] ; then
        return 1
    else
        return 0
    fi
}

####### 检查/opt/wotung/node/0 目录已被ext4文件挂在并且大小>=30G
####+++ return : 1通过成功 0 失败
function is_parafs_node_ok() {
    local ip=$1
    local user=$2
    local passwd=$3
    local dfnode="df -T"

    local temp_file="/tmp/parafs_node_check$ip"
    local node_dir="/opt/wotung/node/0"
    local format="ext4"
    local _30G=30831523
    echo "do is_parafs_node_ok at $ip"
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$dfnode" >$temp_file
    
    local capcity=`cat $temp_file |grep ${node_dir} |grep ${format} |awk '{print $3}' `
    # echo "[ ! -z ${capcity} ] && [ $((capcity)) -gt  $((_30G)) ] "
    if [ ! -z ${capcity} ] && [ $((capcity)) -gt  $((_30G)) ] ; then
        return 1
    else
        return 0
    fi
}

###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
UTILS_BASH_NAME=common_utils.sh
if [ -z "$VARIABLE_BASH_NAME" ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
#  # ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
#  # is_conn "ht1.r1.n72"
#  # is_local_parafs_node_OK 
#  # echo $?
#  # is_parafs_node_ok 192.168.138.71 "root" "Tianpusen@1" 
#  # echo $?
#  # is_parafs_node_ok 192.168.138.70 "parafs" "tianpusen" 
#  # echo $?
#  ###########
#  # is_no_parauser 192.168.138.70 "root" "Tianpusen@1" "parauser" 
#  # echo $?
#  # is_no_parauser 192.168.138.71 "root" "Tianpusen@1" "parauser"
#  # echo $?
#  # is_no_parauser 192.168.138.72 "root" "Tianpusen@1" "parauser"
#  # echo $?
#  # is_no_parauser 192.168.138.73 "root" "Tianpusen@1" "parauser"
#  # echo $?
#  ###########
#  # delete_user 192.168.138.70 "parafs" "tianpusen" "parauser" 
#  # create_user "192.168.138.70" "parafs" "tianpusen" "parauser" "YdwAWdHXqldYI" "/home/parauser" "/bin/bash"
#  # sudoer_nopasswd "192.168.138.70" "parafs" "tianpusen" "parauser" 
#  # sudoer_nopasswd "192.168.138.71" "root" "Tianpusen@1" "parauser" 
#  # echo $?
#  ##########
#  # ssh_user_authorize "192.168.138.71" 'parauser' "hetong@2015" "/home/parauser"  \
#  #     "192.168.138.71" "parauser" "hetong@2015" "/home/parauser"
#  # root用户执行
#  # zip_dir /opt/wotung/parafs-install
#  #######
# dirpath_chown 192.168.138.72 root Tianpusen@1 /opt/wotung parauser parauser
# dirpath_chown 192.168.1.99 parafs tianpusen /opt/wotung parafs parafs
#  # ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
