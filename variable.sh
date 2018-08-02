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
INSTALL_PACAKGE_FILE=${BASE_DIR}/parafs.tar.gz
INSTALL_PACAKGE_MD5=${BASE_DIR}/parafs.md5sum
PASSWD_CONFIG_FILE=${BASE_DIR}/conf/passwd
NETWORK_CONFIG_FILE=${BASE_DIR}/conf/networks
USER_PASSWD=${BASE_DIR}/conf/user_passwd
INSTALLONLY_CONFIG_FILE=${BASE_DIR}/conf/installonly
BASHRC_CONFIG_FILE=${BASE_DIR}/conf/bashrc

SSH_EXP_LOGIN=${BASE_DIR}/parafs/expect_common/ssh_login.exp
SSH_REMOTE_EXEC=${BASE_DIR}/parafs/expect_common/ssh_remote_exec.exp
SSH_EXP_AUTHORIZE=${BASE_DIR}/parafs/expect_common/current_authorize.exp

#以下变量请不要赋值变更
# ip数组
IP_ARRAY=
IPLongShortArray=
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

IP_ARRAY=`cat ${NETWORK_CONFIG_FILE} |grep -v "^#" | awk -F " " '{print $1}'`    
IPLongShortArray=`cat ${NETWORK_CONFIG_FILE} |grep -v "^#"  | awk -F " " '{print $1","$2","$3}'` 	  
   
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
