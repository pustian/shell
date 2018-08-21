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
            #检查本地安装文件是否齐全
            check_local_install_files
            #检查各IP是否能够ping通
            check_ips
            #在root免密的情况下会直接通过，先重命名~/.ssh 使免密失效
            cluster_check_passwd 
            #检查/opt/wotung/node/0 目录 
            cluster_check_nodes
            echo -e "\033[40;32m\tpre-check done \033[0m"
            ;;
        R|r) 
            echo -e "\033[40;34m\tpre-installation begin\033[0m"
#           ## cluster_create_user
#           ## cluster_user_authorize
            #集群root用户免密，注意先配置conf/network和conf/passwd
            cluster_root_authorize
            #集群配置/etc/hostname, /etc/hosts。先要确保上述2文件存在
            cluster_config_network
            #本地压缩parafs-install/生成压缩包，并生成md5 
            local_script_zip
#            ### 远程机器需要同样存在目录 `dirname $SCRIPT_BASE_DIR`,即/opt/wotung
            #集群分发压缩包、检查md5、解压缩
            cluster_script_dist
#            ## cluster_root_chown
#            # 删除 passwd user_passwd 文件 
            echo -e "\033[40;32m\tpre-installation done \033[0m"
            ;;
        U|u)
            echo -e "\033[40;32m\tdist and install begin \033[0m"
            cluster_dist_rpm
            local_dist_rpm
            cluster_hadoop_dist
            local_dist_hadoop
            cluster_yum
            cluster_pip
            cluster_rpm_install
#            ## cluster_sudoer_chown
            echo -e "\033[40;32m\tdist and install done \033[0m"
            ;;
        D|d)
            echo -e "\033[40;34m\tdistribute begin\033[0m"
            local_dist_rpm
            cluster_dist_rpm
            local_dist_hadoop
            cluster_hadoop_dist
            echo -e "\033[40;34m\tdistribute end\033[0m"
            ;;
        I|i)
            echo -e "\033[40;34m\tinstallation begin\033[0m"
            cluster_yum
            cluster_pip
            cluster_rpm_install
            ##cluster_sudoer_chown
            echo -e "\033[40;32m\tinstallation done \033[0m"
            ;;
        C|c)
            echo -e "\033[40;32m\tconfig begin \033[0m"
            #集群同步.bashrc，需要确保/root/.bashrc存在
            cluster_config_bashrc
            #集群同步hadoop，注意MASTER_IP在conf/MISC_config中配置
            cluster_update_hadoop
            #TODO
            cluster_update_spark
            cluster_update_zookeeper
            cluster_update_hbase
            cluster_update_hive
            cluster_update_azkaban
            # cluster_update_kafka
            echo -e "\033[40;32m\tconfig done \033[0m"
            ;;
        A|a) 
            echo -e "\033[40;34m\tafter-check begin\033[0m"
            
            echo -e "\033[40;32m\tafter-check done \033[0m"
            ;;
        E|e|Q|q|exit) echo "exit"
            exit 0
            ;;
    esac
done
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++###
     
