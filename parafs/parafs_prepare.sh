#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function prepare_usage() {
    echo "cluster-create-user"
    echo "cluster-user-authorize"
    echo "cluster-script-dist"
    # echo "cluster-check-nodes"

    echo "cluster-config-hostname"
    echo "cluster-config-hosts"
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
    echo -e "\t\t cluster_create_user begin"
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

    __cluster_config_sudoers $username

    echo -e "\t\t cluster_create_user end"
}


###### cluster_user
######
function cluster_user_authorize() {
    echo -e "\t\t cluster_user_authorize begin"
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
            ssh_user_authorize ${outer_ip} ${username} ${userpasswd} ${userhome} \
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
    echo -e "\t\t cluster_script_dist begin"
    # 考虑到通用性使用zip 打包 unzip 解压
    zip_dir $BASE_DIR
    echo -e "\t\t cluster_script_dist end"
    echo $?
}

####### 根据配置文件network所有本机到所有机器 root免密登陆
####+++ return : 检查失败输出到屏幕，并且停止进行
function cluster_check_nodes() {
    echo -e "\t\t cluster_check_nodes begin"
    local filename=$NETWORK_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${outer_ip}" = "x" ] ; then
            break;
        fi
#        is_parafs_node_OK 
#        $SSH_EXP_LOGIN $ip $user $passwd $user_home | grep "login $ip successfully"  >/dev/null
        if [ $? -ne 0 ] ; then
            fault_ips="$ip $fault_ips"
            echo -e "\033[31m\t\t $ip /opt/wotung/note/0 fstat error \033[0m"
            # break;
        fi 
    done
    if [ ! -z "$fault_ips" ] ; then
        echo -e "\033[31m\t\tmake sure the node config\033[0m"
        exit 1;
    fi
    echo -e "\t\t cluster_check_nodes end"
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
if [ -z ${COMMON_BASH_NAME} ] ; then
    . /opt/wotung/parafs-install/parafs/common/common_parafs.sh
fi
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
# cluster_create_user
# cluster_user_authorize
# cluster_check_nodes
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
