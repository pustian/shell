#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function usage() {
    echo -e "\033[40;37m##########################################################################\033[0m" ;
    echo -e "\033[40;37m#         Hetong Infinity Fusion installation and tools System           #\033[0m" ;
    echo -e "\033[40;37m##########################################################################\033[0m" ;
    echo -e "\033[40;37mpre-check -------------------------------------------------------------[P]\033[0m" ;
    echo -e "\033[40;37mpre-installation-------------------------------------------------------[R]\033[0m" ;
    echo -e "\033[40;37minstallation---------------------------------------------------------- [I]\033[0m" ;
    echo -e "\033[40;37mafter-check------------------------------------------------------------[A]\033[0m" ;
    echo -e "\033[40;37mSynchronizeInstall-----------------------------------------------------[S]\033[0m" ;
    echo -e "\033[40;37mUpgradeParafs----------------------------------------------------------[U]\033[0m" ;
	  echo -e "\033[40;37mTest------------------------------------------------------------------ [T]\033[0m" ;
    echo -e "\033[40;37mExit ------------------------------------------------------------------[E]\033[0m" ;
}



###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
if [ -z $VARIABLE_BASH_NAME ] ; then
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z ${CHECK_ENV_BASH_NAME} ] ; then
    . $BASE_DIR/parafs/check-env.sh
fi
if [ -z ${PREPARE_BASH_NAME} ] ; then
    . $BASE_DIR/parafs/parafs_prepare.sh 
fi
if [ -z ${INSTALL_BASH_NAME} ] ; then
    . $BASE_DIR/parafs/parafs_install.sh
fi
if [ -z ${CHECK_BASH_NAME} ] ; then
    . $BASE_DIR/parafs/parafs_check.sh
fi
#. /opt/wotung/parafs-install/install.sh

EXPECT=`which expect`
if [ $? -ne 0 ] ; then
    echo -e "\033[40;31m\texpect must support, please run 'yum install expect'\033[0m"
    exit 1
fi

input="?"
while [ x"${input}" != x"E" ]; do 
    usage
    read -p "What you want to do:" input
    case ${input} in
        P|p) 
            echo -e "\033[40;34m\tpre-check begin\033[0m"
#            check_config 
#            check_ips
#            cluster_check_passwd
#            cluster_check_nodes
            echo -e "\033[40;32m\tpre-check done \033[0m"
            ;;
        R|r) 
            echo -e "\033[40;34m\tpre-installation begin\033[0m"
#            cluster_create_user
#            cluster_user_authorize
            # 删除 passwd user_passwd 文件
#            cluster_wotung_chown
#            cluster_script_dist
#            cluster_config_network
            cluster_parafs_rpm_dist
            cluster_hadoop_dist
            # cluster_yum_source
            # cluster_pip_source
            # cluster_yum_install
            # cluster_pip_install
            echo -e "\033[40;32m\tpre-installation done \033[0m"
            ;;
        I|i)
            echo -e "\033[40;34m\tinstallation begin\033[0m"
            cluster_ParafsInstallation
            cluster_SourceBashrc
            cluster_ChangeConfigurationFile
            echo -e "\033[40;32m\tinstallation done \033[0m"
            ;;
        A|a) 
            echo -e "\033[40;34m\tafter-check begin\033[0m"
            
            echo -e "\033[40;32m\tafter-check done \033[0m"
            ;;
        S|s) 
            echo -e "\033[40;34m\SynchronizeInstall begin\033[0m"
            source $BASE_DIR/parafs/SynchronizeFolder.sh
            echo -e "\033[40;32m\SynchronizeInstall done\033[0m"
            ;;
        U|u) 
            echo -e "\033[40;34m\UpgradeParafs begin\033[0m"
            source $BASE_DIR/parafs/InstallALLParafs.sh
            echo -e "\033[40;32m\UpgradeParafs done\033[0m"
            ;;
        T|t) 
            echo $BASE_DIR
            ;;
        E|e|Q|q) echo "exit"
            exit 0
            ;;
    esac
done
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++###
     
