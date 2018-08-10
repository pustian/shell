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

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
TOOLS_BASH_NAME=parafs_tools.sh
if [ -z ${VARIABLE_BASH_NAME} ] ; then 
    . ../variable.sh
fi
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
