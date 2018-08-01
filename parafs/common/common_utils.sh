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
    echo "do is_conn at $hostname"
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
    echo "do is_parafs_node_OK"
    capcity=`df -T |grep ${node_dir} |grep ${format} |awk '{print $3}' `
    if [ ! -z ${capcity} ] && [ $((capcity)) -gt  $((_30G)) ] ; then
        return 1
    else
        return 0
#         echo -e "\033[31m\t\t\tcheck that mount /dev/XXX /opt/wotung/node/0 with ext4 format\033[0m"
#         return 1
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
###===========================================================================
###### 远程判断是否存在用户
### ip $1 远程ip
### user $2 远程机器用户
### passwd $3 远程机器用户密码
### username $4 远程机器需要检查的用户
### ret 0:存在用户 1:不存在用户
function is_no_parauser() {
    local ip=$1
    local user=$2
    local passwd=$3
    local username=$4
    local temp_file="/tmp/parafs_parauser_check$ip"

    passwd_file="cat /etc/passwd"
    echo "do is_no_parauser at $ip"
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$passwd_file" >$temp_file
    
    cat $temp_file | grep $username  >/dev/null
    ret=$?
    # rm $temp_file
    return $ret
}

###### 远程增加用户
### ip $1 远程ip
### user $2 远程机器用户
### passwd $3 远程机器用户密码
### username $4 远程机器需要检查的用户
### userpasswd_ssl
### userhome
### usershell
function create_user() {
    local ip=$1
    local user=$2
    local passwd=$3
    local username=$4
    local userpasswd_ssl=$5
    local userhome=$6
    local usershell=$7

    create_user="sudo useradd -d $userhome -m -U -p $userpasswd_ssl -s $usershell $username"
    echo "do create_user at $ip"
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$create_user" >/dev/null
}

###### 远程增加修改sudoer 用户sudo免密
### ip $1 远程ip
### user $2 远程机器用户
### passwd $3 远程机器用户密码
### username $4 远程机器需要检查的用户
### /etc/sudoers 行尾追加一行免密提升至root
function sudoer_nopasswd() {
    local ip=$1
    local user=$2
    local passwd=$3
    local username=$4
    
#    sudo sed -i '$a parauser ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
    nopasswd_sentence="$username ALL=(ALL) NOPASSWD: ALL"
    user_sudoer="sudo sed -i '\$a $nopasswd_sentence' /etc/sudoers"
    echo "do sudoer_nopasswd at $ip"
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$user_sudoer"  >/dev/null
}

###### 远程删除存在的用户
### ip $1 远程ip
### user $2 远程机器用户
### passwd $3 远程机器用户密码
### username $4 远程机器需要检查的用户
### 注意如果username 用户正在使用则不能删除
function delete_user() {
    local ip=$1
    local user=$2
    local passwd=$3
    local username=$4

    delete_user="sudo userdel -r $username"
    config_sudoer="sudo sed -i '/$username/'d /etc/sudoers "
    echo "do delete_user at $ip"
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$delete_user" >/dev/null
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$config_sudoer" >/dev/null
}
###===========================================================================
###### 当前current_ip上的用户current_user 免密登陆远程机器remote_ip上用户remote_user 
### current_ip 
### current_user
### current_passwd
### current_userhome
### remote_ip
### remote_user
### remote_passwd
### remote_userhome
function ssh_user_authorize() {
    local current_ip=$1
    local current_user=$2
    local current_passwd=$3
    local current_userhome=$4
    local remote_ip=$5
    local remote_user=$6
    local remote_passwd=$7
    local remote_userhome=$8
    echo "do ssh_user_authorize at $current_ip"
    $SSH_EXP_AUTHORIZE ${current_ip} ${current_user} ${current_passwd} ${current_userhome} \
        ${remote_ip} ${remote_user} ${remote_passwd} ${remote_userhome} >/dev/null
}
###===========================================================================
###### 压缩文件并生成md5文件
### dirpath 绝对路径
function zip_dir() {
    local dirpath=$1
    if [ -z "$dirpath" ] ||  [ ! -d "$dirpath" ] ; then
        echo "make sure $1 which mast be directory"
        exit 1
    fi
    current_pwd=`pwd`
    dirname=`dirname $dirpath`
    basename=`basename $dirpath`
    zipfile=$basename.zip 
    md5file=$basename.md5sum
    cd $dirname
    sudo zip -q -r $zipfile $basename
    sudo sh -c " md5sum $zipfile > $md5file "
    cd $current_pwd
    sudo mv $dirname/$zipfile $current_pwd 
    sudo mv $dirname/$md5file $current_pwd 
}
###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
UTILS_BASH_NAME=common_utils.sh
if [ -z "$VARIABLE_BASH_NAME" ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# is_conn "ht1.r1.n72"
# is_parafs_node_OK
# echo $?
###########
# is_no_parauser 192.168.138.70 "root" "Tianpusen@1" "parauser" 
# echo $?
# is_no_parauser 192.168.138.71 "root" "Tianpusen@1" "parauser"
# echo $?
# is_no_parauser 192.168.138.72 "root" "Tianpusen@1" "parauser"
# echo $?
# is_no_parauser 192.168.138.73 "root" "Tianpusen@1" "parauser"
# echo $?
###########
# delete_user 192.168.138.70 "parafs" "tianpusen" "parauser" 
# create_user "192.168.138.70" "parafs" "tianpusen" "parauser" "YdwAWdHXqldYI" "/home/parauser" "/bin/bash"
# sudoer_nopasswd "192.168.138.70" "parafs" "tianpusen" "parauser" 
# sudoer_nopasswd "192.168.138.71" "root" "Tianpusen@1" "parauser" 
# echo $?
##########
# ssh_user_authorize "192.168.138.71" 'parauser' "hetong@2015" "/home/parauser"  \
#     "192.168.138.71" "parauser" "hetong@2015" "/home/parauser"
# root用户执行
# zip_dir /opt/wotung/parafs-install
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
