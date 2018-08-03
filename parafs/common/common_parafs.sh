#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

###### 检查user是否已经存在，现在只检查了用户名。uid gid home未作检查
### username $1
### is_exist $2 true/false true 检查$username是否存在
### grep parauser /etc/passwd
function __cluster_check_user() {
    echo -e "\t\t __cluster_check_user begin"
    local username=$1
    local is_exist=$2

    for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $PASSWD_CONFIG_FILE |awk '{print $2 }'`
        is_no_parauser "$ip" "$DEFAULT_USER" "$passwd" ${username}
        if [ $? -eq 0 ] ; then 
            if [ x${is_exist} = x"false" ] ; then
                echo -e "\033[31m\t\tuser=$username exist at $ip \033[0m"
                fault_ips="$ip $fault_ips"
                # break;
            fi
        else
            if [ x${is_exist} = x"true" ]; then
                echo -e "\033[31m\t\tuser=$username not exist at $ip \033[0m"
                fault_ips="$ip $fault_ips"
                # break;
            fi
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
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $PASSWD_CONFIG_FILE |awk '{print $2 }'`
        #echo "create_user ${ip} ${DEFAULT_USER} ${passwd} ${USER_NAME} ${USER_PASSWD_SSL} ${USER_HOME} ${USER_SHELL}"      
        create_user ${ip} ${DEFAULT_USER} ${passwd} ${USER_NAME} ${USER_PASSWD_SSL} ${USER_HOME} ${USER_SHELL}
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

####### 免密后以免密用户分发文件
#### dist_filename
#### remote path
#function __cluster_file_dist() {
#    echo -e "\t\t __cluster_config_sudoers begin"
#    local dist_filename=$1
#    local remote_path=$2
#    local filename=$PASSWD_CONFIG_FILE
#    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
#    for ip in $IPS; do
#        if [ "x${ip}" = "x" ] ; then
#            break;
#        fi
#         
#        passwd=`grep ${ip} $filename |awk '{print $2 }'`
#        user='root'
#        file_dist $dist_filename $ip $user $passwd $remote_path
#    done
#}
#
####### 检查分发文件的md5
#### zip_file
#### zip_md5_file
#function __cluster_zipfile_check() {
#    local zip_file=$1
#    local zip_md5_file=$2
#
#    local fault_ips=""
#    local filename=$PASSWD_CONFIG_FILE
#    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
#    for ip in $IPS; do
#        if [ "x${ip}" = "x" ] ; then
#            break;
#        fi
#         
#        passwd=`grep ${ip} $filename |awk '{print $2 }'`
#        user='root'
#
#        is_zip_file_ok $zip_md5_file $zip_file $ip $user $passwd
#        if [ $? -eq 0 ] ; then
#            echo -e "\033[31m\t\tzip_file=$zip_file is damage at $ip \033[0m"
#            fault_ips="$ip $fault_ips"
#            # break;
#        fi
#        #file_dist $dist_filename $ip $user $passwd $remote_path
#    done
#    if [ ! -z "$fault_ips" ]; then
#        echo -e "\033[31m\t\tmake sure the user\033[0m"
#        exit 1
#    fi
#    echo "__cluster_zipfile_check end"
#}
#
####### 
####
####
#function __cluster_unzipfile() {
#    local zip_file=$1
#
#    local fault_ips=""
#    local filename=$PASSWD_CONFIG_FILE
#    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
#    for ip in $IPS; do
#        if [ "x${ip}" = "x" ] ; then
#            break;
#        fi
#         
#        passwd=`grep ${ip} $filename |awk '{print $2 }'`
#        user='root'
#
#        unzip_file $zip_file $ip $user $passwd
#        if [ $? -eq 0 ] ; then
#            echo -e "\033[31m\t\tfailed to unzip $zip_file at $ip \033[0m"
#            fault_ips="$ip $fault_ips"
#            # break;
#        fi
#        #file_dist $dist_filename $ip $user $passwd $remote_path
#    done
#    echo "__cluster_unzipfile end"
#    
#}
###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
COMMON_BASH_NAME=common_parafs.h
if [ -z "$VARIABLE_BASH_NAME" ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z "$UTILS_BASH_NAME" ]; then
    . /opt/wotung/parafs-install/parafs/common/common_utils.sh
fi
if [ -z "$USER_BASH_NAME" ]; then
    . /opt/wotung/parafs-install/parafs/common/common_user.sh
fi
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# __cluster_check_user parauser false
# __cluster_create_user  "parauser" "YdwAWdHXqldYI" "/home/parauser"  "/bin/bash"
# __cluster_config_sudoers parauser
#__cluster_file_dist  /opt/wotung/parafs-install.zip /opt/wotung
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
