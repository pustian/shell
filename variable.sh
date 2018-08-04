#!/bin/bash
###++++++++++++++++++++++++      const variable   ++++++++++++++++++++++++++###
function IsLocalIP() 
{
 local ip=$1
 local itself=`ip addr |grep ${ip}`
 if [ x"${itself}" = "x" ]; then
     return 1
 else
     return 0
 fi
}

VARIABLE_BASH_NAME=variable.sh

###### 安装相关文件
INSTALL_DIR=/opt/wotung

BASE_DIR=/opt/wotung/parafs-install
###### 相关配置文件
PASSWD_CONFIG_FILE=${BASE_DIR}/conf/passwd
NETWORK_CONFIG_FILE=${BASE_DIR}/conf/networks
USER_PASSWD_FILE=${BASE_DIR}/conf/user_passwd
MISC_CONF_FILE=${BASE_DIR}/conf/misc_config
INSTALLONLY_CONFIG_FILE=${BASE_DIR}/conf/installonly
BASHRC_CONFIG_FILE=${BASE_DIR}/conf/bashrc

###### EXPECT 相关代码
SSH_EXP_LOGIN=${BASE_DIR}/parafs/expect_common/ssh_login.exp
SSH_EXP_COPY=${BASE_DIR}/parafs/expect_common/ssh_copy.exp
SSH_REMOTE_EXEC=${BASE_DIR}/parafs/expect_common/ssh_remote_exec.exp
SSH_EXP_AUTHORIZE=${BASE_DIR}/parafs/expect_common/current_authorize.exp

###### 安装文件,不包含目录 misc_config
SCRIPT_FILE=`grep '^parafs_install_file=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
SCRIPT_MD5_FILE=`grep '^parafs_install_file_md5=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
PARAFS_RPM=`grep '^parafs_rpm=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
PARAFS_MD5_RPM=`grep '^parafs_rpm_md5=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
LLOG_RPM=`grep '^llog_rpm=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
LLOG_MD5_RPM=`grep '^llog_rpm_md5=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
HADOOP_FILE=`grep '^parafs_hadoop_file=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
HADOOP_MD5_FILE=`grep '^parafs_hadoop_file_md5=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`

###### 新建用户名 user_passwd
USER_NAME=`grep '^user=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
USER_PASSWD=`grep '^passwd_plain=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
USER_PASSWD_SSL=`grep '^passwd_ssl=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
USER_HOME=`grep '^home=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
USER_SHELL=`grep '^shell=' $USER_PASSWD_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
test -z "$USER_NAME"  &&  USER_NAME="parauser" 
test -z "$USER_HOME"  &&  USER_HOME="/home/$username"
test -z "$USER_SHELL" &&  USER_SHELL="/bin/bash"  
if [ -z $USER_PASSWD ] || [ -z $USER_PASSWD_SSL ] ; then
    echo "please generate a encrpt passwd config the conf/user_passwd"
    exit 1
fi
# echo "USER_NAME $USER_NAME"
# echo "USER_PASSWD $USER_PASSWD"
# echo "USER_PASSWD_SSL $USER_PASSWD_SSL"
# echo "USER_HOME $USER_HOME"
# echo "USER_SHELL $USER_SHELL"

#######
CLUSTER_IPS=`cat ${NETWORK_CONFIG_FILE} |grep -v '^#' | awk -F " " '{print $1}'` 
####### PASSWD_CONFIG_FILE 中默认用户
DEFAULT_USER=`grep 'default_user=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
DEFAULT_USER_HOME=`grep 'default_user_home=' $MISC_CONF_FILE | grep -v '^#' | awk -F "=" '{print $2}'`
test -z "$DEFAULT_USER" && DEFAULT_USER=root
test -z "$DEFAULT_USER_HOME" && DEFAULT_USER_HOME=/root

# echo $CLUSTER_IPS
# echo $DEFAULT_USER
# echo $DEFAULT_USER_HOME

###### ipv4
CLUSTER_LOCAL_IP=
for local_ip in `ip addr |grep inet |awk '{print $2}' |awk -F '/' '{print $1}' |grep -e '^[1|2][0-9]' `; do
    CLUSTER_LOCAL_IP=`grep $local_ip $NETWORK_CONFIG_FILE | awk '{print $1}'`
    if [ ! -z "$CLUSTER_LOCAL_IP" ]; then
        break;
    fi
done
# echo $CLUSTER_LOCAL_IP


#以下变量请不要赋值变更
# ip数组
IP_ARRAY=`cat ${NETWORK_CONFIG_FILE} |grep -v "^#" | awk -F " " '{print $1}'`    
IPLongShortArray=`cat ${NETWORK_CONFIG_FILE} |grep -v "^#"  | awk -F " " '{print $1","$2","$3}'` 	  

# 本机IP
Local_IP=
# master ip
Master_IP=
# 本机长名
Local_LongName=
# 本机短名
Local_ShortName=
# 允许安装的ip
IpInstallOnly="${BASE_DIR}/conf/installonly"

# parafs安装文件
InstallParafsFiles="${BASE_DIR}/conf/InstallParafsFiles"

# parafs 复制文件
CopyFiles="${BASE_DIR}/conf/CopyFiles"

   
for ip in ${IP_ARRAY}; do
	Master_IP=$ip
	break
done
         
for ip in ${IP_ARRAY}; do
	 IsLocalIP ${ip} 
	 if [ $? -eq 0 ];  then
	 	Local_IP=${ip}
	 	Local_ShortName=`grep ${ip} ${NETWORK_CONFIG_FILE}|grep -v "^#" |awk -F " " '{print $3}'`
	 	Local_LongName=`grep ${ip} ${NETWORK_CONFIG_FILE}|grep -v "^#" |awk -F " " '{print $2}'`
		break
	 fi 
done
