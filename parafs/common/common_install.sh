#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###############################################################################
###### 以下指令执行指定ssh免密用户执行
###############################################################################
###### 远程配置yum安装源
# function yum_config() {
# }

###### 远程使用yum安装文件
function yum_install() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3

    local temp_file="/tmp/parafs_yum_install$authoriz_ip"
    local remote_command="yum -q -y install ntp ntpdate net-tools redhat-lsb gcc libffi-devel \
        python python-devel python-pip openssl-devel numactl epel-release"

    sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$remote_command'" >$temp_file
    return $?
}

# ###### 远程配置yum安装源
# function pip_config() {
# }

###### 远程使用pip安装源
function pip_install() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3

    local temp_file="/tmp/parafs_pip_install$authoriz_ip"
    local remote_command="pip install paramiko "

    sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$remote_command'" >$temp_file
    return $?
}

###### 远程安装 rpm 文件
function rpm_install() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3
    local rmp_file=$4

    local temp_file="/tmp/parafs_rpm_install$authoriz_ip"
    local remote_command="rpm --ivh --force $rpm_file "

    sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$remote_command'" >>$temp_file
    return $?
}

###### 远程 bashrc 更新
function update_bashrc() {
    echo $?
}

###### 远程 更改hadoop 配置
function update_hadoop_config() {
    echo $?
}

###### 远程 更改spark配置
function update_spark_config() {
    echo $?
}

###### 远程 更改sparkSQL配置
function update_spark_sql_config() {
    echo $?
}

###### 远程 更改zookeeper配置
function update_zookeeper_config() {
    echo $?
}

###### 远程 更改hbase配置
function update_hbase_config() {
    echo $?
}

###### 远程 更改hive配置
function update_hive_config() {
    echo $?
}

###### 远程 更改azkaban配置
function update_azkaban_config() {
    echo $?
}

###### 远程 更改kafka配置
function update_kafka_config() {
    echo $?
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
# rpm_install parauser 192.168.138.71 parauser xxxxx.rpm
# echo $?
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
