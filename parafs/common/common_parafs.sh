#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###############################################################################
###### common_parafs.sh ===>common_user.sh
###### 检查user是否已经存在，不符合退出报错。uid gid home未作检查
### username $1
### is_exist $2 true/false false 不存在；true 检查$username是已存在
function __cluster_check_user() {
    print_bgblack_fgwhite "function call ...... __cluster_check_user begin ......" $common_parafs_output_tabs
    local username=$1
    local is_exist=$2

    for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $PASSWD_CONFIG_FILE |awk '{print $2 }'`
        ### grep parauser /etc/passwd
        is_no_parauser "$ip" "$DEFAULT_USER" "$passwd" ${username}
        if [ $? -eq 0 ] ; then 
            if [ x${is_exist} = x"false" ] ; then
                print_bgblack_fgred "user=$username exist at $ip " $common_parafs_output_tabs
                fault_ips="$ip $fault_ips"
                # break;
            fi
        else
            if [ x${is_exist} = x"true" ]; then
                print_bgblack_fgred "user=$username not exist at $ip " $common_parafs_output_tabs
                fault_ips="$ip $fault_ips"
                # break;
            fi
        fi
    done
   
    if [ ! -z "$fault_ips" ]; then
        echo -e "\033[31m\t\tmake sure the user\033[0m"
        print_bgblack_fgred "make sure the user at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    print_bgblack_fgwhite "function call ...... __cluster_check_user end ......" $common_parafs_output_tabs
}

###### 创建用户
function __cluster_create_user() {
    print_bgblack_fgwhite "function call ...... __cluster_create_user begin ......" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $PASSWD_CONFIG_FILE |awk '{print $2 }'`
        #echo "create_user ${ip} ${DEFAULT_USER} ${passwd} ${USER_NAME} ${USER_PASSWD_SSL} ${USER_HOME} ${USER_SHELL}"      
        create_user ${ip} ${DEFAULT_USER} ${passwd} ${USER_NAME} ${USER_PASSWD_SSL} ${USER_HOME} ${USER_SHELL}
    done
    
    print_bgblack_fgwhite "function call ...... __cluster_create_user end ......" $common_parafs_output_tabs
}

###### 执行sudo 免密 
function __cluster_config_sudoers() {
    echo -e "\t\t __cluster_config_sudoers begin"
    local username=$1

    local fault_ips=""
    local filename=$PASSWD_CONFIG_FILE
    for ip in $CLUSTER_IPS; do
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        # echo "sudoer_nopasswd ${ip} ${DEFAULT_USER} ${passwd} ${username}"
        sudoer_nopasswd ${ip} ${DEFAULT_USER} ${passwd} ${username}
    done
    
    echo -e "\t\t __cluster_config_sudoers end"
}

### userdel -r parauser
### sed -i '/parauser/'d /etc/sudoers
function __cluster_delete_user() {
    echo -e "\t\t cluster_delete_user begin"
    local username=$1
    local delete_user="userdel -r $1"
    local config_sudoer="sed -i '/$username/'d /etc/sudoers "

    local fault_ips=""
    local filename=$PASSWD_CONFIG_FILE
    local IPS=`cat $filename | grep -v '^#' | awk '{print $1}' `
    for ip in $IPS; do
        if [ "x${ip}" = "x" ] ; then
            break;
        fi
         
        passwd=`grep ${ip} $filename |awk '{print $2 }'`
        user='root'
        echo "do delete_user at $ip"       
        $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$delete_user" >/dev/null
        $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$config_sudoer" >/dev/null

    done
    
    echo -e "\t\t cluster_delete_user end"
}

