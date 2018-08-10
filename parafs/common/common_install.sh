#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###############################################################################
###### 以下指令执行指定ssh免密用户执行
###############################################################################
###### 远程使用yum安装文件
function yum_install() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3

    echo "do yum at $authorize_ip"
    local temp_file="/tmp/parafs_yum_install$authorize_ip"
    local remote_command="yum -q -y install ntp ntpdate net-tools redhat-lsb gcc libffi-devel \
        python python-devel openssl-devel numactl epel-release"
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >$temp_file

    local remote_command="yum -q -y install python-pip "
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >$temp_file
    return $?
}

###### 远程使用pip安装源
# pip_source可以为空
function pip_install() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local pip_source=$4

    echo "do pip at $authorize_ip"
    local temp_file="/tmp/parafs_pip_install$authorize_ip"
    local remote_command="pip install paramiko "
    if [ -z "$pip_source" ] ; then
        remote_command="pip install -i https://pypi.tuna.tsinghua.edu.cn/simple paramiko"
    fi

    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >$temp_file
    return $?
}

###### 远程安装 rpm 文件
function rpm_install() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local rpm_file=$4

    echo "do rpm $rpm_file at $authorize_ip"
    local temp_file="/tmp/parafs_rpm_install$authorize_ip"
    local remote_command="rpm -ivh --force $rpm_file "

    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >>$temp_file
    return $?
}

###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
COMMON_INSTALL_BASH_NAME=common_install.sh
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# yum_install parauser 192.168.138.71 parauser
# echo $?
# pip_install parauser 192.168.138.71 parauser
# echo $?
# rpm_install parauser 192.168.138.71 parauser /opt/wotung/parafs-1.0.1-1.x86_64.rpm
# echo $?
# update_bashrc parauser 192.168.138.72 parauser /home/parauser /opt/wotung/parafs-install/conf/bashrc
#echo $?
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
