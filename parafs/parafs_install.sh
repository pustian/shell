#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

function install_usage() {
    echo "cluster_ParafsInstallation：parafs的安装，需要使用networks"
    echo "cluster-dist-rpm"
    echo "cluster-dist-hadoop"
    echo "cluster-yum"
    echo "cluster-pip"
    echo "cluster-config-bashrc"
    echo "cluster-update-hadoop"
    echo "cluster-update-spark"
    echo "cluster-update-zookeeper"
    echo "cluster-update-hive"
    echo "cluster-update-hbase"
    echo "cluster-update-kafka"
    echo "cluster-update-azkaban"
    echo "cluster-update-ycsb"
    echo "cluster-chown-ycsb"
    echo "cluster-wotung-chown"
}

####### 分发安装文件到各机器上,llog.rpm parafs.rpm
function cluster_dist_rpm() {
    echo -e "\t\t cluster_parafs_rpm_dist begin"
    
    __cluster_file_dist $INSTALL_DIR $PARAFS_RPM $INSTALL_DIR

    __cluster_zipfile_check $PARAFS_MD5_RPM $PARAFS_RPM $INSTALL_DIR

    __cluster_file_dist $INSTALL_DIR $LLOG_RPM $INSTALL_DIR

    __cluster_zipfile_check $LLOG_MD5_RPM $LLOG_RPM $INSTALL_DIR

    echo -e "\t\t cluster_parafs_rpm_dist end"
}
 
#######  分发生态文件到各机器上,
function cluster_dist_hadoop() {
    echo -e "\t\t cluster_hadoop_dist begin"

    __cluster_file_dist $INSTALL_DIR $HADOOP_FILE $INSTALL_DIR

    __cluster_zipfile_check $HADOOP_MD5_FILE $HADOOP_FILE $INSTALL_DIR

    __cluster_unzipfile $HADOOP_FILE $INSTALL_DIR
    
    echo -e "\t\t cluster_hadoop_dist end"
}

# ####### ParafsInstallation 
# ####+++ 逐台安装parafs和日志
# function cluster_ParafsInstallation() {
#    	echo -e "\t\t cluster_ParafsInstallation start"
# 		 source $BASE_DIR/parafs/InstallALLParafs.sh
#     echo -e "\t\t cluster_parafs done"
# }
# 
# ####### cluster_SourceBashrc
# ####+++  设置环境变量
# function cluster_SourceBashrc() {
# 	  echo -e "\t\t cluster_SourceBashrc start"
# 	  	source $BASE_DIR/parafs/InstallAllSourceBashrc.sh 
#     echo -e "\t\t cluster_SourceBashrc done"
# }
# 
# ####### cluster_ChangeConfigurationFile
# ####+++ 修改xml文件
# function cluster_ChangeConfigurationFile() {
#     echo -e "\t\t cluster_ChangeConfigurationFile start"
# 	  	source $BASE_DIR/parafs/InstallAllChangeParaCfg.sh  
#     echo -e "\t\t cluster_ChangeConfigurationFile done"
# }
# 

###### 修改/opt/wotung 所有者为parauser
function cluster_wotung_chown() {
     echo -e "\t\t cluster_wotung_chown begin"
     local filename=$PASSWD_CONFIG_FILE

     for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        
        dirpath_chown $ip $DEFAULT_USER $passwd $INSTALL_DIR $USER_NAME $USER_NAME
        # dirpath_chown 192.168.1.99 parafs tianpusen /opt/wotung parafs parafs
     done
     echo -e "\t\t cluster_wotung_chown end" 
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