###############################################################################
###### 以下函数执行前需要ssh免密才能顺利进行
###############################################################################
###### common_parafs.sh ==>common_config.sh
###### 免密后修改 hostname 
function __cluster_config_hostname() {
    print_bgblack_fgwhite "function call ...... __cluster_config_hostname begin ......" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        local hostname=`grep $ip $NETWORK_CONFIG_FILE | awk '{print $2}'`
        # echo "config_hostname $USER_NAME $ip $USER_NAME $hostname" 
        # config_hostname parauser 192.168.138.71 parauser ht1.r1.x71
        config_hostname $USER_NAME $ip $USER_NAME $hostname
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "ERROR: failed to config hostname at $ip " $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "make sure the file /etc/hostname at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    print_bgblack_fgwhite "function call ...... __cluster_config_hostname end ......" $common_parafs_output_tabs
}
###### 免密后修改 hosts
function __cluster_config_hosts() {
    print_bgblack_fgwhite "function call ...... __cluster_config_hostname begin ......" $common_parafs_output_tabs
    local fault_ips=""
    for config_ip in $CLUSTER_IPS; do
        config_hosts_comment $USER_NAME $config_ip $USER_NAME "#####parafs_config_begin#####"
        for cluster_ip in $CLUSTER_IPS; do
            local ip_hostname_alias=`grep $cluster_ip $NETWORK_CONFIG_FILE `
            local hostname=`echo $ip_hostname_alias | awk '{print $2}'`
            local hostalias=`echo $ip_hostname_alias | awk '{print $3}'`
            # config_hosts parauser 192.168.138.71 parauser 192.168.138.72 ht1.r2.n73 hia73
            #echo "config_hosts $USER_NAME $config_ip $USER_NAME $cluster_ip $hostname $hostalias"
            config_hosts $USER_NAME $config_ip $USER_NAME $cluster_ip $hostname $hostalias
            if [ $? -ne 0 ] ; then
                print_bgblack_fgred "ERROR: failed to config hosts at $config_ip " $common_parafs_output_tabs
                fault_ips="$config_ip $fault_ips"
                # break;
            fi
        done 
        config_hosts_comment $USER_NAME $config_ip $USER_NAME "#####parafs_config_end#####"
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "make sure the file /etc/hosts at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    print_bgblack_fgwhite "function call ...... __cluster_config_hosts end ......" $common_parafs_output_tabs
}

###############################################################################
###### 以下函数执行前需要ssh免密才能顺利进行
###############################################################################
###### common_parafs.sh ==>common_zip.sh
####### 免密后以免密用户分发文件, 此处分发会跳过本机
### 此处 dist_user用户下可以免密登陆 authorize_user@authorize_ip 
###      authorize_user 在remote_path 用户写权限
#### dist_file_path
#### dist_zip_file
#### remote_path
function __cluster_file_dist() {
    print_bgblack_fgwhite "function call ...... __cluster_file_dist begin ......" $common_parafs_output_tabs
    local dist_file_path=$1
    local dist_zip_file=$2
    local remote_path=$3

    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        if [ ${ip} = ${CLUSTER_LOCAL_IP}  ] ; then
            continue
        fi
        print_msg "file_dist $dist_file_path $dist_zip_file $USER_NAME ${ip} ${USER_NAME}  $remote_path"
        file_dist $USER_NAME ${ip} ${USER_NAME} $dist_file_path $dist_zip_file $remote_path
        if [ $? -ne 0 ] ; then 
            print_bgblack_fgred "file dist error to $ip " $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
   
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "make sure the file dist $dist_zip_file at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    print_bgblack_fgwhite "function call ...... __cluster_file_dist end ......" $common_parafs_output_tabs
}

###### 免密后检查分发文件的md5
### 此处 dist_user用户下可以免密登陆 authorize_user@authorize_ip 
###      authorize_user 在remote_path 用户可执行文件权限
### zip_file
### zip_md5_file
function __cluster_zipfile_check() {
    print_bgblack_fgwhite "function call ...... __cluster_zipfile_check begin ......" $common_parafs_output_tabs
    local zip_md5_file=$1
    local zip_md5_dir=$2
    local zip_file=$3
    local zip_file_dir=$4
    
    local md5=`cat ${zip_md5_dir}/$zip_md5_file |awk '{print $1}'`
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        if [ ${ip} = ${CLUSTER_LOCAL_IP}  ] ; then
            continue
        fi
        print_msg "check_zip_file $md5 $zip_file_dir $zip_file ${USER_NAME} $ip ${USER_NAME}"
        check_zip_file ${USER_NAME} $ip ${USER_NAME} $md5 $zip_file_dir $zip_file 
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "zip_file=$zip_file is damage at $ip " $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
        #file_dist $dist_filename $ip $user $passwd $remote_path
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "make sure the file dist $zip_file_dir at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    print_bgblack_fgwhite "function call ...... __cluster_zipfile_check end ......" $common_parafs_output_tabs
}

