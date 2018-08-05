#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################

function tools_usage() {
    echo "检查指定ip的node"
    echo "新建一个parauser";
    echo "同一用户免密"
    echo "dist file to some computer";
    echo "删除用户";
    echo "集群新增一台机器"
    echo "集群删除一台机器"
}

### userdel -r parauser
### sed -i '/parauser/'d /etc/sudoers
function __cluster_delete_user() {
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
        
        $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$delete_user" >/dev/null
        $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$config_sudoer" >/dev/null

    done
    
    echo -e "\t\t cluster_delete_user end"
}

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
TOOLS_BASH_NAME=parafs_tools.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi

# local user_passwd_file=${USER_PASSWD}
# local username=`grep user $user_passwd_file | grep -v '^#' | awk -F "=" '{print $2}'`
# test -z "$username"  &&  username="parauser" 
# cluster_delete_user $username

###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# __cluster_delete_user parauser
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
