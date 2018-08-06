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
        python python-devel python-pip openssl-devel numactl epel-release"

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

###### 远程修改sed文件
#function update_sed_script() {
#    local local_user=$1
#    local authorize_ip=$2
#    local authorize_user=$3
#    local sed_script_file=$4
#    local sed_content=$5
#    #local statement="\<value\>hello world\</value\> \<!-- 田--\>"
# 
#    ### 修改sed文件 
#    local temp_file="/tmp/parafs_update_sed_script$authorize_ip"
#    local remote_command="echo $sed_content |sudo tee $sed_script_file"   
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

    ### 1, 远程获取需要更新的行数，
    ### 2, 并在远端生成sed_script
    ### 3, 远程执行sed脚本
    local property='\<name\>yarn.resourcemanager.hostname\</name\>'
    local line_num=sudo su - $local_user -c "ssh $authorize_user@$authorize_ip 'grep -n $property $filename'" |awk
    local value="<value>${main_ip}</value>  <!-- yarn主节点 -->"
    
    # echo "do update_hadoop_yarn at $authorize_ip "
    # local temp_file="/tmp/parafs_update_hadoop_yarn$authoriz_ip"
    # ## 1, yarn 替换sed_script_file
    # ## 2, 远程执行yarn文件
    # local property="<name>yarn.resourcemanager.hostname</name>"
#   #  local yarn_value="<value>${master_ip}</value>  <!-- yarn主节点 -->"
#   #  local yarn_value="<value>${master_ip}</value>    <!-- yarn主节点 --> "
#   #  local line_num=`grep -n "$property" /opt/wotung/parafs-install/conf/passwd | awk -F ':' '{print $1}'`
    # local sed_script_file="/tmp/sed_script_tmp"
#   #      local sed_script="echo $(($line_num+1)),$(($line_num+1))c '$yarn_value' |sudo tee $sed_script_file"
#   #  local remote_command="$sed_script && sudo sed -i -f $sed_script_file  $filename"
    # sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip'  'sudo sed -i -f $sed_script_file $filename' " >$temp_file
    return $?
}
function update_hadoop_mem() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3

    local temp_file="/tmp/parafs_update_hadoop_mem$authorize_ip"
    echo "do update_hadoop_mem at $authorize_ip "
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
update_sed_script parauser 192.168.138.70 parauser  /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn
# update_hadoop_yarn_ip parauser 192.168.138.71 parauser /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/yarn-site.xml /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn 192.168.1.1
echo $?
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