###### 免密后检查分发文件解压
### 此处 dist_user用户下可以免密登陆 authorize_user@authorize_ip 
###      authorize_user 在remote_path 用户写权限
### zip_file $1
### zip_file_dir $2
function __cluster_unzipfile() {
    print_bgblack_fgwhite "function call ...... __cluster_unzipfile begin ......" $common_parafs_output_tabs
    local zip_file=$1
    local zip_file_dir=$2

    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        if [ ${ip} = ${CLUSTER_LOCAL_IP}  ] ; then
            continue
        fi
        print_msg "unzip_file $zip_file_dir $zip_file $USER_NAME $ip $USER_NAME"
        unzip_file $USER_NAME $ip $USER_NAME $zip_file_dir $zip_file
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "failed to unzip $zip_file at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "make sure the file $zip_file_dir at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    print_bgblack_fgwhite "function call ...... __cluster_unzipfile end ......" $common_parafs_output_tabs
}

###############################################################################
###### 以下函数执行前需要ssh免密, 且远程文件存在
###############################################################################
###### slave配置
function __cluster_hadoop_slave() {
    print_bgblack_fgwhite "function call ...... __cluster_hadoop_slave begin ......" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $HADOOP_SLAVES" $common_parafs_output_tabs
    config_local_hadoop_slaves $HADOOP_SLAVES "${CLUSTER_IPS[*]}"
    local dist_file_path=`dirname $HADOOP_SLAVES`
    local dist_zip_file=`basename $HADOOP_SLAVES`
    local remote_path=`dirname $HADOOP_SLAVES`
    __cluster_file_dist $dist_file_path $dist_zip_file $remote_path
    print_bgblack_fgwhite "function call ...... __cluster_hadoop_slave end ......" $common_parafs_output_tabs
}

###### yarn配置文件
function __cluster_hadoop_xml() {
    print_bgblack_fgwhite "function call ...... __cluster_hadoop_xml begin......" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $HADOOP_YARN_XML" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        # update_hadoop_yarn_ip parauser 192.168.138.71 parauser \
        #     /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/yarn-site.xml \
        #     /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn_ip \
        #     192.168.1.299 
        # update_hadoop_yarn_mem parauser 192.168.138.71 parauser \
        #     /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/yarn-site.xml \
        #     /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn_mem 
        # update_hadoop_yarn_cpu parauser 192.168.138.71 parauser \
        #     /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/yarn-site.xml \
        #     /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn_cpus 
        update_hadoop_yarn_ip $USER_NAME ${ip} $USER_NAME ${HADOOP_YARN_XML} ${SED_SCRIPT_HADOOP_YARN_IP} ${MASTER_IP} \
        && update_hadoop_yarn_mem $USER_NAME ${ip} $USER_NAME ${HADOOP_YARN_XML} ${SED_SCRIPT_HADOOP_YARN_MEM}         \
        && update_hadoop_yarn_cpu $USER_NAME ${ip} $USER_NAME ${HADOOP_YARN_XML} ${SED_SCRIPT_HADOOP_YARN_CPUS}
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config ${HADOOP_YARN_XML} at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "Make sure the file ${HADOOP_YARN_XML} at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    print_bgblack_fgwhite "function call ...... __cluster_hadoop_xml end" $common_parafs_output_tabs
}

###### spark slave配置 可以考虑软连接hadoop
function __cluster_spark_slave() {
    print_bgblack_fgwhite "function call ...... __cluster_spark_slave begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $SPARK_SLAVES" $common_parafs_output_tabs
    config_local_hadoop_slaves $SPARK_SLAVES "${CLUSTER_IPS[*]}"
    local dist_file_path=`dirname $SPARK_SLAVES`
    local dist_zip_file=`basename $SPARK_SLAVES`
    local remote_path=`dirname $SPARK_SLAVES`
    __cluster_file_dist $dist_file_path $dist_zip_file $remote_path
    print_bgblack_fgwhite "function call ...... __cluster_spark_slave end" $common_parafs_output_tabs
}

