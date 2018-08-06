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
    local remote_command="sudo yum -q -y install ntp ntpdate net-tools redhat-lsb gcc libffi-devel \
        python python-devel openssl-devel numactl epel-release"
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >$temp_file

    local remote_command="sudo yum -q -y install python-pip "
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

    local temp_file="/tmp/parafs_rpm_install$authorize_ip"
    local remote_command="sudo rpm -ivh --force $rpm_file "

    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >>$temp_file
    return $?
}

###### 远程 bashrc 更新
function update_bashrc() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local authorize_home=$4
    local bashrc_file=$5

    echo "do update_bashrc at $authorize_ip"
    local temp_file="/tmp/parafs_update_bashrc$authorize_ip"
    local remote_command="cat $bashrc_file| sudo tee -a $authorize_home/.bashrc"
    
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >$temp_file
    return $?
}

####### 远程修改sed文件
#function update_sed_script() {
#    local local_user=$1
#    local authorize_ip=$2
#    local authorize_user=$3
#    local sed_script_file=$4
#    local sed_script=$5
#
#    sed_script="\<value\>hello world\</value\> \<!-- 田--\>"
# 
#    ### 修改sed文件 
#    local temp_file="/tmp/parafs_update_sed_script$authorize_ip"
#    local remote_command="echo $sed_script |sudo tee $sed_script_file"   
#    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >>$temp_file
#    return $?
#}

function update_hadoop_yarn_ip() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local main_ip=$6

    local temp_file="/tmp/parafs_update_yarn_ip$authorize_ip"
    ### 1, 远程获取需要更新的行数，
    local yarn_master_label="name"
    local yarn_master_label_value="yarn.resourcemanager.hostname"
    local remote_yarn_master_line="grep -n $yarn_master_label_value $filename |grep $yarn_master_label_value "
    local remote_yarn_master_line_result=`sudo su - $local_user -c "ssh $authorize_user@$authorize_ip '$remote_yarn_master_line' "` 
    if [ -z "$remote_yarn_master_line_result" ]; then 
        echo "pls check $filename at $authorize_ip"
    fi
    echo $remote_yarn_master_line_result >$temp_file

    ### 2, 在本地生成sed_script 然后复制到远端脚本所在地
    local line_num=` echo "$remote_yarn_master_line_result" | awk -F ':' '{print $1}'`
    local yarn_master_value="\<value\>${main_ip}\</value\>  \<!-- yarn主节点 --\>"
    local sed_script="$(($line_num+1)),$(($line_num+1))c $yarn_master_value "   
    echo $sed_script |sudo tee $sed_script_file >>$temp_file
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'" >>$temp_file   
    
    ### 3, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" >>$temp_file
    return $?
}

function update_hadoop_yarn_mem() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5

    local temp_file="/tmp/parafs_update_yarn_mem$authorize_ip"
    ### 1 远程获取内存
    local remote_mem_kb="grep MemTotal /proc/meminfo"
    local remote_mem_kb_result=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_mem_kb'" `
    local mem_kb=`echo $remote_mem_kb_result | awk '{print $2}' `
    # local mem_mb_2=$(($mem_kb/512))  # XXX/1024*2

    ### 2,远程获取 总内存需要更新的行数，
    local memory_label="name"
    local memory_label_value="yarn.nodemanager.resource.memory-mb"
    local remote_memory_line="grep -n $memory_label_value $filename |grep $memory_label_value "
    local remote_memory_line_result=`sudo su - $local_user -c "ssh $authorize_user@$authorize_ip '$remote_memory_line' "` 
    if [ -z "$remote_memory_line" ]; then 
        echo "pls check $filename at $authorize_ip"
    fi
    echo $remote_memory_line_result >$temp_file

    ### 3, 在本地生成sed_script 然后复制到远端脚本所在地
    local line_num=`echo "$remote_memory_line_result" | awk -F ':' '{print $1}'`
    local memory_value="\<value\>$(($mem_kb/512))\</value\>  \<!-- yarn使用总内存 --\>"
    local sed_script="$(($line_num+1)),$(($line_num+1))c $memory_value "   
    echo $sed_script |sudo tee $sed_script_file >>$temp_file
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'" >>$temp_file   
    
    ### 4,远程获取 单个scheduler 内存 需要更新的行数，
    local alloc_mem_label="name"
    local alloc_mem_label_value="yarn.scheduler.maximum-allocation-mb"
    local remote_alloc_mem_line="grep -n $alloc_mem_label_value $filename |grep $alloc_mem_label_value "
    local remote_alloc_mem_line_result=`sudo su - $local_user -c "ssh $authorize_user@$authorize_ip '$remote_alloc_mem_line' "` 
    if [ -z "$remote_alloc_mem_line" ]; then 
        echo "pls check $filename at $authorize_ip"
    fi
    echo $remote_alloc_mem_line_result >$temp_file
    ### 5, 在本地生成sed_script 然后复制到远端脚本所在地
    local line_num=`echo "$remote_alloc_mem_line_result" | awk -F ':' '{print $1}'`
    local alloc_mem_value="\<value\>$(($mem_kb/1024))\</value\>  \<!-- 单个进程最大占用内存 --\>"
    local sed_script="$(($line_num+1)),$(($line_num+1))c $alloc_mem_value "   
    echo $sed_script |sudo tee -a $sed_script_file >>$temp_file ## 此处为追加
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'" >>$temp_file   

    ### 3, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" >>$temp_file
    return $?
}
function update_hadoop_scheduler_mem() {
echo $?
}
function update_hadoop_cpu() {
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

###### 远程 更改ycsb配置
function update_ycsb_config() {
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
# rpm_install parauser 192.168.138.71 parauser /opt/wotung/parafs-1.0.1-1.x86_64.rpm
# echo $?
# update_bashrc parauser 192.168.138.72 parauser /home/parauser /opt/wotung/parafs-install/conf/bashrc
# update_sed_script parauser 192.168.138.70 parauser  /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn
 update_hadoop_yarn_ip parauser 192.168.138.71 parauser /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/yarn-site.xml /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn_ip 192.168.1.299
 update_hadoop_yarn_mem parauser 192.168.138.71 parauser /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/yarn-site.xml /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn_mem
echo $?
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
