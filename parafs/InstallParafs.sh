#!/bin/bash

#本机安装rpm包
My_DIR=$1
source $My_DIR/variable.sh

cat $InstallParafsFiles | while read line
do
	  #安装rmp软件
		rpm -ivh  ${line} --force
done

