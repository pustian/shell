#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###### parafs_prepare.sh 
###############################################################################
###### tar 压缩打包文件并生成md5文件 tar czf xxx.tar.gz -C /xxxx/xxx_dir xxx
### dirpath $1 打包该绝对路径目录或文件
### zip_file_dir $2 打包后声称文件地址
function zip_dir() {
    local dirpath=$1
    local zip_file_dir=$2

    if [ -z "$dirpath" ] ||  [ ! -d "$dirpath" ] ; then
        echo "make sure $1 which mast be directory"
        exit 1
    fi
    echo "zip_dir $dirpath"
    dirname_dir=`dirname $dirpath`
    basename_dir=`basename $dirpath`
    zipfile=${zip_file_dir}/${basename_dir}.tar.gz 
    md5file=${zip_file_dir}/${basename_dir}.md5sum
#    tar czf $zipfile -P $dirpath
    tar czf $zipfile -C $dirname_dir $basename_dir
    md5sum $zipfile > $md5file
}
###############################################################################
###### 以下指令执行指定ssh免密用户执行
###############################################################################
###### 指定用户 分发文件 到已免密登陆用户分发到机器上
### local_file_dir $1 分发的文件所在目录
### local_file $2 分发的文件
### local_user $3 以用户 该用户可以免密登陆remote_user@remote_ip
### authoriz_ip $4 指定的ip
### authorize_user $5 指定用户
### remote_path $6 指定位置 remote_user在remote_path 有访问权限
### 0 成功执行
function file_dist() {
    local local_file_dir=$1
    local local_file=$2
    local local_user=$3
    local authoriz_ip=$4
    local authorize_user=$5
    local remote_path=$6
    local temp_file="/tmp/parafs_file_dist${local_file}$authoriz_ip"
    echo "do dist $local_file to $authoriz_ip"
    sudo su - $local_user -c "scp '${local_file_dir}/$local_file' '$authorize_user@$authoriz_ip:$remote_path'" >$temp_file
    return $?
}

###### 远程通过md5sum 检查文件完整性
### su - parauser -c " ssh  parauser@192.168.138.71 'md5sum /opt/wotung/parafs-install.tar.gz' "
### md5 $1
### zip_file_dir $2
### zip_file $3
### local_user $4
### authoriz_ip $5
### authorize_user $6
### return: 0 md5检查通过 1检查不通过
function is_zip_file_ok() {
    local md5=$1
    local zip_file_dir=$2
    local zip_file=$3
    local local_user=$4
    local authoriz_ip=$5
    local authorize_user=$6
    
    local temp_file="/tmp/parafs_zip_file_ok_$zip_file$authoriz_ip"
    local remote_zip_md5="sudo md5sum ${zip_file_dir}/$zip_file"

    echo "do is_zip_file_ok at $authoriz_ip"
    sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$remote_zip_md5'" >$temp_file
    grep $md5 $temp_file >/dev/null

    return $?
}

###### 将文件解压到指定目录下
### zip_file_dir 解压指定目录
### zip_file
### local_user
### authoriz_ip
### authorize_user
### 0 运行正常
function unzip_file() {
    local zip_file_dir=$1
    local zip_file=$2
    local local_user=$3
    local authoriz_ip=$4
    local authorize_user=$5

    local temp_file="/tmp/parafs_${zip_file}_unzip$ip"
    unzip_file_command="sudo tar xzf $zip_file_dir/$zip_file -C $zip_file_dir"
    echo "do unzip_file at $authoriz_ip"
    echo "sudo su - $local_user -c \"ssh '$authorize_user@$authoriz_ip' '$unzip_file_command'\" >$temp_file"
    #sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$unzip_file_command'" >$temp_file
    return $?
}
###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
ZIP_BASH_NAME=common_zip.sh
if [ -z "$VARIABLE_BASH_NAME" ] ; then 
    . /opt/wotung/parafs-install/variable.sh
fi
##################
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# zip_dir /opt/wotung/parafs-install /opt/wotung
# file_dist /opt/wotung parafs-install.tar.gz parauser 192.168.138.72 parauser /opt/wotung
# is_zip_file_ok "f1150af446cf6d7b714ee81014b3f60e"  /opt/wotung parafs-install.tar.gz parauser 192.168.138.72 parauser 
## echo $?
# unzip_file /opt/wotung parafs-install.tar.gz parauser 192.168.138.72 parauser
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