function __cluster_spark_env() {
    print_bgblack_fgwhite "function call ...... __cluster_spark_env begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $SPARK_ENV" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        # update_spark_env parauser 192.168.138.71 parauser \
        #     /opt/wotung/hadoop-parafs/spark-2.0.1/conf/spark-env.sh \
        #     /opt/wotung/parafs-install/conf/sed_script/spark/spark_env \
        #     192.168.1.299
        # update_spark_conf parauser 192.168.138.71 parauser \
        #     /opt/wotung/hadoop-parafs/spark-2.0.1/conf/spark-defaults.conf \
        #     /opt/wotung/parafs-install/conf/sed_script/spark/spark_defaults
        update_spark_env $USER_NAME $ip $USER_NAME $SPARK_ENV $SED_SCRIPT_SPARK_ENV $MASTER_IP\
        && update_spark_conf $USER_NAME $ip $USER_NAME $SPARK_CONF $SED_SCRIPT_SPARK_CONF 
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config ${SPARK_ENV} at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "Make sure the file ${SPARK_ENV} at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    print_bgblack_fgwhite "function call ...... __cluster_spark_env end" $common_parafs_output_tabs
}

function __cluster_spark_sql() {
    echo -e "\t\t __cluster_spark_sql begin"
    echo "+++++++++ do nothing +++++++"
#    update_spark_sql_config
    echo -e "\t\t __cluster_spark_sql end"
}
###### 
function __cluster_zookeeper_conf() {
    print_bgblack_fgwhite "function call ...... __cluster_zookeeper_conf begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $ZOOKEEPER_CONF" $common_parafs_output_tabs
    config_local_zookeeper_conf $ZOOKEEPER_CONF $ZOOKEEPER_DATA $ZOOKEEPER_DATA_LOG "${CLUSTER_IPS[*]}"
    local dist_file_path=`dirname $ZOOKEEPER_CONF`
    local dist_zip_file=`basename $ZOOKEEPER_CONF`
    local remote_path=`dirname $ZOOKEEPER_CONF`
    __cluster_file_dist $dist_file_path $dist_zip_file $remote_path
    print_bgblack_fgwhite "function call ...... __cluster_zookeeper_conf end" $common_parafs_output_tabs
}

function __cluster_zookeeper_myid() {
    print_bgblack_fgwhite "function call ...... __cluster_zookeeper_myid begin" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        # update_zookeeper_myid parauser 192.168.138.71 parauser \
        #     /opt/wotung/hadoop-parafs/zookeeper-3.4.10/zk-data/myid 
        update_zookeeper_myid $USER_NAME $ip $USER_NAME $ZOOKEEPER_MY_ID
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config ${ZOOKEEPER_MY_ID} at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "Make sure the file ${ZOOKEEPER_MY_ID} at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    
    print_bgblack_fgwhite "function call ...... __cluster_zookeeper_myid end" $common_parafs_output_tabs
}

###### spark slave配置 可以考虑软连接hadoop
function __cluster_hbase_regeionservers() {
    print_bgblack_fgwhite "function call ...... __cluster_hbase_regeionservers begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $HBASE_REGEION_SERVERS " $common_parafs_output_tabs
    config_local_hadoop_slaves $HBASE_REGEION_SERVERS "${CLUSTER_IPS[*]}"
    local dist_file_path=`dirname $HBASE_REGEION_SERVERS`
    local dist_zip_file=`basename $HBASE_REGEION_SERVERS`
    local remote_path=`dirname $HBASE_REGEION_SERVERS`
    __cluster_file_dist $dist_file_path $dist_zip_file $remote_path
    print_bgblack_fgwhite "function call ...... __cluster_hbase_regeionservers end" $common_parafs_output_tabs
}

