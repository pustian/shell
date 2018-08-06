#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###############################################################################
###### parafs_prepare.sh cluster_create_user ---> common_parafs.sh
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
    for ip in $CLUSTER_IPS; do
         
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        # echo "sudoer_nopasswd ${ip} ${DEFAULT_USER} ${passwd} ${username}"
        sudoer_nopasswd ${ip} ${DEFAULT_USER} ${passwd} ${username}
    done
    
    echo -e "\t\t __cluster_config_sudoers end"
}

###############################################################################
###### parafs_prepare.sh cluster_dist ---> common_parafs.sh
###############################################################################
####### 免密后以免密用户分发文件
### 此处 dist_user用户下可以免密登陆 authorize_user@authorize_ip 
###      authorize_user 在remote_path 用户写权限
#### dist_file_path
#### dist_zip_file
#### remote_path
function __cluster_file_dist() {
    echo -e "\t\t __cluster_file_dist begin"
    local dist_file_path=$1
    local dist_zip_file=$2
    local remote_path=$3

    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        if [ ${ip} = ${CLUSTER_LOCAL_IP}  ] ; then
            continue
        fi
#        echo "file_dist $dist_file_path $dist_zip_file $USER_NAME ${ip} ${USER_NAME}  $remote_path"
        file_dist $USER_NAME ${ip} ${USER_NAME} $dist_file_path $dist_zip_file $remote_path
        if [ $? -ne 0 ] ; then 
            echo -e "\033[31m\t\tfile dist error to $ip \033[0m"
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
   
    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure the file dist \033[0m"
        exit 1
    fi
    echo -e "\t\t __cluster_file_dist end"
}

###### 免密后检查分发文件的md5
### 此处 dist_user用户下可以免密登陆 authorize_user@authorize_ip 
###      authorize_user 在remote_path 用户写权限
### zip_file
### zip_md5_file
function __cluster_zipfile_check() {
    echo -e "\t\t __cluster_zipfile_check begin"
    local zip_md5_file=$1
    local zip_file=$2
    local zip_file_dir=$3
    
    local md5=`cat ${zip_file_dir}/$zip_md5_file |awk '{print $1}'`
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        if [ ${ip} = ${CLUSTER_LOCAL_IP}  ] ; then
            continue
        fi
 #       echo "is_zip_file_ok $md5 $zip_file_dir $zip_file ${USER_NAME} $ip ${USER_NAME}"
        is_zip_file_ok ${USER_NAME} $ip ${USER_NAME} $md5 $zip_file_dir $zip_file 
        if [ $? -ne 0 ] ; then
            echo -e "\033[31m\t\tzip_file=$zip_file is damage at $ip \033[0m"
            fault_ips="$ip $fault_ips"
            # break;
        fi
        #file_dist $dist_filename $ip $user $passwd $remote_path
    done
    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure the file $zip_file at $zip_file_dir \033[0m"
        exit 1
    fi
    echo -e "\t\t __cluster_zipfile_check end"
}

###### 免密后检查分发文件解压
### 此处 dist_user用户下可以免密登陆 authorize_user@authorize_ip 
###      authorize_user 在remote_path 用户写权限
### zip_file $1
### zip_file_dir $2
function __cluster_unzipfile() {
    echo -e "\t\t __cluster_unzipfile begin"
    local zip_file=$1
    local zip_file_dir=$2

    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        if [ ${ip} = ${CLUSTER_LOCAL_IP}  ] ; then
            continue
        fi
#        echo "unzip_file $zip_file_dir $zip_file $USER_NAME $ip $USER_NAME"
        unzip_file $USER_NAME $ip $USER_NAME $zip_file_dir $zip_file
        if [ $? -ne 0 ] ; then
            echo -e "\033[31m\t\tfailed to unzip $zip_file at $ip \033[0m"
            fault_ips="$ip $fault_ips"
            # break;
        fi
        #file_dist $dist_filename $ip $user $passwd $remote_path
    done
    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure the file $zip_file at $zip_file_dir \033[0m"
        exit 1
    fi
    echo -e "\t\t __cluster_unzipfile end"
}

###### 免密后配置文件hostname 
function __cluster_config_hostname() {
    echo -e "\t\t __cluster_config_hostname begin"
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        local hostname=`grep $ip $NETWORK_CONFIG_FILE | awk '{print $2}'`
        # echo "config_hostname $USER_NAME $ip $USER_NAME $hostname"
        config_hostname $USER_NAME $ip $USER_NAME $hostname
        if [ $? -ne 0 ] ; then
            echo -e "\033[31m\t\tfailed to config hostname at $ip \033[0m"
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure the file /etc/hostname \033[0m"
        exit 1
    fi
    echo -e "\t\t __cluster_config_hostname end"
}

###### 免密后配置文件hosts
function __cluster_config_hosts() {
    echo -e "\t\t __cluster_config_hostname begin"
    local fault_ips=""
    for config_ip in $CLUSTER_IPS; do
        for cluster_ip in $CLUSTER_IPS; do
            local ip_hostname_alias=`grep $cluster_ip $NETWORK_CONFIG_FILE `
            local hostname=`echo $ip_hostname_alias | awk '{print $2}'`
            local hostalias=`echo $ip_hostname_alias | awk '{print $3}'`
            config_hosts $USER_NAME $config_ip $USER_NAME $cluster_ip $hostname $hostalias
            if [ $? -ne 0 ] ; then
                echo -e "\033[31m\t\tfailed to config hostname at $config_ip \033[0m"
                fault_ips="$config_ip $fault_ips"
                # break;
            fi
        done 
    done
    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure the file /etc/hosts \033[0m"
        exit 1
    fi
    echo -e "\t\t __cluster_config_hostname end"
}

###### slave 应该为空文件
function config_local_hadoop_slaves() {
    local slaves_file=$1
    test -f $slaves_file && sudo truncate -s 0 $slaves_file || sudo touch $slaves_file
    for ip in $CLUSTER_IPS; do
        echo $ip |sudo tee -a $slaves_file  
    done
}
function __cluster_hadoop_slave() {
    echo -e "\t\t __cluster_hadoop_slave begin"
    config_local_hadoop_slaves $HADOOP_SLAVES
    local dist_file_path=`dirname $HADOOP_SLAVES`
    local dist_zip_file=`basename $HADOOP_SLAVES`
    local remote_path=`dirname $HADOOP_SLAVES`
    __cluster_file_dist $dist_file_path $dist_zip_file $remote_path
    echo -e "\t\t __cluster_hadoop_slave end"
}
###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
COMMON_BASH_NAME=common_parafs.h
if [ -z "$VARIABLE_BASH_NAME" ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z "$UTILS_BASH_NAME" ]; then
    . ${BASE_DIR}/parafs/common/common_utils.sh
fi
if [ -z "$USER_BASH_NAME" ]; then
    . ${BASE_DIR}/parafs/common/common_user.sh
fi
if [ -z "$ZIP_BASH_NAME" ]; then
    . ${BASE_DIR}/parafs/common/common_zip.sh
fi
if [ -z "$CONFIG_BASH_NAME"]; then
    . ${BASE_DIR}/parafs/common/common_config.sh
fi
if [ -z "$COMMON_INSTALL_BASH_NAME"]; then
    . ${BASE_DIR}/parafs/common/common_install.sh
fi
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# __cluster_check_user parauser false
# __cluster_create_user  "parauser" "YdwAWdHXqldYI" "/home/parauser"  "/bin/bash"
# __cluster_config_sudoers parauser
# __cluster_file_dist  /opt/wotung parafs-install.tgz /opt/wotung
# __cluster_zipfile_check parafs-install.tar.gz.md5sum parafs-install.tar.gz /opt/wotung
# __cluster_unzipfile parafs-install.tgz /opt/wotung
#echo $?
######

# __cluster_config_hostname
# __cluster_config_hosts
# echo $?
# __config_hadoop_slaves parauser 192.168.138.70 parauser /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/slaves
# config_local_hadoop_slaves /opt/wotung/pusentian

# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
