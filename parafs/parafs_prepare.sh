#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function prepare_usage() {
    echo "cluster-create-user"
    echo "cluster-user-authorize"
    echo "cluster-check-nodes"

    echo "cluster-config-hostname"
    echo "cluster-config-hosts"
    echo "cluster-script-dist"
    echo "cluster-install-package-dist"
#    echo "cluster-check-install-package"
    echo "cluster-unzip-install-package"
#    echo "cluster-yum-source"
    echo "cluster-yum-install"
#    echo "cluster-pip-source"
    echo "cluster-pip-install"
}

####### 根据配置文件PASSWD_CONFIG_FILE ip,在机器上创建新用户parauser 
####+++ return : 
function cluster_create_user() {
    local user_passwd_file=${USER_PASSWD}
    local username=`grep user $user_passwd_file | grep -v '^#' | awk -F "=" '{print $2}'`
    local userpasswd_ssl=`grep passwd_ssl $user_passwd_file | grep -v '^#' | awk -F "=" '{print $2}'`
    local userhome=`grep home $user_passwd_file | grep -v '^#' | awk -F "=" '{print $2}'`
    local usershell=`grep shell $user_passwd_file | grep -v '^#' | awk -F "=" '{print $2}'`
    local userpasswd=`grep passwd_plain $user_passwd_file | grep -v '^#' | awk -F "=" '{print $2}'`

    if [ -z $userpasswd_ssl ] || [ -z $userpasswd ] ; then
        echo "please generate a encrpt passwd config the conf/user_passwd"
        exit 1
    fi
    test -z "$username"  &&  username="parauser" 
    test -z "$userhome"  &&  userhome="/home/$username"
    test -z "$usershell" &&  usershell="/bin/bash"  

    #__cluster_check_user $username $userhome
    __cluster_check_user $username 

    __cluster_create_user $username $userpasswd_ssl $userhome $usershell

    __cluster_config_suders $username

    echo -e "\t\t cluster_create_user end"
}

###### 检查user是否已经存在，现在只检查了用户名。uid gid home未作检查
### grep parauser /etc/passwd
function __cluster_check_user() {
    local username=$1
#    local userhome=$2
#    local git=$3
#    local uid=$4
    local passwd_file="cat /etc/passwd"
#    local group_file="cat /etc/group"

    local fault_ips=""
    local filename=$PASSWD_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${ip}" = "x" ] ; then
             break;
         fi
         
         passwd=`grep ${ip} $filename |awk '{print $2 }'`
         user='root'
        
         ip_passwd_file=`$SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$passwd_file"`
         echo $ip_passwd_file | grep $username >/dev/null
         if [ $? -eq 0 ] ; then
             echo -e "\033[31m\t\tuser=$username exist at $ip \033[0m"
             fault_ips="$ip $fault_ips"
             # break;
         fi
#         # uid git 检查
#         echo $ip_passwd_file | grep $uid
#         if [ $? -eq 0 ] ; then
#              echo -e "\033[31m\t\tuid=$uid exist at $ip \033[0m"
#             fault_ips="$ip $fault_ips"
#             # break;
#         fi
#         group_passwd_file=`$SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$group_file"`
#         echo $group_passwd_file | grep $gid
#         if [ $? -eq 0 ] ; then
#             echo -e "\033[31m\t\t$ip connection error\033[0m"
#             fault_ips="$ip $fault_ips"
#             # break;
#         fi
#         # home 检查
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
    local username=$1
    local userpasswd_ssl=$2
    local userhome=$3
    local usershell=$4
    
    local create_user="useradd -d $userhome -m -U -p $userpasswd_ssl -s $usershell $username"

    local fault_ips=""
    local filename=$PASSWD_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${ip}" = "x" ] ; then
            break;
        fi
         
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        user='root'
        
        $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$create_user" >/dev/null
    done
    
    echo -e "\t\t __cluster_create_user end"
}

