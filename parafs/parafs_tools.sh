#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

function tools_usage() {
	echo "在集群上执行指定命令"  
	echo "在集群上同步指定文件" 
    echo "在集群上更新parafs"
    echo "检查指定ip的node"
    echo "新建一个parauser";
    echo "同一用户免密"
    echo "dist file to some computer";
}

### 在集群上执行某个命令
### $1:	command to be excuted
### 注意：调用时,command要用双引号括起来,否则$1传输会出错
function cluster_cmd() {
	local command=$1
	local local_user="root"
	local remote_user="root"
	for each_ip in $CLUSTER_IPS; do
		remote_excute_cmd $local_user $remote_user $each_ip "$command" 
	done
}

### 在集群上同步指定文件
### $1: 要同步文件的完整路径
function cluster_sync_file() {
	local filename=$1

	local local_user="root"
	local remote_user="root"
    echo $1
	for each_ip in $CLUSTER_IPS; do
		sync_file $local_user $remote_user $each_ip $filename
	done
}

### 集群上更新parafs,
### 需要在/opt/wotung/package/update中放好parafs和llog的安装包
function cluster_update_parafs(){
    local update_dir=$INSTALL_DIR/package/update
    local parafs_rpm=`ls $update_dir | grep parafs`
    local llog_rpm=`ls $update_dir | grep llog`
    cluster_cmd "mkdir -p $update_dir"

    local para_fullpath=$update_dir/$parafs_rpm
    local llog_fullpath=$update_dir/$llog_rpm
    cluster_sync_file "$para_fullpath"
    cluster_sync_file "$llog_fullpath"

    local cmd_update_para="rpm -ivh $para_fullpath --force"
    local cmd_update_llog="rpm -ivh $llog_fullpath --force"
    cluster_cmd "$cmd_update_para"
    cluster_cmd "$cmd_update_llog"
}

###集群删除conf/passwd,/opt/wotung下的多余文件,以及log文件
function cluster_install_clean(){
    # passwd
    local file_passwd="${SCRIPT_BASE_DIR}/conf/passwd"

    # redundant files
    local name_parafs_rpm=`grep '^parafs_rpm' $SCRIPT_BASE_DIR/conf/misc_config | awk -F '=' '{print $2}'`
    local name_llog_rpm=`grep '^llog_rpm' $SCRIPT_BASE_DIR/conf/misc_config | awk -F '=' '{print $2}'`
    local f_parafs_rpm="${INSTALL_DIR}/${name_parafs_rpm}"
    local f_llog_rpm="${INSTALL_DIR}/${name_llog_rpm}"
    local f_hadoop_tar="${INSTALL_DIR}/hadoop-system.tar.gz"
    local f_all_tar="${INSTALL_DIR}/install_all.tar.gz"
    local f_script_tar="${INSTALL_DIR}/parafs-install.tar.gz"
    local f_script_md5="${INSTALL_DIR}/parafs-install.tar.gz.md5sum"

    local file_array=("$f_parafs_rpm" "$f_llog_rpm" "$f_hadoop_tar" "$f_all_tar" "$f_script_tar" "$f_script_md5")

    # logs
    local file_logs_old="/tmp/parafs_*"
    local file_logs_new="$INSTALL_LOG*bak"
    local file_logs=("$file_logs_old" "$file_logs_new")

    # 循环交互，y or n
    ask_for_deletion "passwd in conf/" "$file_passwd" "remote"
    ask_for_deletion "redundant files in /opt/wotung" "${file_array[*]}" "remote"
    ask_for_deletion "logs" "${file_logs[*]}" "local"
}

function ask_for_deletion(){
    local rubbish=$1
    local rubbish_array=$2
    local remote_or_local=$3
    read -p "Do you want to delete [ $rubbish ]  ?(y/n)" input
    case ${input} in
        y|Y)  
            echo "Deleting the $rubbish ..."
            delete_file "${rubbish_array[*]}" "$remote_or_local"
            ;;  
        n|N)  
            echo "The [ $rubbish ] will be preserved."
            ;;  
        *)  
            ask_for_deletion "$rubbish" $rubbish_array $remote_or_local
            ;;  
    esac
}

function delete_file(){
    local rubbish_array=$1 
    local remote_or_local=$2
    if [[ $remote_or_local = "local" ]];then
        for i in $rubbish_array
        do
            echo "local delete" $i
            rm -f $i
        done
    elif [[ $remote_or_local = "remote" ]];then
        for i in $rubbish_array
        do
            echo "remote delete $i" 
            cluster_cmd "rm -f $i"
        done
    fi
}

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
TOOLS_BASH_NAME=parafs_tools.sh
. /opt/wotung/parafs-install/variable.sh
. ${SCRIPT_BASE_DIR}/parafs/common/common_utils.sh
tools_output_tabs="2"
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
#cluster_cmd "touch /tmp/hello_111"
#cluster_cmd "rm -f /tmp/hello_111"
#touch /tmp/hello_111
#cluster_sync_file /tmp/hello_111
#cluster_cmd "rm -f /tmp/hello_111"
#cluster_update_parafs
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
