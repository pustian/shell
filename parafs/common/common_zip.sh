#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###### parafs_prepare.sh 
###############################################################################
###############################################################################
###### 以下指令执行指定ssh免密用户执行
###############################################################################
###### 远程打包
###### tar 压缩打包文件并生成md5文件 tar czf xxx.tar.gz -C /xxxx/xxx_dir xxx
### dirpath $1 打包该绝对路径目录或文件
### zippedfile_dir $2 打包后生成文件地址
function zip_dir() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3
    local dirpath=$4
    local zippedfile_dir=$5

    if [ -z "$dirpath" ] ||  [ ! -d "$dirpath" ] ; then
        echo "make sure $1 which mast be directory"
        print_bgblack_fgread "make sure $dirpath mast be directory" $common_zip_output_tabs
        exit 1
    fi
    print_bgblack_fgwhite "function call ......zip_dir..... $dirpath at $authoriz_ip" $common_zip_output_tabs
    local dirname_dir=`dirname $dirpath`
    local basename_dir=`basename $dirpath`
    local zippedfile=${zippedfile_dir}/${basename_dir}.tar.gz 

    local temp_file="/tmp/parafs_zip${basename_dir}$authoriz_ip"
    local remote_command="tar czf $zippedfile -C $dirname_dir $basename_dir"
    sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$remote_command'" >$temp_file
    return $?
}
###### 远程md5命令
function file_md5sum() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3
    local zipped_filepath=$4

    print_bgblack_fgwhite "function call ......file_md5sum..... $dirpath at $authoriz_ip" $common_zip_output_tabs
    local zipped_dir=`dirname $zipped_filepath`
    local zipped_file=`basename $zipped_filepath`
    local zipped_file_md5sum=${zipped_file}.md5sum

    local temp_file="/tmp/parafs_md5sum${zipped_file}$authoriz_ip"
    local remote_command="md5sum ${zipped_dir}/${zipped_file} |tee ${zipped_dir}/${zipped_file_md5sum}"
    sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$remote_command'" >$temp_file
    return $?
}
###### 指定用户 分发文件 到已免密登陆用户分发到机器上
### scp提供文件到文件如果存在 scp -r 不会覆盖
### local_user $1 以用户 该用户可以免密登陆remote_user@remote_ip
### authoriz_ip $2 指定的ip
### authorize_user $3 指定用户
### local_file_dir $4 分发的文件所在目录
### local_file $5 分发的文件
### remote_path $6 指定位置 remote_user在remote_path 有访问权限
### 0 成功执行
function file_dist() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3
    local local_file_dir=$4
    local local_file=$5
    local remote_path=$6
    # local remote_file=$7
    
    local temp_file="/tmp/parafs_file_dist${local_file}$authoriz_ip"
    #if authoriz_ip is $CLUSTER_LOCAL_IP, execute 'cp'
    print_bgblack_fgwhite "function call ......file_dist.....  at $authoriz_ip" $common_zip_output_tabs
    if [[ $authoriz_ip = $CLUSTER_LOCAL_IP ]]; then
        sudo su - $local_user -c "cp '${local_file_dir}/$local_file' '$remote_path'" >$temp_file
    else
        sudo su - $local_user -c "scp '${local_file_dir}/$local_file' '$authorize_user@$authoriz_ip:$remote_path'" | tee -a $temp_file
    fi
    return $?
}

###### 远程通过md5sum 检查文件完整性
### su - parauser -c " ssh  parauser@192.168.138.71 'md5sum /opt/wotung/parafs-install.tar.gz' "
### local_user $1
### authoriz_ip $2
### authorize_user $3
### md5 $4
### zippedfile_dir $5
### zippedfile $6
### return: 0 md5检查通过 1检查不通过
function is_zip_file_ok() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3
    local md5=$4
    local zippedfile_dir=$5
    local zippedfile=$6
    
    local temp_file="/tmp/parafs_zip_file_ok_$zippedfile$authoriz_ip"
    local remote_zip_md5="md5sum ${zippedfile_dir}/$zippedfile"

    print_bgblack_fgwhite "function call ......is_zip_file_ok.....  at $authoriz_ip" $common_zip_output_tabs
    sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$remote_zip_md5'" >$temp_file
    grep $md5 $temp_file >/dev/null
    return $?
}

###### 将文件解压到指定目录下
### local_user $1
### authoriz_ip $2
### authorize_user $3
### zippedfile_dir $4
### zip_file $5
### 0 运行正常
function unzip_file() {
    local local_user=$1
    local authoriz_ip=$2
    local authorize_user=$3
    local zippedfile_dir=$4
    local zip_file=$5

    local temp_file="/tmp/parafs_${zip_file}_unzip$ip"
    # local remote_command="tar xzf $zippedfile_dir/$zip_file -C $zippedfile_dir"
    local remote_command="tar xzf $zippedfile_dir/$zip_file -C $zippedfile_dir "
    print_bgblack_fgwhite "function call ......unzip_file.....  at $authoriz_ip" $common_zip_output_tabs
    # echo "sudo su - $local_user -c \"ssh '$authorize_user@$authoriz_ip' '$remote_command'\" >$temp_file"
    sudo su - $local_user -c "ssh '$authorize_user@$authoriz_ip' '$remote_command'" | tee -a $temp_file
    return $?
}
###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
ZIP_BASH_NAME=common_zip.sh
common_zip_output_tabs="3"
##################
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
#zip_dir parauser 192.168.138.70 parauser /opt/wotung/parafs-install /opt/wotung
#file_md5sum parauser 192.168.138.70 parauser /opt/wotung/parafs-install.tar.gz
# file_dist parauser 192.168.138.71 parauser  /opt/wotung  parafs-install.tar.gz /opt/wotung
#  is_zip_file_ok  parauser 192.168.138.71 parauser "f40b7a7217aa973dedc11b929334e3aa"  /opt/wotung parafs-install.tar.gz 
# unzip_file parauser 192.168.138.71 parauser /opt/wotung parafs-install.tar.gz 
# echo $?
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
