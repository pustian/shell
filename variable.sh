#!/bin/bash
###++++++++++++++++++++++++      const variable   ++++++++++++++++++++++++++###
VARIABLE_BASH_NAME=variable.sh

###### 安装相关文件目录不可变更
INSTALL_DIR=/opt/wotung
###### 脚本根目录支持parafs-install 不在/opt/wotung目录下
SCRIPT_BASE_DIR=/opt/wotung/parafs-install
INSTALL_LOG=$SCRIPT_BASE_DIR/parafs-install.log
SCRIPT_FILE=`basename $SCRIPT_BASE_DIR`.tar.gz
SCRIPT_MD5_FILE=${SCRIPT_MD5_FILE}.md5sum
if test ! -d $SCRIPT_BASE_DIR ; then
    echo -e "\033[31mmake sure the script at $SCRIPT_BASE_DIR\033[0m" 
    exit 1 
fi
# echo "SCRIPT_FILE    =$SCRIPT_FILE    " 
# echo "SCRIPT_MD5_FILE=$SCRIPT_MD5_FILE" 

###### EXPECT 相关代码
SSH_EXP_LOGIN=${SCRIPT_BASE_DIR}/parafs/expect_common/ssh_login.exp
SSH_EXP_SECOND_LOGIN=${SCRIPT_BASE_DIR}/parafs/expect_common/ssh_second_login.exp
SSH_EXP_COPY=${SCRIPT_BASE_DIR}/parafs/expect_common/ssh_copy.exp
SSH_REMOTE_EXEC=${SCRIPT_BASE_DIR}/parafs/expect_common/ssh_remote_exec.exp
SSH_EXP_AUTHORIZE=${SCRIPT_BASE_DIR}/parafs/expect_common/current_authorize.exp
###### 相关配置文件
NETWORK_CONFIG_FILE=${SCRIPT_BASE_DIR}/conf/networks
USER_PASSWD_FILE=${SCRIPT_BASE_DIR}/conf/user_passwd
MISC_CONF_FILE=${SCRIPT_BASE_DIR}/conf/misc_config
PASSWD_CONFIG_FILE=${SCRIPT_BASE_DIR}/conf/passwd
###### 修改配置文件
BASHRC_CONFIG_FILE=${SCRIPT_BASE_DIR}/conf/bashrc

###### sed_script 文件位置
SED_SCRIPT_HADOOP_YARN_IP=${SCRIPT_BASE_DIR}/conf/sed_script/hadoop/hadoop_yarn_ip
SED_SCRIPT_HADOOP_YARN_MEM=${SCRIPT_BASE_DIR}/conf/sed_script/hadoop/hadoop_yarn_mem
SED_SCRIPT_HADOOP_YARN_CPUS=${SCRIPT_BASE_DIR}/conf/sed_script/hadoop/hadoop_yarn_cpus
SED_SCRIPT_SPARK_ENV=${SCRIPT_BASE_DIR}/conf/sed_script/spark/spark_defaults
SED_SCRIPT_SPARK_CONF=${SCRIPT_BASE_DIR}/conf/sed_script/spark/spark_env
SED_SCRIPT_HBASE_CONF=${SCRIPT_BASE_DIR}/conf/sed_script/hbase/hbase_conf
SED_SCRIPT_HIVE_CONF=${SCRIPT_BASE_DIR}/conf/sed_script/hive/hive_conf
SED_SCRIPT_AZKABAN_CONF=${SCRIPT_BASE_DIR}/conf/sed_script/azkaban/azkaban_conf 
SED_SCRIPT_KAFKA_CONF=${SCRIPT_BASE_DIR}/conf/sed_script/kafka/kafka_conf
SED_SCRIPT_KAFKA_BROKER_ID=${SCRIPT_BASE_DIR}/conf/sed_script/kafka/kafka_broker_id
SED_SCRIPT_SPARK_BENCH_LEGACY_ENV=${SCRIPT_BASE_DIR}/conf/sed_script/spark_bench_legacy/spark_bench_legacy_env

###### CLUSTER网络配置 ip hostname alias 最终需要添加到 /etc/hosts
CLUSTER_IPS=`cat ${NETWORK_CONFIG_FILE} |grep -v '^#' | awk -F " " '{print $1}'` 
###### ipv4本机器在机群上的ip
CLUSTER_LOCAL_IP=
for local_ip in `ip addr |grep inet |awk '{print $2}' |awk -F '/' '{print $1}' |grep -e '^[1|2][0-9]' `; do
    CLUSTER_LOCAL_IP=`grep $local_ip $NETWORK_CONFIG_FILE | awk '{print $1}'`
    if [ ! -z "$CLUSTER_LOCAL_IP" ]; then
        break;
    fi
done
# echo "CLUSTER_LOCAL_IP=$CLUSTER_LOCAL_IP"

