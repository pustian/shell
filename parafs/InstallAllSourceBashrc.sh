#!/bin/bash


#IpInstallOnly大于5认为是有数据
kb=`ls -l $IpInstallOnly | awk '$5>10 { print $5}'`

for ip in ${IP_ARRAY}; do
		tt=`cat $IpInstallOnly | grep ${ip// /}`
		if [ x"${tt}" = x ] && [ x$kb != 'x' ] ; then
			echo ${ip} "不是目标IP，跳过"
			continue;
		fi
    
		echo "对"${ip}  "开始基础安装！"
			ssh ${ip} "${BASE_DIR}/parafs/InstallSourceBashrc.sh ${BASE_DIR}"
		echo "对"${ip}  "基础安装完成！"		
done