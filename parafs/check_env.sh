#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function env_usage() {
    echo "check-local-install-files"
    echo "check-address"
    echo "local-install-expect"
    echo "cluster-check-root-passwd"
    echo "cluster-check-nodes"
}

####### 配置文件相关检查已经在 需要安装文件在此处作检查
function check_local_install_files() {
    print_bgblack_fggreen "check_local_install_files begin" $check_env_output_tabs
    test ! -d $SOURCE_DIR && print_bgblack_fgred "$SOURCE_DIR is not exist" && exit 1
    test ! -f $SOURCE_DIR/$PARAFS_RPM  && print_bgblack_fgred "$SOURCE_DIR/$PARAFS_RPM is not exist" && exit 1
    test ! -f $SOURCE_DIR/$PARAFS_MD5_RPM && print_bgblack_fgred "$SOURCE_DIR/$PARAFS_MD5_RPM is not exist" && exit 1
    test ! -f $SOURCE_DIR/$LLOG_RPM && print_bgblack_fgred "$SOURCE_DIR/$LLOG_RPM is not exist" && exit 1
    test ! -f $SOURCE_DIR/$LLOG_MD5_RPM && print_bgblack_fgred "$SOURCE_DIR/$LLOG_MD5_RPM is not exist" && exit 1
    test ! -f $SOURCE_DIR/$HADOOP_FILE && print_bgblack_fgred "$SOURCE_DIR/$HADOOP_FILE is not exist" && exit 1
    test ! -f $SOURCE_DIR/$HADOOP_MD5_FILE && print_bgblack_fgred "$SOURCE_DIR/$HADOOP_MD5_FILE is not exist" && exit 1


    test ! -d $SCRIPT_BASE_DIR  && print_bgblack_fgred "$SCRIPT_BASE_DIR is not exist" && exit 1
    test ! -d $SCRIPT_BASE_DIR/parafs/expect_common  && print_bgblack_fgred "$SCRIPT_BASE_DIR/parafs/expect_common is not exist" && exit 1
    test ! -f $SSH_EXP_LOGIN  && print_bgblack_fgred "$SSH_EXP_LOGIN is not exist" && exit 1
    test ! -f $SSH_EXP_COPY  && print_bgblack_fgred "$SSH_EXP_COPY is not exist" && exit 1
    test ! -f $SSH_REMOTE_EXEC && print_bgblack_fgred "$SSH_REMOTE_EXEC is not exist" && exit 1
    test ! -f $SSH_EXP_AUTHORIZE  && print_bgblack_fgred "$SSH_EXP_AUTHORIZE is not exist" && exit 1

    test ! -d $SCRIPT_BASE_DIR/conf && print_bgblack_fgred "$SCRIPT_BASE_DIR/conf is not exist" && exit 1
    test ! -f $NETWORK_CONFIG_FILE && print_bgblack_fgred "$NETWORK_CONFIG_FILE is not exist" && exit 1
    # test ! -f $USER_PASSWD_FILE  && print_bgblack_fgred "$USER_PASSWD_FILE is not exist" && exit 1
    test ! -f $MISC_CONF_FILE && print_bgblack_fgred "$MISC_CONF_FILE is not exist" && exit 1
    test ! -f $PASSWD_CONFIG_FILE && print_bgblack_fgred "$PASSWD_CONFIG_FILE is not exist" && exit 1
    test ! -f $BASHRC_CONFIG_FILE  && print_bgblack_fgred "$BASHRC_CONFIG_FILE is not exist" && exit 1

    test ! -d $SCRIPT_BASE_DIR/conf/sed_script && print_bgblack_fgred "$SCRIPT_BASE_DIR/conf/sed_script is not exist" && exit 1
    test ! -f $SED_SCRIPT_HADOOP_YARN_IP && print_bgblack_fgred "$SED_SCRIPT_HADOOP_YARN_IP is not exist" && exit 1
    test ! -f $SED_SCRIPT_HADOOP_YARN_MEM && print_bgblack_fgred "$SED_SCRIPT_HADOOP_YARN_MEM is not exist" && exit 1
    test ! -f $SED_SCRIPT_HADOOP_YARN_CPUS && print_bgblack_fgred "$SED_SCRIPT_HADOOP_YARN_CPUS is not exist" && exit 1
    test ! -f $SED_SCRIPT_SPARK_ENV && print_bgblack_fgred "$SED_SCRIPT_SPARK_ENV is not exist" && exit 1 
    test ! -f $SED_SCRIPT_SPARK_CONF && print_bgblack_fgred "$SED_SCRIPT_SPARK_CONF is not exist" && exit 1 
    test ! -f $SED_SCRIPT_HBASE_CONF && print_bgblack_fgred "$SED_SCRIPT_HBASE_CONF is not exist" && exit 1 
    test ! -f $SED_SCRIPT_HIVE_CONF && print_bgblack_fgred "$SED_SCRIPT_HIVE_CONF is not exist" && exit 1
    test ! -f $SED_SCRIPT_AZKABAN_CONF && print_bgblack_fgred "$SED_SCRIPT_AZKABAN_CONF is not exist" && exit 1 
    test ! -f $SED_SCRIPT_KAFKA_CONF && print_bgblack_fgred "$SED_SCRIPT_KAFKA_CONF is not exist" && exit 1 
    test ! -f $SED_SCRIPT_KAFKA_BROKER_ID && print_bgblack_fgred "$SED_SCRIPT_KAFKA_BROKER_ID is not exist" && exit 1
    test ! -f $SED_SCRIPT_SPARK_BENCH_LEGACY_ENV && print_bgblack_fgred "$SED_SCRIPT_SPARK_BENCH_LEGACY_ENV is not exist" && exit 1

    test -z $MASTER_IP && print_bgblack_fgred "\$MASTER_IP is null" && exit 1
    test -z ${HADOOP_PARAFS_HOME} &&  print_bgblack_fgred "\$HADOOP_PARAFS_HOME is null" && exit 1
    print_bgblack_fggreen "check_local_install_files end" $check_env_output_tabs
}

