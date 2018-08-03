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
    capcity=`df -T |grep ${node_dir} |grep ${format} |awk '{print $3}' `
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
    
    capcity=`cat $temp_file |grep ${node_dir} |grep ${format} |awk '{print $3}' `
    # echo "[ ! -z ${capcity} ] && [ $((capcity)) -gt  $((_30G)) ] "
    if [ ! -z ${capcity} ] && [ $((capcity)) -gt  $((_30G)) ] ; then
        return 1
    else
        return 0
    fi
}

#  ###===========================================================================
#  ###### 远程判断是否存在用户
#  ### ip $1 远程ip
#  ### user $2 远程机器用户
#  ### passwd $3 远程机器用户密码
#  ### username $4 远程机器需要检查的用户
#  ### ret 0:存在用户 1:不存在用户
#  function is_no_parauser() {
#      local ip=$1
#      local user=$2
#      local passwd=$3
#      local username=$4
#  
#      local temp_file="/tmp/parafs_parauser_check$ip"
#      passwd_file="cat /etc/passwd"
#      echo "do is_no_parauser at $ip"
#      $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$passwd_file" >$temp_file
#      
#      cat $temp_file | grep $username  >/dev/null
#      return $?
#  }
#  
#  ###### 远程增加用户
#  ### ip $1 远程ip
#  ### user $2 远程机器用户
#  ### passwd $3 远程机器用户密码
#  ### username $4 远程机器需要检查的用户
#  ### userpasswd_ssl
#  ### userhome
#  ### usershell
#  function create_user() {
#      local ip=$1
#      local user=$2
#      local passwd=$3
#      local username=$4
#      local userpasswd_ssl=$5
#      local userhome=$6
#      local usershell=$7
#  
#      local temp_file="/tmp/parafs_create_user$ip"
#      create_user="sudo useradd -d $userhome -m -U -p $userpasswd_ssl -s $usershell $username"
#      echo "do create_user at $ip"
#      $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$create_user" >$temp_file
#      return $?
#  }
#  
#  ###### 远程增加修改sudoer 用户sudo免密
#  ### ip $1 远程ip
#  ### user $2 远程机器用户
#  ### passwd $3 远程机器用户密码
#  ### username $4 远程机器需要检查的用户
#  ### /etc/sudoers 行尾追加一行免密提升至root
#  function sudoer_nopasswd() {
#      local ip=$1
#      local user=$2
#      local passwd=$3
#      local username=$4
#      
#      local temp_file="/tmp/parafs_sudoer_nopasswd$ip"
#  #    sudo sed -i '$a parauser ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
#      nopasswd_sentence="$username ALL=(ALL) NOPASSWD: ALL"
#      user_sudoer="sudo sed -i '\$a $nopasswd_sentence' /etc/sudoers"
#      echo "do sudoer_nopasswd at $ip"
#      sudo $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$user_sudoer"  >$temp_file
#  }
#  
#  ###### 远程删除存在的用户
#  ### ip $1 远程ip
#  ### user $2 远程机器用户
#  ### passwd $3 远程机器用户密码
#  ### username $4 远程机器需要检查的用户
#  ### 注意如果username 用户正在使用则不能删除
#  function delete_user() {
#      local ip=$1
#      local user=$2
#      local passwd=$3
#      local username=$4
#  
#      local temp_file="/tmp/parafs_delete_user$ip"
#      delete_user="sudo userdel -r $username"
#      config_sudoer="sudo sed -i '/$username/'d /etc/sudoers "
#      echo "do delete_user at $ip"
#      $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$delete_user" >$temp_file
#      $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$config_sudoer" >>$temp_file
#  }
#  ###===========================================================================
#  ###### 当前current_ip上的用户current_user 免密登陆远程机器remote_ip上用户remote_user 
#  ### current_ip 
#  ### current_user
#  ### current_passwd
#  ### current_userhome
#  ### remote_ip
#  ### remote_user
#  ### remote_passwd
#  ### remote_userhome
#  function ssh_user_authorize() {
#      local current_ip=$1
#      local current_user=$2
#      local current_passwd=$3
#      local current_userhome=$4
#      local remote_ip=$5
#      local remote_user=$6
#      local remote_passwd=$7
#      local remote_userhome=$8
#  
#      local temp_file="/tmp/parafs_ssh_user_authorize$ip"
#      echo "do ssh_user_authorize at $current_ip to $remote_ip"
#      $SSH_EXP_AUTHORIZE ${current_ip} ${current_user} ${current_passwd} ${current_userhome} \
#          ${remote_ip} ${remote_user} ${remote_passwd} ${remote_userhome} >$temp_file
#  }
#  ###===========================================================================
#  ###### tar 压缩打包文件并生成md5文件
#  ### dirpath 绝对路径
#  function zip_dir() {
#      local dirpath=$1
#      if [ -z "$dirpath" ] ||  [ ! -d "$dirpath" ] ; then
#          echo "make sure $1 which mast be directory"
#          exit 1
#      fi
#      echo "zip_dir $dirpath"
#      current_pwd=`pwd`
#      dirname=`dirname $dirpath`
#      basename=`basename $dirpath`
#      zipfile=$basename.tgz 
#      md5file=$basename.md5sum
#      cd $dirname
#  #    sudo zip -q -r $zipfile $basename
#      sudo tar czf $zipfile $basename
#      sudo sh -c " md5sum $zipfile > $md5file "
#      sudo mv $dirname/$zipfile $current_pwd 
#      sudo mv $dirname/$md5file $current_pwd 
#      cd $current_pwd
#  }
#  ######
#  ### local_file
#  ### remote_ip
#  ### remote_user
#  ### remote_passwd
#  ### remote_path
#  function file_dist() {
#      local local_file=$1
#      local remote_ip=$2
#      local remote_user=$3
#      local remote_passwd=$4
#      local remote_path=$5
#  
#      local temp_file="/tmp/parafs_file_dist$ip"
#      echo "do dist $local_file to $remote_ip"
#      sudo $SSH_EXP_COPY ${local_file} ${remote_ip} ${remote_user} ${remote_passwd} ${remote_path}
#  }
#  ###### 通过md5sum 检查文件完整性
#  ### local_md5_file
#  ### zip_file
#  ### ip
#  ### user
#  ### passwd
#  ### 0 md5检查通过 1检查不通过
#  function is_zip_file_ok() {
#      local local_md5_file=$1
#      local zip_file=$2
#      local ip=$3
#      local user=$4
#      local passwd=$5
#  
#      local temp_file="/tmp/parafs_${zip_file}_check$ip"
#      zip_file_md5="sudo md5sum $zip_file"
#      $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$file_md5" > $temp_file
#      diff $local_md5_file $temp_file
#      return $?
#  }
#  
#  ###### 将文件解压到指定目录下
#  ### zip_file
#  ### path  解压指定目录
#  ### ip
#  ### user
#  ### passwd
#  ### 0 md5检查通过 1检查不通过
#  function unzip_file() {
#      local zip_file=$1
#      local path=$2
#      local ip=$3
#      local user=$4
#      local passwd=$5
#  
#      local temp_file="/tmp/parafs_${zip_file}_unzip$ip"
#  #    unzip_file_command="sudo unzip $zip_file"
#      unzip_file_command="sudo tar xzf $zip_file -C $path"
#      $SSH_REMOTE_EXEC "$ip" "$user" "$passwd"  "$unzip_file_command" >$temp_file
#      return $?
#  }
#  
#  ###### 以指定用户执行命令
#  ### su - parauser -c "ssh parauser@192.168.138.71 'sudo ls -l /opt' "
#  ### user 当前用户执行
#  ###
#  function user_ssh_remote_exec() {
#      local user=$1
#      local authorize_user=$2
#      local authoriz_ip=$3
#      local run_command=$4
#      su - $user -c "sudo ssh '$authorize_user@$authoriz_ip' '$run_command'"
#      return $?
#  }
#  ###===========================================================================
#  ###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
#  UTILS_BASH_NAME=common_utils.sh
#  if [ -z "$VARIABLE_BASH_NAME" ] ; then 
#      . /opt/wotung/parafs-install/variable.sh
#  fi
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
#  # ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
