#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
### 输出
function print_tabs() {
    tabsize=$1
    test x$tabsize = x"" && tabsize=0
    count=0
    while (( $count < $tabsize )); do
        echo -n "  "
        let "count++"
    done
}
function print_msg() {
    echo "$1" |tee -a $INSTALL_LOG
 #   echo "$1" >> $INSTALL_LOG
}
function print_result() {
    echo "$1" |tee -a $INSTALL_LOG
 #   echo "ret=$1" >> $INSTALL_LOG
    echo "------------------------------------------------------------------------------" >>$INSTALL_LOG
}

function print_bgblack_fgwhite() {
    msg=$1
    tabsize=$2
    print_tabs $tabsize
    echo -e "\033[40;37m$msg \033[0m" |tee -a $INSTALL_LOG
}
function print_bgblack_fgred() {
    msg=$1
    tabsize=$2
    print_tabs $tabsize
    echo -e "\033[40;31m$msg \033[0m" |tee -a $INSTALL_LOG
}
function print_bgblack_fggreen() {
    msg=$1
    tabsize=$2
    print_tabs $tabsize
    echo -e "\033[40;32m$msg \033[0m" |tee -a $INSTALL_LOG
}
function print_bgblack_fgblue() {
    msg=$1
    tabsize=$2
    print_tabs $tabsize
    echo -e "\033[40;34m$msg \033[0m" |tee -a $INSTALL_LOG
}

###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
LOG_BASH_NAME=common_log.sh

