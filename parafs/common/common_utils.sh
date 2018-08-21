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
#####################################################################
###### 免密升级sudoer用户不需要密码 修改文件所有用户
function dirpath_sudoer_chown() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local dirpath=$4
    local username=$5
    local groupname=$6

    echo "do dirpath at $authorize_ip"
    local temp_file="/tmp/parafs_dirpath_sudoer_chown$authorize_ip"
    local remote_command="sudo chown -R $username:$groupname $dirpath"
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >>$temp_file
    return $?
}

### 远程执行某个命令
function remote_excute_cmd() {
	local local_user=$1
	local remote_user=$2
	local remote_ip=$3
	local remote_cmd=$4
	
	local log_file="/tmp/parafs_remote_excute_cmd"
	sudo su - $local_user -c "ssh '$remote_user@$remote_ip' '$remote_cmd'" >>$log_file
}

###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
UTILS_BASH_NAME=common_utils.sh
if [ -z "$VARIABLE_BASH_NAME" ] ; then 
    . ../..//variable.sh
fi
#  # ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
  # is_conn "ht1.r1.n72"
  # is_local_parafs_node_OK 
  # is_passwd_ok 192.168.1.12 'root' '' '/root'
  # echo $?
  # is_parafs_node_ok 192.168.138.71 "root" "Tianpusen@1" 
  # echo $?
  # is_parafs_node_ok 192.168.138.70 "parafs" "tianpusen" 
  # dirpath_sudoer_chown parauser 192.168.138.71 parauser /opt/wotung/hadoop-parafs parauser parauser
  # echo $?
#  # ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
