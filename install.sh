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
    echo -e "\033[40;37mpre-check -----------------------------------------------------------------[P]\033[0m" ;
    echo -e "\033[40;37mpre-installation-----------------------------------------------------------[R]\033[0m" ;
    echo -e "\033[40;37minstallation-------------------------------------------------------------- [I]\033[0m" ;
    echo -e "\033[40;37mpackage-dist ------------------------------------------------------------- [D]\033[0m" ;
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
installsh_output_tabs="1"
if [ -f $INSTALL_LOG ] ; then
    mv $INSTALL_LOG $INSTALL_LOG`date  +%y%m%d%H%M%S`.bak 
    truncate -s 0 $INSTALL_LOG
else
    touch $INSTALL_LOG
fi

input="?"
while [ x"${input}" != x"E" ]; do 
    usage
    read -p "What you want to do:" input
    case ${input} in
        P|p) 
            print_bgblack_fgblue "pre-chenk begin" $installsh_output_tabs
            #对本地的hadoop_system,llog,parafs进行md5sum
            local_exec_md5
            #本地安装expect，免密需要用到。
            local_install_expect
            #检查本地安装文件是否齐全
            check_local_install_files
            #检查各IP是否能够ping通
            check_address
            #在root免密的情况下会直接通过
            cluster_check_passwd 
            #检查/opt/wotung/node/0 目录 
            cluster_check_filesystem
            print_bgblack_fgblue "pre-chenk end" $installsh_output_tabs
            ;;
        R|r) 
            print_bgblack_fgblue "pre-installation begin" $installsh_output_tabs
            # cluster_create_user
            # cluster_user_authorize
            #集群root用户免密，注意先配置conf/network和conf/passwd
            cluster_root_authorize
            #集群配置/etc/hostname, /etc/hosts。
            cluster_config_network
            #集群配置长名、短名的免密,这一步要在cluster_config_network之后
            ### 此处操作应该在pre-check中作。后续再作改进
            cluster_alias_authorize
            #检查集群internet能否连通
            cluster_check_internet
            #关闭防火墙
            cluster_close_firewalld
            #本地压缩parafs-install/生成压缩包，并生成md5 
            local_script_zip
            ### 远程机器需要同样存在目录 `dirname $SCRIPT_BASE_DIR`,即/opt/wotung
            #集群分发压缩包、检查md5、解压缩
            cluster_script_dist
            ## cluster_root_chown
            # 删除 passwd user_passwd 文件 
            print_bgblack_fgblue "pre-installation end" $installsh_output_tabs
            ;;
        #此选项没有在提示中显示，执行U选项相当于执行D和I
        U|u) 
            print_bgblack_fgblue "dist and install begin " $installsh_output_tabs
            cluster_dist_rpm
            local_dist_rpm
            cluster_yum
            cluster_pip
            cluster_rpm_install
	    ## hadoop-system
            cluster_hadoop_dist
            local_dist_hadoop
            ## cluster_sudoer_chown
            print_bgblack_fgblue "dist and install end" $installsh_output_tabs
            ;;
        I|i)
            print_bgblack_fgblue "installation begin" $installsh_output_tabs
            echo -e "\033[40;34m\t\033[0m"
            local_dist_rpm
            cluster_dist_rpm
            cluster_config_yum_source
            cluster_yum
            cluster_pip
            cluster_rpm_install
            ##cluster_sudoer_chown
            print_bgblack_fgblue "installation end" $installsh_output_tabs
            ;;
        D|d)
            print_bgblack_fgblue "distribute begin" $installsh_output_tabs
            print_bgblack_fgwhite "It will take a few minutes at each machine for $HADOOP_FILE operation" $installsh_output_tabs
            local_dist_hadoop
            cluster_hadoop_dist
            print_bgblack_fgblue "distribute end" $installsh_output_tabs
            ;;
        C|c)
            print_bgblack_fgblue "config parafs-system begin" $installsh_output_tabs
            # 集群同步.bashrc，需要确保/root/.bashrc存在
            cluster_config_bashrc
            # 集群操作，给hadoop-system的bin/和sbin/ +x
            cluster_chmod
            # 
            check_local_config_file
            # 集群同步hadoop，注意MASTER_IP在conf/MISC_config中配置
            cluster_update_hadoop
            # 集群同步spark
            cluster_update_spark
            # 集群同步zookeeper
            cluster_update_zookeeper
            # 集群同步hbase
            cluster_update_hbase
            # 集群同步hive
            cluster_update_hive
            # 集群同步azkaban
            cluster_update_azkaban
            # 集群同步kafka
            cluster_update_kafka
            #
            cluster_update_ycsb_hbase
            # 
            cluster_update_spark_bench_legacy
            print_bgblack_fgblue "config parafs-system end" $installsh_output_tabs
            print_bgblack_fgred "Bash environment has been changed. Pls reopen a new console, or run source ~/.bashrc"
            ;;
        A|a) 
            print_bgblack_fgblue "after-check begin" $installsh_output_tabs
            # 删除conf/passwd、/opt/wotung下的各类临时文件
            cluster_install_clean
            print_bgblack_fgblue "after-check end" $installsh_output_tabs
            ;;
        E|e|Q|q|exit) 
            exit 0
            ;;
    esac
done
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++###
     
