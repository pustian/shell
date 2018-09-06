#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###### parafs_prepare.sh cluster_create_user ---> common_parafs.sh create_user
###############################################################################
###### 远程判断是否存在用户
###### 检查/etc/passwd
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
    remote_passwd_command="cat /etc/passwd"
    echo "do is_no_parauser at $ip"
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$remote_passwd_command" >$temp_file
    
    cat $temp_file | grep $username  >/dev/null
    return $?
}

###### 远程增加用户
###### useradd -d $userhome -m -U -p $userpasswd_ssl -s $usershell $username"
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

    local temp_file="/tmp/parafs_create_user$ip"
    local remote_create_user="sudo useradd -d $userhome -m -U -p $userpasswd_ssl -s $usershell $username"
    echo "do create_user at $ip"
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$remote_create_user" >$temp_file
}

###### 远程增加修改sudoer 用户sudo免密
###### /etc/sudoers 行尾追加一行免密提升至root
### ip $1 远程ip
### user $2 远程机器用户
### passwd $3 远程机器用户密码
### username $4 远程机器需要检查的用户
function sudoer_nopasswd() {
    local ip=$1
    local user=$2
    local passwd=$3
    local username=$4
    
    local temp_file="/tmp/parafs_sudoer_nopasswd$ip"
#    sudo sed -i '$a parauser ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
    nopasswd_sentence="$username ALL=(ALL) NOPASSWD: ALL"
    local parauser_condition="grep $username /etc/sudoers |grep NOPASSWD"
    local remote_user_sudoer=" $parauser_condition || sudo sed -i '\$a $nopasswd_sentence' /etc/sudoers"
    echo "do sudoer_nopasswd at $ip"
    sudo $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$remote_user_sudoer"  >$temp_file
}

###############################################################################
###### parafs_prepare.sh cluster_user_authorize
###############################################################################
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

    local temp_file="/tmp/parafs_ssh_user_authorize$ip"
    echo -e "\tdo ssh_user_authorize at $current_user@$current_ip to $remote_user@$remote_ip"
    $SSH_EXP_AUTHORIZE ${current_ip} ${current_user} ${current_passwd} ${current_userhome} \
        ${remote_ip} ${remote_user} ${remote_passwd} ${remote_userhome} >$temp_file
}

#####复制master机器上的authorized_keys到远程的机器
function copy_authorized_keys(){
	local master_ip=$1
	local each_ip=$2

	echo -e "\tdo copy_authorized_keys to $each_ip"
	local temp_file="/tmp/parafs_copy_authorized_keys$each_ip"
	scp ~/.ssh/authorized_keys root@$each_ip:~/.ssh/authorized_keys >$temp_file
}

#####复制master机器上的known_hosts到远程的机器
function copy_known_hosts(){
	local master_ip=$1
	local each_ip=$2

	echo -e "\tdo copy_known_hosts to $each_ip"
	local temp_file="/tmp/parafs_copy_known_hosts$each_ip"
	scp ~/.ssh/known_hosts root@$each_ip:~/.ssh/known_hosts >$temp_file
}

function ssh_user_login() {
    local current_ip=$1
    local current_user=$2
    local current_passwd=$3
    local remote_ip=$4
    local remote_user=$5
    local remote_passwd=$6

    local temp_file="/tmp/parafs_ssh_user_login$ip"
    echo "do ssh_user_login at $current_user@$current_ip to $remote_user@$remote_ip"
    $SSH_EXP_SECOND_LOGIN ${current_ip} ${current_user} ${current_passwd} \
        ${remote_ip} ${remote_user} ${remote_passwd} >$temp_file
}
###############################################################################
###### parafs_tools.sh 
###############################################################################
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

    local temp_file="/tmp/parafs_delete_user$ip"
    delete_user="sudo userdel -r $username"
    config_sudoer="sudo sed -i '/$username/'d /etc/sudoers "
    echo "do delete_user at $ip"
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$delete_user" >$temp_file
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$config_sudoer" >>$temp_file
}

###### 远程修改目录的所有者
### remote_ip $1 远程ip
### remote_user $2 远程机器用户
### remote_passwd $3 远程机器用户密码
### dirpath $4 需要变更目录
### username $5 变更后所有者
### groupname $6 变更后所有这
###### 
function dirpath_root_chown() {
    local remote_ip=$1
    local remote_user=$2
    local remote_passwd=$3
    local dirpath=$4
    local username=$5
    local groupname=$6

    # sudo chown -R parauser:parauser /opt/wotung
    local temp_file="/tmp/parafs_create_user$remote_ip"
    local remote_chown="sudo chown -R $username:$groupname $dirpath"
    echo "do dirpath_root_chown $dirpath at $remote_ip"
    $SSH_REMOTE_EXEC "$remote_ip" "$remote_user" "$remote_passwd" "$remote_chown" >$temp_file
}
###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
USER_BASH_NAME=common_user.sh
if [ -z "$VARIABLE_BASH_NAME" ] ; then 
    . ../../variable.sh
fi
###++++++++++++++++++++++++      main  end        ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
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
#######
# dirpath_root_chown 192.168.138.72 root Tianpusen@1 /opt/wotung parauser parauser
# dirpath_root_chown 192.168.1.99 parafs tianpusen /opt/wotung parafs parafs
#ssh_user_login "192.168.138.71" 'parauser' "hetong@2015" "192.168.138.71" 'parauser' "hetong@2015"
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
