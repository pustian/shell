#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function prepare_usage() {
    echo "cluster-create-user"
    echo "cluster-user-authorize"
    echo "cluster-config-network"
    echo "local-script-zip"
    echo "cluster-script-dist"
    echo "cluster-root-chown"
}

####### 根据配置文件PASSWD_CONFIG_FILE ip,在机器上创建新用户parauser 
####+++ return : 
function cluster_create_user() {
    print_bgblack_fggreen "cluster_create_user begin" $prepare_output_tabs
    #__cluster_check_user $username $userhome
    # 检查没有创建过parauser用户
    __cluster_check_user $USER_NAME false

    __cluster_create_user $USER_NAME $USER_PASSWD_SSL $USER_HOME $USER_SHELL

    __cluster_config_sudoers $USER_NAME
    ## 检查用户创建成功
    __cluster_check_user $USER_NAME true

    print_bgblack_fggreen "cluster_create_user end" $prepare_output_tabs
}

###### 用户免密  n*n ssh_user_authorize==>common_user.sh
function cluster_user_authorize() {
    print_bgblack_fggreen "cluster_user_authorize begin" $prepare_output_tabs
    
    for outer_ip in $CLUSTER_IPS; do
        for inner_ip in $CLUSTER_IPS; do
            ssh_user_authorize ${outer_ip} ${USER_NAME} ${USER_PASSWD} ${USER_HOME} \
                ${inner_ip} ${USER_NAME} ${USER_PASSWD} ${USER_HOME}
        done
    done

    print_bgblack_fggreen "cluster_user_authorize end" $prepare_output_tabs
}
###### 用户hostname alias 登陆
function cluster_each_user_login() {
    local filename=$NETWORK_CONFIG_FILE
    for outer_ip in $CLUSTER_IPS; do
        for inner_ip in $CLUSTER_IPS; do
            local hostname=`grep $inner_ip $filename | awk '{print $2}'`
            local alias=`grep $inner_ip $filename | awk '{print $3}'`
            # echo "${outer_ip} ${user_name} ${user_passwd} ${hostname} ${user_name} ${user_passwd}"
            ssh_user_login ${outer_ip} ${user_name} ${user_passwd} \
                ${hostname} ${user_name} ${user_passwd}  >/dev/null &
        done
    done
}

###### 用户免密   ssh_user_authorize==>common_user.sh
function cluster_root_authorize() {
    print_bgblack_fggreen "cluster_root_authorize begin" $prepare_output_tabs

    local filename=$PASSWD_CONFIG_FILE
    local user_name='root'
    local user_home='/root'

    local master_ip=$MASTER_IP
    local user_passwd=`grep ${master_ip} $filename |awk '{print $2 }'`
	# 从master到各机器，再从各机器到master免密
    for each_ip in $CLUSTER_IPS; do
		#master to each
        ssh_user_authorize ${master_ip} ${user_name} ${user_passwd} ${user_home} \
               			   ${each_ip} ${user_name} ${user_passwd} ${user_home} 
    done

	for each_ip in $CLUSTER_IPS; do
		#each to master, exclude master->master
		if test $master_ip != $each_ip; then
			ssh_user_authorize ${each_ip} ${user_name} ${user_passwd} ${user_home} \
						 	   ${master_ip} ${user_name} ${user_passwd} ${user_home}
		fi
	done
	
	#复制authorized_keys和known_hosts 
	for each_ip in $CLUSTER_IPS; do
		copy_authorized_keys $master_ip $each_ip
		copy_known_hosts $master_ip $each_ip
	done

    print_bgblack_fggreen "cluster_root_authorize end" $prepare_output_tabs
}

### 这一步要在配置好/etc/hosts和/etc/hostname之后
function cluster_alias_authorize(){
    print_bgblack_fggreen "cluster_alias_authorize begin" $prepare_output_tabs
	
	local master_ip=$MASTER_IP
	# 长名、短名的免密
	local ip_longname=`cat ${NETWORK_CONFIG_FILE} |grep -v '^#' | awk -F " " '{print $2}'`
	local ip_shortname=`cat ${NETWORK_CONFIG_FILE} |grep -v '^#' | awk -F " " '{print $3}'`

	for each_longname in $ip_longname; do
        print_bgblack_fgwhite "login from $each_longname to $master_ip by expect" "(($prepare_output_tabs+1))"
        print_msg "$SCRIPT_BASE_DIR/parafs/expect_common/ssh_alias_login.exp $each_longname " 
		ret=`$SCRIPT_BASE_DIR/parafs/expect_common/ssh_alias_login.exp $each_longname`
        print_result "$ret"
	done
	for each_shortname in $ip_shortname; do
        print_bgblack_fgwhite "login from $each_shortname to $master_ip by expect" "(($prepare_output_tabs+1))"
        print_msg "$SCRIPT_BASE_DIR/parafs/expect_common/ssh_alias_login.exp $each_shortname "
		ret=`$SCRIPT_BASE_DIR/parafs/expect_common/ssh_alias_login.exp $each_shortname` 
        print_result "$ret"
	done
	
	#复制authorized_keys和known_hosts 
	for each_ip in $CLUSTER_IPS; do
        print_bgblack_fgwhite "copy authorized_keys known_hosts to $each_ip" "(($prepare_output_tabs+1))"
		copy_authorized_keys $master_ip $each_ip
		copy_known_hosts $master_ip $each_ip
	done
    print_bgblack_fggreen "cluster_alias_authorize end" $prepare_output_tabs
}

