#!/bin/bash
###++++++++++++++++++++++++      const variable   ++++++++++++++++++++++++++###
VARIABLE_BASH_NAME=variable.sh

###### 安装相关文件目录不可变更
INSTALL_DIR=/opt/wotung
###### 脚本根目录支持parafs-install 不在/opt/wotung目录下
BASE_DIR=/opt/wotung/parafs-install

###### EXPECT 相关代码
SSH_EXP_LOGIN=${BASE_DIR}/parafs/expect_common/ssh_login.exp
SSH_EXP_COPY=${BASE_DIR}/parafs/expect_common/ssh_copy.exp
SSH_REMOTE_EXEC=${BASE_DIR}/parafs/expect_common/ssh_remote_exec.exp
SSH_EXP_AUTHORIZE=${BASE_DIR}/parafs/expect_common/current_authorize.exp

###### 相关配置文件
NETWORK_CONFIG_FILE=${BASE_DIR}/conf/networks
PASSWD_CONFIG_FILE=${BASE_DIR}/conf/passwd
MISC_CONF_FILE=${BASE_DIR}/conf/misc_config
USER_PASSWD_FILE=${BASE_DIR}/conf/user_passwd

###### 修改配置文件
BASHRC_CONFIG_FILE=${BASE_DIR}/conf/bashrc

###### CLUSTER网络配置 ip hostname alias 最终需要添加到 /etc/hosts
CLUSTER_IPS=`cat ${NETWORK_CONFIG_FILE} |grep -v '^#' | awk -F " " '{print $1}'` 

###### 需要创建parauser 的所有机器，root密码

###### 安装文件,不包含目录 misc_config
SCRIPT_FILE=`basename $BASE_DIR`.tar.gz
SCRIPT_MD5_FILE=${SCRIPT_MD5_FILE}.md5sum
PARAFS_RPM=`grep '^parafs_rpm=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
PARAFS_MD5_RPM=`grep '^parafs_rpm_md5=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
LLOG_RPM=`grep '^llog_rpm=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
LLOG_MD5_RPM=`grep '^llog_rpm_md5=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
HADOOP_FILE=`grep '^parafs_hadoop_file=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
HADOOP_MD5_FILE=`grep '^parafs_hadoop_file_md5=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
PIP_SOURCE=`grep '^pip_source=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
DEFAULT_USER=`grep 'default_user=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
DEFAULT_USER_HOME=`grep 'default_user_home=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
test -z "$DEFAULT_USER" && DEFAULT_USER=root
test -z "$DEFAULT_USER_HOME" && DEFAULT_USER_HOME=/root
if [ -z $PARAFS_RPM ] || [ -z $LLOG_RPM ] || [ -z $HADOOP_FILE ] ; then
    echo "please confirm the file $MISC_CONF_FILE "
    exit 1
fi
# echo "SCRIPT_FILE    =$SCRIPT_FILE    " 
# echo "SCRIPT_MD5_FILE=$SCRIPT_MD5_FILE" 
# echo "PARAFS_RPM     =$PARAFS_RPM     " 
# echo "PARAFS_MD5_RPM =$PARAFS_MD5_RPM " 
# echo "LLOG_RPM       =$LLOG_RPM       " 
# echo "LLOG_MD5_RPM   =$LLOG_MD5_RPM   " 
# echo "HADOOP_FILE    =$HADOOP_FILE    " 
# echo "HADOOP_MD5_FILE=$HADOOP_MD5_FILE" 
# echo "PIP_SOURCE     =$PIP_SOURCE     " 

###### 新建用户名 user_passwd 所需要 passwd
USER_NAME=`grep '^user=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
USER_PASSWD=`grep '^passwd_plain=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
USER_PASSWD_SSL=`grep '^passwd_ssl=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
USER_HOME=`grep '^home=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
USER_SHELL=`grep '^shell=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
test -z "$USER_NAME"  &&  USER_NAME="parauser" 
test -z "$USER_HOME"  &&  USER_HOME="/home/$username"
test -z "$USER_SHELL" &&  USER_SHELL="/bin/bash"  
if [ -z $USER_PASSWD ] || [ -z $USER_PASSWD_SSL ] ; then
    echo "please confirm the file $USER_PASSWD_FILE "
    exit 1
fi
# echo "USER_NAME      =$USER_NAME"
# echo "USER_PASSWD    =$USER_PASSWD"
# echo "USER_PASSWD_SSL=$USER_PASSWD_SSL"
# echo "USER_HOME      =$USER_HOME"
# echo "USER_SHELL     =$USER_SHELL"

# echo $CLUSTER_IPS
# echo $DEFAULT_USER
# echo $DEFAULT_USER_HOME

###### ipv4本机器在机群上的ip
CLUSTER_LOCAL_IP=
for local_ip in `ip addr |grep inet |awk '{print $2}' |awk -F '/' '{print $1}' |grep -e '^[1|2][0-9]' `; do
    CLUSTER_LOCAL_IP=`grep $local_ip $NETWORK_CONFIG_FILE | awk '{print $1}'`
    if [ ! -z "$CLUSTER_LOCAL_IP" ]; then
        break;
    fi
done
# echo "CLUSTER_LOCAL_IP=$CLUSTER_LOCAL_IP"

# /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/slaves
HADOOP_SLAVES=$INSTALL_DIR/hadoop-parafs/hadoop-2.7.3/etc/hadoop/slaves
#### sed 文件位置
HADOOP_YARN_SED=${BASE_DIR}/conf/
