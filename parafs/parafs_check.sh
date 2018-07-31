#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
function check_usage() {
    echo "cluster-check-firewall"
    echo "cluster-check-iptable"
    echo "cluster-ntpdate"
    echo "cluster-install"
    echo "cluster-bashrc-config"
}
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
CHEC_BASH_NAME=parafs_check.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . /opt/wotung/parafs-install/common/utils.sh
fi

###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
#check_usage
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
