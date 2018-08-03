#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###### parafs_prepare.sh 
###############################################################################
###### tar 压缩打包文件并生成md5文件 tar czf xxx.tgz -P /xxxx/file
### dirpath $1 绝对路径
function zip_dir() {
    local dirpath=$1

    if [ -z "$dirpath" ] ||  [ ! -d "$dirpath" ] ; then
        echo "make sure $1 which mast be directory"
        exit 1
    fi
    echo "zip_dir $dirpath"
    current_pwd=`pwd`
    # dirname=`dirname $dirpath`
    basename_dir=`basename $dirpath`
    zipfile=${basename_dir}.tgz 
    md5file=${basename_dir}.md5sum
    tar czpf $zipfile -P $basename_dir
    md5sum $zipfile > $md5file
#    cd $dirname
#    sudo zip -q -r $zipfile $basename
#    sudo sh -c " md5sum $zipfile > $md5file "
#    sudo mv $dirname/$zipfile $current_pwd 
#    sudo mv $dirname/$md5file $current_pwd 
#    cd $current_pwd
}
###############################################################################
###### 以下指令执行指定ssh免密用户执行
###############################################################################
###### 指定用户 分发文件 到已免密登陆用户分发到机器上
### local_file $1 分发的文件
### local_user $2 以用户 该用户可以免密登陆remote_user@remote_ip
### remote_ip  $3 指定的ip
### remote_user $4 指定用户
### remote_path $5 指定位置 remote_user在remote_path 有访问权限
function file_dist() {
    local local_file=$1
    local local_user=$2
    local remote_ip=$3
    local remote_user=$4
    local remote_path=$5
    local temp_file="/tmp/parafs_file_dist$ip"
    echo "do dist $local_file to $remote_ip"
    sudo su - $user -c "scp '$local_file' '$authorize_user@$authoriz_ip:$remote_path'" >$temp_file
    return $?
}

###### 远程通过md5sum 检查文件完整性
### local_md5_file $1
### zip_file $2
### ip $3
### user $4
### passwd $5
### return: 0 md5检查通过 1检查不通过
function is_zip_file_ok() {
    local local_md5_file=$1
    local zip_file=$2
    local ip=$3
    local user=$4
    local passwd=$5

    local temp_file="/tmp/parafs_${zip_file}_check$ip"
    local remote_zip_md5="sudo md5sum $zip_file"
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd" "$remote_zip_md5" > $temp_file
    diff $local_md5_file $temp_file
    return $?
}

###### 将文件解压到指定目录下
### zip_file
### path  解压指定目录
### ip
### user
### passwd
### 0 md5检查通过 1检查不通过
function unzip_file() {
    local zip_file=$1
    local path=$2
    local ip=$3
    local user=$4
    local passwd=$5

    local temp_file="/tmp/parafs_${zip_file}_unzip$ip"
#    unzip_file_command="sudo unzip $zip_file"
    unzip_file_command="sudo tar xzf $zip_file -C $path"
    $SSH_REMOTE_EXEC "$ip" "$user" "$passwd"  "$unzip_file_command" >$temp_file
    return $?
}
###===========================================================================
