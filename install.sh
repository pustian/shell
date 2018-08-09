#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function usage() {
#    clear
    echo ""
    echo ""
    echo -e "\033[40;35m    ##################################################################\033[0m" ;
    echo -e "\033[40;35m    ##      __      __       __                                     ##\033[0m" ; 
    echo -e "\033[40;35m    ##      /  \    /  \_____/  |_ __ __  ____    ____              ##\033[0m" ; 
    echo -e "\033[40;35m    ##      \   \/\/   /  _ \   __\  |  \/    \  / ___\             ##\033[0m" ; 
    echo -e "\033[40;35m    ##       \        (  <_> )  | |  |  /   |  \/ /_/  >            ##\033[0m" ; 
    echo -e "\033[40;35m    ##         \__/\  / \____/|__| |____/|___|  /\___  /            ##\033[0m" ; 
    echo -e "\033[40;35m    ##                \/                        \//_____/           ##\033[0m" ; 
    echo -e "\033[40;35m    ##                                                              ##\033[0m" ; 
    echo -e "\033[40;35m    ##\c\033[0m"
    echo -e "\033[40;37m        Infinity Fusion installation & tools System       \c\033[0m" ; 
    echo -e "\033[40;35m    ##\033[0m"
    echo -e "\033[40;35m    ##################################################################\033[0m" ;
    echo ""
    echo ""
#    echo -e "\033[40;35m##                                                                      ##\033[0m" ; 
#    echo -e "\033[40;35m##                                                                      ##\033[0m" ; 
    echo -e "\033[40;37mpre-check -----------------------------------------------------------------[P]\033[0m" ;
    echo -e "\033[40;37mpre-installation-----------------------------------------------------------[R]\033[0m" ;
    echo -e "\033[40;37mdist and install---------------------------------------------------------- [U]\033[0m" ;
    echo -e "\033[40;37mpackage-dist ------------------------------------------------------------- [D]\033[0m" ;
    echo -e "\033[40;37minstallation-------------------------------------------------------------- [I]\033[0m" ;
    echo -e "\033[40;37mconfig-------------------------------------------------------------------- [C]\033[0m" ;
    echo -e "\033[40;37mafter-check----------------------------------------------------------------[A]\033[0m" ;
    echo -e "\033[40;37mExit ----------------------------------------------------------------------[E]\033[0m" ;
}



###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
if [ -z $VARIABLE_BASH_NAME ] ; then
    . ./variable.sh
fi
if [ -z ${CHECK_ENV_BASH_NAME} ] ; then
    . $SCRIPT_BASE_DIR/parafs/check_env.sh
fi
if [ -z ${PREPARE_BASH_NAME} ] ; then
    . $SCRIPT_BASE_DIR/parafs/parafs_prepare.sh 
fi
if [ -z ${DIST_BASH_NAME} ] ; then
    . $SCRIPT_BASE_DIR/parafs/parafs_dist.sh
fi
if [ -z ${INSTALL_BASH_NAME} ] ; then
    . $SCRIPT_BASE_DIR/parafs/parafs_install.sh
fi
if [ -z ${CONFIG_BASH_NAME} ] ; then
    . $SCRIPT_BASE_DIR/parafs/parafs_config.sh
fi
#if [ -z ${CHECK_BASH_NAME} ] ; then
#    . $SCRIPT_BASE_DIR/parafs/parafs_check.sh
#fi

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
            check_local_install_files
            check_ips
            cluster_check_passwd #在root免密的情况下会直接通过，先重命名~/.ssh 使免密失效
#            cluster_check_nodes
            echo -e "\033[40;32m\tpre-check done \033[0m"
            ;;
        R|r) 
            echo -e "\033[40;34m\tpre-installation begin\033[0m"
#            cluster_create_user
#            cluster_user_authorize
#             cluster_root_authorize
#            cluster_config_network
#            local_script_zip
#            ### 远程机器需要同样存在 目录 `dirname $SCRIPT_BASE_DIR`
#            cluster_script_dist
#            # cluster_root_chown
#            # 删除 passwd user_passwd 文件 
            echo -e "\033[40;32m\tpre-installation done \033[0m"
            ;;
        U|u)
            echo -e "\033[40;32m\tdist and install begin \033[0m"
#            cluster_dist_rpm
#            cluster_hadoop_dist
#            if [ `basename ${SOURCE_DIR}` != `basename ${INSTALL_DIR}` ] \
#                || [ `dirname ${SOURCE_DIR}` != `dirname ${INSTALL_DIR}` ] ;
#                local_dist_rpm
#                local_dist_hadoop
#            fi
#            cluster_yum
#            cluster_pip
#            cluster_rpm_install
#            # cluster_sudoer_chown
            echo -e "\033[40;32m\tdist and install done \033[0m"
            ;;
        D|d)
            echo -e "\033[40;34m\tdistribute begin\033[0m"
#            cluster_dist_rpm
#            cluster_hadoop_dist
#            if [ `basename ${SOURCE_DIR}` != `basename ${INSTALL_DIR}` ] \
#                || [ `dirname ${SOURCE_DIR}` != `dirname ${INSTALL_DIR}` ] ;
#                local_dist_rpm
#                local_dist_hadoop
#            fi
            echo -e "\033[40;34m\tdistribute end\033[0m"
            ;;
        I|i)
            echo -e "\033[40;34m\tinstallation begin\033[0m"
#            cluster_yum
#            cluster_pip
#            cluster_rpm_install
#            cluster_sudoer_chown
            echo -e "\033[40;32m\tinstallation done \033[0m"
            ;;
        C|c)
            echo -e "\033[40;32m\tconfig begin \033[0m"
#            cluster_config_bashrc
            cluster_update_hadoop
#            cluster_update_spark
#            cluster_update_zookeeper
#            cluster_update_hbase
#            cluster_update_hive
#            cluster_update_azkaban
#            cluster_update_kafka
            echo -e "\033[40;32m\tconfig done \033[0m"
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
     