### 集群关闭防火墙
function cluster_close_firewalld(){
    print_bgblack_fggreen "cluster_close_firewalld begin" $prepare_output_tabs

    #执行两条命令
    local cmd_disable="systemctl disable firewalld"
    local cmd_stop="systemctl stop firewalld"
    cluster_cmd "$cmd_disable && $cmd_stop"
    #本地执行sed，复制到远程
    local firewall_file="/etc/selinux/config"
    config_SELINUX
    cluster_sync_file $firewall_file
    # 禁用、关闭NetworkManager
    local cmd_dis_manager="systemctl disable NetworkManager"
    local cmd_stop_manager="systemctl stop NetworkManager"
    cluster_cmd "$cmd_dis_manager && $cmd_stop_manager"
    
    print_bgblack_fggreen "cluster_close_firewalld end" $prepare_output_tabs

}

### 单节点关闭防火墙
function single_close_firewalld(){
    local ip=$1
    print_bgblack_fggreen "cluster_close_firewalld begin" $prepare_output_tabs

    #执行两条命令
    local cmd_disable="systemctl disable firewalld"
    local cmd_stop="systemctl stop firewalld"
    single_cmd "$cmd_disable && $cmd_stop" $ip
    #本地执行sed，复制到远程
    local firewall_file="/etc/selinux/config"
    config_SELINUX
    single_sync_file $firewall_file $ip

    # 禁用、关闭NetworkManager
    local cmd_dis_manager="systemctl disable NetworkManager"
    local cmd_stop_manager="systemctl stop NetworkManager"
    single_cmd "$cmd_dis_manager && $cmd_stop_manager"
    
    print_bgblack_fggreen "cluster_close_firewalld end" $prepare_output_tabs
}

###### 用户hostname alias 登陆
function cluster_each_root_login() {
    local filename=$PASSWD_CONFIG_FILE
    local network=$NETWORK_CONFIG_FILE
    local user_name='root'
    local user_home='/root'
    for outer_ip in $CLUSTER_IPS; do
        local outer_user_passwd=`grep ${outer_ip} $filename |awk '{print $2 }'`
        for inner_ip in $CLUSTER_IPS; do
            local hostname=`grep $inner_ip $network | awk '{print $2}'`
            local alias=`grep $inner_ip $network | awk '{print $3}'`
            local inner_user_passwd=`grep ${inner_ip} $filename |awk '{print $2 }'`
            # echo "${outer_ip} ${user_name} ${outer_user_passwd} ${hostname} ${user_name} ${inner_user_passwd}"
            ssh_user_login "192.168.138.71" 'parauser' "hetong@2015" "192.168.138.71" 'parauser' "hetong@2015"
            ssh_user_login ${outer_ip} ${user_name} ${outer_user_passwd} \
                ${hostname} ${user_name} ${inner_user_passwd} >/dev/null 
            ssh_user_login ${outer_ip} ${user_name} ${outer_user_passwd} \
                ${alias} ${user_name} ${inner_user_passwd} >/dev/null 
        done
    done
}

####### 各机器上配置文件,/etc/hosts /etc/hostname
function cluster_config_network() {
    print_bgblack_fggreen "cluster_config_network begin" $prepare_output_tabs

    __cluster_config_hostname
    
    __cluster_config_hosts

    print_bgblack_fggreen "cluster_config_network end" $prepare_output_tabs
}

###集群检查internet连接
function cluster_check_internet(){
    print_bgblack_fggreen "cluster_check_internet begin" $check_env_output_tabs
    local fail_node=""
    
    for ip in $CLUSTER_IPS; do
        internet_conn $ip "www.baidu.com"
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "ERROR: $ip to internet connection error" $check_env_output_tabs
            fail_node="$ip $fail_node"
        fi  
    done

    if [ ! -z "$fail_node" ]; then
        print_bgblack_fgred "check the internet connection of $fail_node" $check_env_output_tabs
        exit 1
    fi  
    print_bgblack_fggreen "cluster_check_internet end" $check_env_output_tabs
}