###### 需要创建parauser 的所有机器，root密码
###### 新建用户名 user_passwd 所需要 passwd
# USER_NAME=`grep '^user=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
# USER_PASSWD=`grep '^passwd_plain=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
# USER_PASSWD_SSL=`grep '^passwd_ssl=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
# USER_HOME=`grep '^home=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
# USER_SHELL=`grep '^shell=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
# test -z "$USER_NAME"  &&  USER_NAME="parauser" 
# test -z "$USER_HOME"  &&  USER_HOME="/home/$username"
# test -z "$USER_SHELL" &&  USER_SHELL="/bin/bash"  
# change user to root, may change...
# if [ -z $USER_PASSWD ] || [ -z $USER_PASSWD_SSL ] ; then
#     echo -e "\033[31mplease confirm the file $USER_PASSWD_FILE,\033[0m"
#     echo -e "\033[31m    the passwd_plain and passwd_ssl are must\033[0m"
#     exit 1
# fi
USER_NAME='root'
USER_HOME='/root'
# echo "USER_NAME      =$USER_NAME"
# echo "USER_PASSWD    =$USER_PASSWD"
# echo "USER_PASSWD_SSL=$USER_PASSWD_SSL"
# echo "USER_HOME      =$USER_HOME"
# echo "USER_SHELL     =$USER_SHELL"

###### 安装文件,不包含目录 misc_config
SOURCE_DIR=`grep '^source_dir' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
PARAFS_RPM=`grep '^parafs_rpm' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
PARAFS_MD5_RPM=`grep '^md5_parafs_rpm' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
LLOG_RPM=`grep '^llog_rpm' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
LLOG_MD5_RPM=`grep '^md5_llog_rpm' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
HADOOP_FILE=`grep '^parafs_hadoop_file' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
HADOOP_MD5_FILE=`grep '^md5_parafs_hadoop_file' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
PIP_SOURCE=`grep '^pip_source' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
DEFAULT_USER=`grep 'default_user=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
DEFAULT_USER_HOME=`grep 'default_user_home=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
MASTER_IP=`grep 'master_ip' $NETWORK_CONFIG_FILE | grep -v '^#' | awk -F " " '{print $1}'`
test -z "$DEFAULT_USER" && DEFAULT_USER=root
test -z "$DEFAULT_USER_HOME" && DEFAULT_USER_HOME=/root

#echo "#$SOURCE_DIR#"
#echo "#$PARAFS_RPM#" 
#echo "#$PARAFS_MD5_RPM#" 
#echo "#$LLOG_RPM#" 
#echo "#$LLOG_MD5_RPM#" 
#echo "#$HADOOP_FILE#" 
#echo "#$HADOOP_MD5_FILE#" 
#echo "#$PIP_SOURCE#" 
#echo "#$DEFAULT_USER#"
#echo "#$DEFAULT_USER_HOME#"
#echo "#$MASTER_IP#"

#####################################################################
HADOOP_PARAFS_HOME=`grep '^export HADOOP_PARAFS_HOME=' $BASHRC_CONFIG_FILE | awk -F "=" '{print $2}'`
# echo "HADOOP_PARAFS_HOME=$HADOOP_PARAFS_HOME"
###### hadoop相关配置文件
HADOOP_SLAVES=${HADOOP_PARAFS_HOME}/hadoop-2.7.3/etc/hadoop/slaves
HADOOP_YARN_XML=${HADOOP_PARAFS_HOME}/hadoop-2.7.3/etc/hadoop/yarn-site.xml
SPARK_SLAVES=${HADOOP_PARAFS_HOME}/spark-2.0.1/conf/slaves
SPARK_ENV=${HADOOP_PARAFS_HOME}/spark-2.0.1/conf/spark-env.sh
SPARK_CONF=${HADOOP_PARAFS_HOME}/spark-2.0.1/conf/spark-defaults.conf
ZOOKEEPER_CONF=${HADOOP_PARAFS_HOME}/zookeeper-3.4.10/conf/zoo.cfg
ZOOKEEPER_MY_ID=${HADOOP_PARAFS_HOME}/zookeeper-3.4.10/zk-data/myid
ZOOKEEPER_DATA=${HADOOP_PARAFS_HOME}/zookeeper-3.4.10/zk-data
ZOOKEEPER_DATA_LOG=${HADOOP_PARAFS_HOME}/zookeeper-3.4.10/zk-logs
HBASE_REGEION_SERVERS=${HADOOP_PARAFS_HOME}/hbase-1.2.5/conf/regionservers
HBASE_CONF=${HADOOP_PARAFS_HOME}/hbase-1.2.5/conf/hbase-site.xml
HBASE_BACKUP_MASTERS=${HADOOP_PARAFS_HOME}/hbase-1.2.5/conf/backup-masters
HIVE_CONF=${HADOOP_PARAFS_HOME}/hive-2.1.1/conf/hive-site.xml
SPARK_HIVE_CONF=${HADOOP_PARAFS_HOME}/spark-2.0.1/conf/hive-site.xml
AZKABAN_EXEC_CONF=${HADOOP_PARAFS_HOME}/azkaban/azkaban-exec-server-3.41.0/conf/azkaban.properties
AZKABAN_WEB_CONF=${HADOOP_PARAFS_HOME}/azkaban/azkaban-web-server-3.41.0/conf/azkaban.properties
KAFKA_CONF=${HADOOP_PARAFS_HOME}/kafka_2.11-1.0.1/config/server.properties
SPARK_BENCH_LEGACY_ENV=${HADOOP_PARAFS_HOME}/spark-bench-legacy/conf/env.sh
YCSB_HBASE12_CONF=${HADOOP_PARAFS_HOME}/ycsb-hbase12/conf/hbase-site.xml
# echo "====================variable loaded==========="
