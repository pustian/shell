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
#    echo -e "\033[40;37mupgrade ---------------------------------------------------------------[U]\033[0m" ;
#    echo -e "\033[40;37mtools------------------------------------------------------------------[T]\033[0m" ;
    echo -e "\033[40;37mExit ------------------------------------------------------------------[E]\033[0m" ;
}



###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
if [ -z $VARIABLE_BASH_NAME ] ; then
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z ${CHECK_ENV_BASH_NAME} ] ; then
    . /opt/wotung/parafs-install/parafs/check-env.sh
fi
if [ -z ${PREPARE_BASH_NAME} ] ; then
    . /opt/wotung/parafs-install/parafs/parafs_prepare.sh 
fi
if [ -z ${INSTALL_BASH_NAME} ] ; then
    . /opt/wotung/parafs-install/parafs/parafs_install.sh
fi
if [ -z ${CHECK_BASH_NAME} ] ; then
    . /opt/wotung/parafs-install/parafs/parafs_check.sh
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
            check_config 
            check_ips
            cluster_check_root_passwd
            echo -e "\033[40;32m\tpre-check done \033[0m"
            ;;
        R|r) 
            echo -e "\033[40;34m\tpre-installation begin\033[0m"
            cluster_create_user
            cluster_parauser_authorize
            cluster_script_dist
            cluster_config_hostname
            cluster_config_hosts
            cluster_check_node
            cluster_install_package_dist
            cluster_check_install_package
            cluster_unzip_install_package
            # cluster_yum_source
            # cluster_pip_source
            # cluster_yum_install
            # cluster_pip_install
            echo -e "\033[40;32m\tpre-installation done \033[0m"
            ;;
        I|i)
            echo -e "\033[40;34m\tinstallation begin\033[0m"
            cluster_parafs
            cluster_parafs_client
            cluster_llog
            cluster_hadoop
            echo -e "\033[40;32m\tinstallation done \033[0m"
            ;;
        A|a) 
            echo -e "\033[40;34m\tafter-check begin\033[0m"
            echo -e "\033[40;32m\tafter-check done \033[0m"
            ;;
        E|e|Q|q) echo "exit"
            exit 0
            ;;
    esac
done
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++###
     