###### sudo 执行免密
#####  echo "parauser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
function __cluster_config_suders() {
    local username=$1
    local user_sudoer="echo '$username ALL=(ALL) NOPASSWD: ALL' >>/etc/sudoers"

    local fault_ips=""
    local filename=$PASSWD_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${ip}" = "x" ] ; then
            break;
        fi
         
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        user='root'
        
        $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$user_sudoer" >/dev/null
    done
    
    echo -e "\t\t __cluster_config_suders end"
}

###### cluster_user
######
function cluster_user_authorize() {
    local user_passwd_file=${USER_PASSWD}
    local username=`grep user $user_passwd_file | grep -v '^#' | awk -F "=" '{print $2}'`
    local userpasswd=`grep passwd_plain $user_passwd_file | grep -v '^#' | awk -F "=" '{print $2}'`
    local userhome=`grep home $user_passwd_file | grep -v '^#' | awk -F "=" '{print $2}'`
    test -z "$username"  &&  username="parauser" 
    test -z "$userhome"  &&  userhome="/home/$username"
    test -z "$usershell" &&  usershell="/bin/bash"  
    
    local filename=$PASSWD_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for outer_ip in $IPS; do
        if [ "x${outer_ip}" = "x" ] ; then
            break;
        fi
        for inner_ip in $IPS; do
            if [ "x${inner_ip}" = "x" ] ; then
                break;
            fi
#            echo "outer_ip=$outer_ip inner_ip=$inner_ip"
            echo "${outer_ip} ${username} ${userpasswd} ${userhome} ${inner_ip} ${username} ${userpasswd} ${userhome}"
            $SSH_EXP_AUTHORIZE ${outer_ip} ${username} ${userpasswd} ${userhome} \
                ${inner_ip} ${username} ${userpasswd} ${userhome}
        done
    done

    echo -e "\t\t cluster_user_authorize end"
}

####### 根据配置文件network修改hostname
####+++ parater: network_config
####+++ 
function cluster_script_dist() {
    local filename=$PASSWD_CONFIG_FILE
    # tar czvf
    # scp
    # tar xzvf
    echo -e "\t\t cluster_script_dist end"
    echo $?
}

####### 根据配置文件network修改hostname
####+++ 
function cluster_config_hostname() {
    local filename=$PASSWD_CONFIG_FILE
    echo -e "\t\t cluster_config_hostname end"
    echo $?
}

####### 根据配置文件network修改hosts
####+++ return :
function cluster_config_hosts() {
    local filename=$PASSWD_CONFIG_FILE
    echo -e "\t\t cluster_config_hosts end"
    echo $?
}

####### 根据配置文件network所有本机到所有机器 root免密登陆
####+++ return : 检查失败输出到屏幕，并且停止进行
function cluster_check_node() {
    local filename=$NETWORK_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    srcipt=""
    for ip in $IPS; do
        if [ "x${outer_ip}" = "x" ] ; then
            break;
        fi
        echo "ssh $user@$ip "$script" "
    done
    echo -e "\t\t cluster_check_node end"
}
####### 检查配置文件 network 是否存在并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function cluster_install_package_dist() {
    local ip_filename=
    local install_filename=
    # IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    ### 检查ips相同
    echo -e "\t\t cluster_install_package_dist done"
}

####### 检查配置文件 network 是否存在并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function cluster_check_install_package() {
    local ip_filename=
    local install_filename=
    #IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    ### 检查ips相同
    echo -e "\t\t cluster_check_install_package done"
}

####### 检查配置文件 network 是否存在并且network ip相同
####+++ return : 不存在直接退出,并给出提示信息。否则无返回信息
function cluster_unzip_install_package() {
    local ip_filename=
    local install_filename=
    # IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    ### 检查ips相同
    echo -e "\t\t cluster_unzip_install_package done"
}
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
PREPARE_BASH_NAME=parafs_prepare.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/parafs/common/common_utils.sh
fi


###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
cluster_create_user
# #     __cluster_check_user  parauser
# #     __cluster_create_user parauser "6615c5JbMtuqM"
# #     __cluster_config_suders parauser
cluster_user_authorize
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
