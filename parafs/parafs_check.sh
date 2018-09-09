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
    . ../variable.sh
fi
if [ -z ${UTILS_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_utils.sh
fi
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi

###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
#check_usage
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
