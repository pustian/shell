#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

function tools_usage() {
	echo "在集群上执行指定命令"  
	echo "在集群上同步指定文件" 
    echo "在集群上更新parafs" #TODO
    echo "检查指定ip的node"
    echo "新建一个parauser";
    echo "同一用户免密"
    echo "dist file to some computer";
    echo "删除用户";
    echo "集群新增一台机器"
    echo "集群删除一台机器"
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

    echo $parafs_rpm 
    echo $llog_rpm
}

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
TOOLS_BASH_NAME=parafs_tools.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . ../variable.sh
fi
. ./common/common_utils.sh
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
#cluster_cmd "touch /tmp/hello_111"
#cluster_cmd "rm -f /tmp/hello_111"
#touch /tmp/hello_111
#cluster_sync_file /tmp/hello_111
#cluster_cmd "rm -f /tmp/hello_111"
#cluster_update_parafs
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