function __cluster_hbase_xml() {
    print_bgblack_fgwhite "function call ...... __cluster_hbase_xml begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $HBASE_CONF" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        # update_hbase_config parauser 192.168.138.71 parauser \
        #     /opt/wotung/hadoop-parafs/hbase-1.2.5/conf/hbase-site.xml \
        #     /opt/wotung/parafs-install/conf/sed_script/hbase/hbase_conf \
        #     192..168.1.1213 \
        #     "${CLUSTER_IPS[*]}"
        update_hbase_config $USER_NAME $ip $USER_NAME $HBASE_CONF $SED_SCRIPT_HBASE_CONF $MASTER_IP "${CLUSTER_IPS[*]}"
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config ${HBASE_CONF} at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "Make sure the file ${HBASE_CONF} at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    
    print_bgblack_fgwhite "function call ...... __cluster_hbase_xml end" $common_parafs_output_tabs
}

function __cluster_hive_xml() {
    print_bgblack_fgwhite "function call ...... __cluster_hive_xml begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $HIVE_CONF" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        # update_hive_config parauser 192.168.138.71 parauser \
        #     /opt/wotung/hadoop-parafs/hive-2.1.1/conf/hive-site.xml \
        #     /opt/wotung/parafs-install/conf/sed_script/hive/hive_conf \
        #     192..168.1213.abx 
        update_hive_config $USER_NAME $ip $USER_NAME ${HIVE_CONF} ${SED_SCRIPT_HIVE_CONF} ${MASTER_IP}
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config ${HIVE_CONF} at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "Make sure the file ${HIVE_CONF} at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    
    print_bgblack_fgwhite "function call ...... __cluster_hive_xml end" $common_parafs_output_tabs
}

function __cluster_azkaban_properties() {
    print_bgblack_fgwhite "function call ...... __cluster_azkaban_properties begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $AZKABAN_WEB_CONF " $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $AZKABAN_EXEC_CONF" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        # update_azkaban_config parauser 192.168.138.71 parauser \
        #     /opt/wotung/hadoop-parafs/azkaban/azkaban-exec-server-3.41.0/conf/azkaban.properties \
        #     # azkaban/azkaban-web-server-3.41.0/conf/azkaban.properties
        #     /opt/wotung/parafs-install/conf/sed_script/azkaban/azkaban_conf \
        #     192.168.1213.abx 
        update_azkaban_config $USER_NAME $ip $USER_NAME $AZKABAN_EXEC_CONF $SED_SCRIPT_AZKABAN_CONF ${MASTER_IP}
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config ${AZKABAN_EXEC_CONF} at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
        update_azkaban_config $USER_NAME $ip $USER_NAME $AZKABAN_WEB_CONF $SED_SCRIPT_AZKABAN_CONF ${MASTER_IP} 
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config ${AZKABAN_WEB_CONF} at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "Make sure the file ${AZKABAN_EXEC_CONF}|${AZKABAN_WEB_CONF} at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    
    print_bgblack_fgwhite "function call ...... __cluster_azkaban_properties end" $common_parafs_output_tabs
}

function __cluster_kafka_connect() { 
    print_bgblack_fgwhite "function call ...... __cluster_kafka_connect begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $KAFKA_CONF" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        # update_kafka_config parauser 192.168.138.71 parauser \
        #     /opt/wotung/hadoop-parafs/kafka_2.11-1.0.1/config/server.properties \
        #     /opt/wotung/parafs-install/conf/sed_script/kafka/kafka_conf\
        #     "${CLUSTER_IPS[*]}"
        update_kafka_config $USER_NAME $ip $USER_NAME $KAFKA_CONF $SED_SCRIPT_KAFKA_CONF "${CLUSTER_IPS[*]}"

        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config ${KAFKA_CONF} at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "Make sure the file ${KAFKA_CONF} at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    
    print_bgblack_fgwhite "function call ...... __cluster_kafka_connect end" $common_parafs_output_tabs
}

function __cluster_kafka_broker_id() {
    print_bgblack_fgwhite "function call ...... __cluster_kafka_broker_id begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $KAFKA_CONF" $common_parafs_output_tabs
    local broker_id=0
    for ip in $CLUSTER_IPS; do
        if [ ${ip} != $MASTER_IP ] ; then
			update_kafka_broker_id $USER_NAME $ip $USER_NAME $KAFKA_CONF $SED_SCRIPT_KAFKA_BROKER_ID $broker_id
        fi
        broker_id=$(($broker_id+1))
    done

    print_bgblack_fgwhite "function call ...... __cluster_kafka_broker_id end" $common_parafs_output_tabs
}

