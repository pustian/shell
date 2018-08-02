#!/bin/bash
# 将本机文件copy到各台机器上
# 必须先可以免密登录其他机器

#内部函数 copy 一个文件
copyFileByIP()
{
		local ip=$1
		local SYNC_FILE_Path=$2
    scp ${SYNC_FILE_Path} ${ip}:${SYNC_FILE_Path}
}

#内部函数 copy 一个文件夹
copyFolderByIP()
{
	  local ip=$1
	  local filePath=$2
		ssh ${ip} "mkdir -p $filePath" 
		scp -r ${filePath} ${ip}:${filePath}/
}

# 批量copy文件，copy文件路径存在一个文件中，传文件名
copyFiles()
{
    local SYNC_FILES_Path=$1
    if  [ x"${SYNC_FILES_Path}" != x ] && [ -f ${SYNC_FILES_Path} ]; then
        for ip in ${IP_ARRAY}; do
              IsLocalIP ${ip}
              if [ $? -eq 0 ]; then
              		echo ${ip}  "跳过！"
                  continue;
              else
              		echo ${ip}  "开始拷贝文件！"
		              cat $SYNC_FILES_Path | while read line
									do
											echo ${ip}  "拷贝文件${line}！"
											copyFileByIP ${ip} ${line}
									done
									echo ${ip}  "拷贝文件完成！"
              fi
        done
    else
         echo "${SYNC_FILE}文件出错！"
    fi
}


# 批量copy一个文件夹 
copyFolder()
{
      #local SYNC_Path="$(pwd)/$1"
      local SYNC_Path=$1
      if [ x"${SYNC_Path}" != x ] && [ -d $SYNC_Path ] ; then
          for ip in ${IP_ARRAY}; do
              IsLocalIP ${ip}
              if [ $? -eq 0 ]; then
                  echo ${ip}  "跳过！"
                  continue;
              else
                  echo ${ip}  "${SYNC_Path}开始拷贝文件夹！"
                  copyFolderByIP ${ip} $SYNC_Path
                  echo ${ip}  "${SYNC_Path}拷贝文件夹完成！"
              fi
          done
      else
       	echo ${SYNC_Path}  "文件夹不存在！"
      fi
}



