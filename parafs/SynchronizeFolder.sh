#!/bin/bash
		
#main 方法
echo "将本机文件ssh文件分发到各台机器上"
source $BASE_DIR/parafs/common/RemoteFolderCopy.sh
copyFolder $BASE_DIR
copyFiles $InstallParafsFiles
echo "thisis$CopyFiles"
copyFiles $CopyFiles
echo "将本机文件ssh文件分发到各台机器上 完成"