function __cluster_ycsb_hbase_xml() {
    print_bgblack_fgwhite "function call ...... __cluster_ycsb_hbase_xml begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $YCSB_HBASE12_CONF" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        update_hbase_config $USER_NAME $ip $USER_NAME $YCSB_HBASE12_CONF $SED_SCRIPT_HBASE_CONF $MASTER_IP "${CLUSTER_IPS[*]}"
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config ${YCSB_HBASE12_CONF} at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "Make sure the file ${YCSB_HBASE12_CONF} at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    
    print_bgblack_fgwhite "function call ...... __cluster_ycsb_hbase_xml end" $common_parafs_output_tabs
}
function __cluster_spark_bench_legacy_env() {
    print_bgblack_fgwhite "function call ...... __cluster_spark_bench_legacy_env begin" $common_parafs_output_tabs
    print_bgblack_fgwhite "    config $SPARK_BENCH_LEGACY_ENV" $common_parafs_output_tabs
    local fault_ips=""
    for ip in $CLUSTER_IPS; do
        update_bench_legacy_env $USER_NAME $ip $USER_NAME $SPARK_BENCH_LEGACY_ENV $SED_SCRIPT_SPARK_BENCH_LEGACY_ENV $MASTER_IP 
        if [ $? -ne 0 ] ; then
            print_bgblack_fgred "Failed to config ${SPARK_BENCH_LEGACY_ENV} at $ip" $common_parafs_output_tabs
            fault_ips="$ip $fault_ips"
            # break;
        fi
    done
    if [ ! -z "$fault_ips" ]; then
        print_bgblack_fgred "Make sure the file ${SPARK_BENCH_LEGACY_ENV} at $fault_ips" $common_parafs_output_tabs
        exit 1
    fi
    
    print_bgblack_fgwhite "function call ...... __cluster_spark_bench_legacy_env end" $common_parafs_output_tabs

}
###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
COMMON_BASH_NAME=common_parafs.h
if [ -z "$VARIABLE_BASH_NAME" ] ; then 
    . ../../variable.sh
fi
if [ -z "$UTILS_BASH_NAME" ]; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_utils.sh
fi
if [ -z "$USER_BASH_NAME" ]; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_user.sh
fi
if [ -z "$ZIP_BASH_NAME" ]; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_zip.sh
fi
if [ -z "$NETWORK_BASH_NAME" ]; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_network.sh
fi
if [ -z "$COMMON_CONFIG_BASH_NAME" ]; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_config.sh
fi
if [ -z "$COMMON_INSTALL_BASH_NAME" ]; then
    . ${SCRIPT_BASE_DIR}/parafs/common/common_install.sh
fi
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi
common_parafs_output_tabs="3"
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# __cluster_check_user parauser false
# __cluster_create_user  "parauser" "YdwAWdHXqldYI" "/home/parauser"  "/bin/bash"
# __cluster_config_sudoers parauser
# __cluster_delete_user parauser
# __cluster_file_dist  /opt/wotung parafs-install.tgz /opt/wotung
# __cluster_zipfile_check parafs-install.tar.gz.md5sum parafs-install.tar.gz /opt/wotung
# __cluster_unzipfile parafs-install.tgz /opt/wotung
#echo $?
######
# __cluster_config_hostname
# __cluster_config_hosts
# echo $?
# __config_hadoop_slaves parauser 192.168.138.70 parauser /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/slaves
# __cluster_hadoop_slave 
# __cluster_hadoop_xml
# __cluster_spark_slave
# __cluster_spark_env
# __cluster_spark_sql
# __cluster_zookeeper_conf
# __cluster_zookeeper_myid
# __cluster_hbase_regeionservers
# __cluster_hbase_xml
# __cluster_hive_xml
# __cluster_azkaban_properties
# __cluster_kafka_connect
# __cluster_kafka_broker_id
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
