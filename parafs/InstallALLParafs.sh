#!/bin/bash

# 不能从本函数启动
#升级安装所有的机器
for ip in ${IP_ARRAY}; do
		echo "对"${ip}  "开始安装！"
		ssh ${ip} "${BASE_DIR}/parafs/InstallParafs.sh ${BASE_DIR} "
		echo "对"${ip}  "安装完成！"	
done