function local_exec_md5(){
    print_bgblack_fggreen "local_exec_md5 begin" $check_env_output_tabs
    local name_hadoop=`grep ^parafs_hadoop_file ${SCRIPT_BASE_DIR}/conf/misc_config | awk -F '=' '{print $2}'`
    local name_parafs=`grep ^parafs_rpm ${SCRIPT_BASE_DIR}/conf/misc_config | awk -F '=' '{print $2}'`
    local name_llog=`grep ^llog_rpm ${SCRIPT_BASE_DIR}/conf/misc_config | awk -F '=' '{print $2}'`

    local package_path="${INSTALL_DIR}/package"
    print_msg "if md5sum file exists, the origin will be used "
    test ! -f ${package_path}/${name_hadoop}.md5sum && md5sum ${package_path}/${name_hadoop} > ${package_path}/${name_hadoop}.md5sum
    test ! -f ${package_path}/${name_parafs}.md5sum &&  md5sum ${package_path}/${name_parafs} > ${package_path}/${name_parafs}.md5sum
    test ! -f ${package_path}/${name_llog}.md5sum && md5sum ${package_path}/${name_llog} > ${package_path}/${name_llog}.md5sum
    print_bgblack_fggreen "local_exec_md5 end" $check_env_output_tabs
}    

####### 根据配置文件network检查ip连通状况
####+++ return : 检查失败输出到屏幕，并且停止进行
function check_address() {
    print_bgblack_fggreen "check_address begin" $check_env_output_tabs
    local fault_ips="" 
    for ip in $CLUSTER_IPS; do
        is_conn $ip
        if [ $? -eq 0 ] ; then
            print_bgblack_fgred "$ip connection error" $check_env_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done

    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "make sure the files $NETWORK_CONFIG_FILE and the networks" $check_env_output_tabs
        exit 1
    fi
    print_bgblack_fggreen "check_address end" $check_env_output_tabs
}

