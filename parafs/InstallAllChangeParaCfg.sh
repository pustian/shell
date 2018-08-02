#!/bin/bash

# 不能从本函数启动
# 修改所有机器生态软件的xml
for ip in ${IP_ARRAY}; do
		echo "对"${ip}  "开始安装！"
			ssh ${ip} "${BASE_DIR}/parafs/InstallChangeParaCfg.sh ${BASE_DIR}"
		echo "对"${ip}  "安装完成！"
done