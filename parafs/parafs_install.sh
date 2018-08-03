#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

function install_usage() {
    echo "cluster_ParafsInstallation：parafs的安装，需要使用networks"
    echo "cluster-hadoop"
}

####### ParafsInstallation 
####+++ 逐台安装parafs和日志
function cluster_ParafsInstallation() {
   	echo -e "\t\t cluster_ParafsInstallation start"
		 source $BASE_DIR/parafs/InstallALLParafs.sh
    echo -e "\t\t cluster_parafs done"
}

####### cluster_SourceBashrc
####+++  设置环境变量
function cluster_SourceBashrc() {
	  echo -e "\t\t cluster_SourceBashrc start"
	  	source $BASE_DIR/parafs/InstallAllSourceBashrc.sh 
    echo -e "\t\t cluster_SourceBashrc done"
}

####### cluster_ChangeConfigurationFile
####+++ 修改xml文件
function cluster_ChangeConfigurationFile() {
    echo -e "\t\t cluster_ChangeConfigurationFile start"
	  	source $BASE_DIR/parafs/InstallAllChangeParaCfg.sh  
    echo -e "\t\t cluster_ChangeConfigurationFile done"
}

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
INSTALL_BASH_NAME=parafs_install.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
#if [ -z ${UTILS_BASH_NAME} ] ; then 
#    . /opt/wotung/parafs-install/common/common_utils.sh
#fi


###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# install_usage
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
