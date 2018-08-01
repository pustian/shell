#!/bin/bash
###++++++++++++++++++++++++      const variable   ++++++++++++++++++++++++++###
# BASE_DIR=/opt/wotung/parafs-install
VARIABLE_BASH_NAME=variable.sh
BASE_DIR=/opt/wotung/parafs-install
INSTALL_PACAKGE_FILE=${BASE_DIR}/parafs.tar.gz
INSTALL_PACAKGE_MD5=${BASE_DIR}/parafs.md5sum
PASSWD_CONFIG_FILE=${BASE_DIR}/conf/passwd
NETWORK_CONFIG_FILE=${BASE_DIR}/conf/networks
USER_PASSWD=${BASE_DIR}/conf/user_passwd

SSH_EXP_LOGIN=${BASE_DIR}/parafs/expect_common/ssh_login.exp
SSH_REMOTE_EXEC=${BASE_DIR}/parafs/expect_common/ssh_remote_exec.exp
SSH_EXP_AUTHORIZE=${BASE_DIR}/parafs/expect_common/current_authorize.exp