###集群检查internet连接
function cluster_check_internet(){
    print_bgblack_fggreen "cluster_check_internet begin" $check_env_output_tabs
    local fail_node=""
    
    for ip in $CLUSTER_IPS; do
        internet_conn $ip "www.baidu.com"
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "ERROR: $ip to internet connection error" $check_env_output_tabs
            fail_node="$ip $fail_node"
        fi
    done

    if [ ! -z "$fail_node" ]; then
        print_bgblack_fgred "check the internet connection of $fail_node" $check_env_output_tabs
        exit 1
    fi
    print_bgblack_fggreen "cluster_check_internet end" $check_env_output_tabs
}

###安装expect
function local_install_expect() {
    print_bgblack_fggreen "local_install_expect begin" $check_env_output_tabs
    
    print_msg "which expect"
    which expect
    if test $? -ne 0 ; then
        print_msg "rpm -ivh ${SCRIPT_BASE_DIR}/download/expect/*.rpm"
        ret=`rpm -ivh ${SCRIPT_BASE_DIR}/download/expect/*.rpm --force`
        print_result "$ret"
    fi
    print_bgblack_fggreen "local_install_expect end" $check_env_output_tabs
}



####### 根据配置文件PASSWD_CONFIG_FILE 检查用户密码,
####+++ return : 
function cluster_check_passwd() {
    print_bgblack_fggreen "cluster_check_passwd begin" $check_env_output_tabs
    local filename=$PASSWD_CONFIG_FILE
    
    fault_ips=""
    for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        #echo "ip=$ip DEFAULT_USER=$DEFAULT_USER passwd=******  DEFAULT_USER_HOME=$DEFAULT_USER_HOME"
        is_passwd_ok "$ip" "$DEFAULT_USER" "$passwd" "$DEFAULT_USER_HOME"
        if [ $? -ne 0 ]; then
            fault_ips="$ip $fault_ips"
            print_bgblack_fgred "ERROR: $ip $user passwd error" $check_env_output_tabs
            # break;
        fi 
    done

    if [ ! -z "$fault_ips" ] ; then
        print_bgblack_fgred "make sure the passwd file with $DEFAULT_USER at $fault_ips" $check_env_output_tabs
        exit 1;
    fi
    print_bgblack_fggreen "cluster_check_passwd end" $check_env_output_tabs
}

######
####### 检查/opt/wotung/node/0 目录，需要root免密登陆
####+++ return : 检查失败输出到屏幕，并且停止进行
function cluster_check_filesystem() {
    print_bgblack_fggreen "cluster_check_filesystem begin" $check_env_output_tabs
    local filename=$PASSWD_CONFIG_FILE

    fault_ips=""
    for ip in $CLUSTER_IPS; do
        if [ "x${ip}" = "x" ] ; then 
            break;
        fi
        passwd=`grep ${ip} $filename |awk '{print $2 }'`

        is_ext4_format $ip $DEFAULT_USER $passwd
        if [ $? -eq 0 ]; then
            fault_ips="$ip $fault_ips"
            print_bgblack_fgred "WARN: The file system isnot ext4 filesystem at $ip" $check_env_output_tabs
            # break;
        fi 
        node_capcity $ip $DEFAULT_USER $passwd
        if [ $? -eq 0 ]; then
            fault_ips="$ip $fault_ips"
            print_bgblack_fgred "WARN: The capcity of /opt/wotung/node/0 need more space at $ip" $check_env_output_tabs
            # break;
        fi 
    done

    if [ ! -z "$fault_ips" ] ; then
        print_bgblack_fgred "make sure /opt/wotung/node/0 at $fault_ips" $check_env_output_tabs
        # exit 1;
    fi
    print_bgblack_fggreen "cluster_check_filesystem end" $check_env_output_tabs
}

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
CHECK_ENV_BASH_NAME=check_env.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . ../variable.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_utils.sh
fi
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi
check_env_output_tabs="2"
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# check_local_install_files
# cluster_check_passwd
# cluster_check_nodes
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