### 单结点远程检查internet连接
function single_check_internet(){
    local ip=$1
    print_bgblack_fggreen "single_check_internet begin" $check_env_output_tabs
    local fail_node=""
    
    internet_conn $ip "www.baidu.com"
    if [ $? -ne 0 ] ; then
        print_bgblack_fgred "ERROR: $ip to internet connection error" $check_env_output_tabs
        fail_node="$ip $fail_node"
    fi  

    if [ ! -z "$fail_node" ]; then
        print_bgblack_fgred "check the internet connection of $fail_node" $check_env_output_tabs
        exit 1
    fi  
    print_bgblack_fggreen "single_check_internet end" $check_env_output_tabs

}

####### 本地压缩parafs-install/生成安装包，并生成md5 
function local_script_zip() {
    print_bgblack_fggreen "local_script_zip begin" $prepare_output_tabs
    zip_dir $USER_NAME $CLUSTER_LOCAL_IP $USER_NAME $SCRIPT_BASE_DIR `dirname $SCRIPT_BASE_DIR`
    zip_file=`basename $SCRIPT_BASE_DIR`.tar.gz
    file_md5sum $USER_NAME $CLUSTER_LOCAL_IP $USER_NAME `dirname $SCRIPT_BASE_DIR`/$zip_file
    print_bgblack_fggreen "local_script_zip end" $prepare_output_tabs
}

####### 分发安装脚本到各机器上,方便配置文件同步
function cluster_script_dist() {
    print_bgblack_fggreen "cluster_script_dist begin" $prepare_output_tabs
#    local script_zip_file=parafs-install.tar.gz
#    local script_zip_md5_file=parafs-install.md5sum
    local script_basedir=`dirname $SCRIPT_BASE_DIR`
    local script_file=`basename $SCRIPT_BASE_DIR`.tar.gz
    local script_md5_file=${script_file}.md5sum

    __cluster_file_dist $script_basedir $script_file $script_basedir

    __cluster_zipfile_check $script_md5_file $script_basedir $script_file $script_basedir

    __cluster_unzipfile $script_file $script_basedir

    print_bgblack_fggreen "cluster_script_dist end" $prepare_output_tabs
}

####### 对单个节点远程分发安装脚本,parameter 1: ip
function single_script_dist(){
    print_bgblack_fggreen "single_script_dist begin" $prepare_output_tabs
    local ip=$1
    local script_basedir=`dirname $SCRIPT_BASE_DIR`
    local script_file=`basename $SCRIPT_BASE_DIR`.tar.gz
    local script_md5_file=${script_file}.md5sum

    __single_file_dist $script_basedir $script_file $script_basedir $ip

    __single_zipfile_check $script_md5_file $script_basedir $script_file $script_basedir $ip

    __single_unzipfile $script_file $script_basedir $ip

    print_bgblack_fggreen "single_script_dist end" $prepare_output_tabs   
}

###### 修改/opt/wotung 所有者为parauser
function cluster_root_chown() {
    print_bgblack_fggreen "cluster_root_chown begin" $prepare_output_tabs
    local filename=$PASSWD_CONFIG_FILE

    local script_basedir=`dirname $SCRIPT_BASE_DIR`
    for ip in $CLUSTER_IPS; do
       passwd=`grep ${ip} $filename |awk '{print $2 }'`
       
       dirpath_root_chown $ip $DEFAULT_USER $passwd $INSTALL_DIR $USER_NAME $USER_NAME
       dirpath_root_chown $ip $DEFAULT_USER $passwd $script_basedir $USER_NAME $USER_NAME
       # dirpath_root_chown 192.168.1.99 parafs tianpusen /opt/wotung parafs parafs
    done
    print_bgblack_fggreen "cluster_root_chown end" $prepare_output_tabs
}
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
PREPARE_BASH_NAME=parafs_prepare.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . ../variable.sh
fi
if [ -z ${USER_BASH_NAME} ] ; then 
    . ${SCRIPT_BASE_DIR}/parafs/common/common_user.sh
fi
if [ -z ${ZIP_BASH_NAME} ] ; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_zip.sh
fi
if [ -z ${COMMON_BASH_NAME} ] ; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_parafs.sh
fi
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi
prepare_output_tabs="2"
# use the parafs_tools.sh
. ${SCRIPT_BASE_DIR}/parafs/parafs_tools.sh
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
# cluster_create_user
# cluster_user_authorize
# cluster_root_authorize
# cluster_each_root_login
# cluster_config_network
# local_script_zip
# cluster_script_dist
# cluster_root_chown
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
