#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

###### 检查user是否已经存在，现在只检查了用户名。uid gid home未作检查
### grep parauser /etc/passwd
function __cluster_check_user() {
    echo -e "\t\t __cluster_check_user begin"
    local username=$1

    local fault_ips=""
    local filename=$PASSWD_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${ip}" = "x" ] ; then
             break;
         fi
         
         passwd=`grep ${ip} $filename |awk '{print $2 }'`
         user='root'
        
         is_no_parauser "$ip" "$user" "$passwd" ${username}
         if [ $? -eq 0 ] ; then
             echo -e "\033[31m\t\tuser=$username exist at $ip \033[0m"
             fault_ips="$ip $fault_ips"
             # break;
         fi
    done
   
    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure the user\033[0m"
        exit 1
    fi
    echo -e "\t\t __cluster_check_user end"
}

###### 创建用户
### 注意此处 -p 后面参数需要使用openssl passwd 生成
### useradd -d /home/parauser -m -U -p 'YdwAWdHXqldYI' -s '/bin/bash'  parauser
function __cluster_create_user() {
    echo -e "\t\t __cluster_create_user begin"
    local username=$1
    local userpasswd_ssl=$2
    local userhome=$3
    local usershell=$4

    local fault_ips=""
    local filename=$PASSWD_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${ip}" = "x" ] ; then
            break;
        fi
         
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        user='root'
        create_user ${ip} ${user} ${passwd} ${username} ${userpasswd_ssl} ${userhome} ${usershell}      
    done
    
    echo -e "\t\t __cluster_create_user end"
}

###### sudo 执行免密
#####  echo "parauser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
function __cluster_config_sudoers() {
    echo -e "\t\t __cluster_config_sudoers begin"
    local username=$1

    local fault_ips=""
    local filename=$PASSWD_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${ip}" = "x" ] ; then
            break;
        fi
         
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        user='root'
        
        sudoer_nopasswd ${ip} ${user} ${passwd} ${username}
    done
    
    echo -e "\t\t __cluster_config_sudoers end"
}

###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
COMMON_BASH_NAME=common_parafs.h
if [ -z "$VARIABLE_BASH_NAME" ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z "$UTILS_BASH_NAME" ]; then
    . /opt/wotung/parafs-install/parafs/common/common_utils.sh
fi
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# __cluster_check_user parafs
#__cluster_create_user  "parauser" "YdwAWdHXqldYI" "/home/parauser"  "/bin/bash"
# __cluster_config_sudoers parauser
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
