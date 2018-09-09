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

    print_bgblack_fgwhite "function call ......yum_install.....  at $authorize_ip" $common_inst_outpus_tabs
    local remote_command="yum -y install ntp ntpdate net-tools redhat-lsb gcc libffi-devel \
        python python-devel openssl-devel numactl epel-release rsync && yum -y install python-pip "
    print_bgblack_fgwhite "It will take a few minutes to some dependences by yum" $common_inst_outpus_tabs
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'"  >> $INSTALL_LOG #|tee -a $INSTALL_LOG
    return $?
}

###### 远程使用pip安装源
# pip_source可以为空
function pip_install() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local pip_source=$4

    print_bgblack_fgwhite "function call ......pip_install.....  at $authorize_ip" $common_inst_outpus_tabs
    local remote_command="pip install paramiko "
    if [ -z "$pip_source" ] ; then
        remote_command="pip install -i https://pypi.tuna.tsinghua.edu.cn/simple paramiko"
    fi

    print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_command'\""
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >> $INSTALL_LOG #|tee -a $INSTALL_LOG
    return $?
}

###### 远程安装 rpm 文件
function rpm_install() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local rpm_file=$4

    print_bgblack_fgwhite "function call ......rpm_install..... at $authorize_ip for `basename $rpm_file`" $common_inst_outpus_tabs
    local remote_command="rpm -ivh --force $rpm_file "
    print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_command'\""
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >> $INSTALL_LOG #|tee -a $INSTALL_LOG
    return $?
}

###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
COMMON_INSTALL_BASH_NAME=common_install.sh
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi
common_inst_outpus_tabs="2"
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# yum_install parauser 192.168.138.71 parauser
# echo $?
# pip_install parauser 192.168.138.71 parauser
# echo $?
# rpm_install parauser 192.168.138.71 parauser /opt/wotung/parafs-1.0.1-1.x86_64.rpm
# echo $?
#echo $?
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
