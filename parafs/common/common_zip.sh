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
    local authorize_ip=$2
    local authorize_user=$3
    local dirpath=$4
    local zippedfile_dir=$5

    if [ -z "$dirpath" ] ||  [ ! -d "$dirpath" ] ; then
        print_bgblack_fgread "make sure $dirpath mast be directory" $common_zip_output_tabs
        exit 1
    fi
    print_bgblack_fgwhite "function call ......zip_dir..... $dirpath at $authorize_ip" $common_zip_output_tabs
    local dirname_dir=`dirname $dirpath`
    local basename_dir=`basename $dirpath`
    local zippedfile=${zippedfile_dir}/${basename_dir}.tar.gz 

    local remote_command="tar cvzf $zippedfile -C $dirname_dir $basename_dir"
    print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_command'\""
    ret=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'"`
    print_result "$ret"
    # return $?
}
###### 远程md5命令
function file_md5sum() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local zipped_filepath=$4

    print_bgblack_fgwhite "function call ......file_md5sum..... $dirpath at $authorize_ip" $common_zip_output_tabs
    local zipped_dir=`dirname $zipped_filepath`
    local zipped_file=`basename $zipped_filepath`
    local zipped_file_md5sum=${zipped_file}.md5sum

    local remote_command="md5sum ${zipped_dir}/${zipped_file} |tee ${zipped_dir}/${zipped_file_md5sum}"
    # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >$temp_file
    # return $?
    print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_command'\" "
    ret=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" `
    print_result "$ret"
}
###### 指定用户 分发文件 到已免密登陆用户分发到机器上
### scp提供文件到文件如果存在 scp -r 不会覆盖
### local_user $1 以用户 该用户可以免密登陆remote_user@remote_ip
### authorize_ip $2 指定的ip
### authorize_user $3 指定用户
### local_file_dir $4 分发的文件所在目录
### local_file $5 分发的文件
### remote_path $6 指定位置 remote_user在remote_path 有访问权限
### 0 成功执行
function file_dist() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local local_file_dir=$4
    local local_file=$5
    local remote_path=$6
    # local remote_file=$7
    
    #if authorize_ip is $CLUSTER_LOCAL_IP, execute 'cp'
    print_bgblack_fgwhite "function call ......file_dist.....  at $authorize_ip for $local_file" $common_zip_output_tabs
    #if [[ $authorize_ip = $CLUSTER_LOCAL_IP ]]; then
    #    print_msg "sudo su - $local_user -c \"cp '${local_file_dir}/$local_file' '$remote_path'\" "
    #    sudo su - $local_user -c "cp '${local_file_dir}/$local_file' '$remote_path'" 
    #    # print_result $ret
    #else
    #    print_msg "sudo su - $local_user -c \"rsync -rv '${local_file_dir}/$local_file' '$authorize_user@$authorize_ip:$remote_path'\" >/dev/null"
    #    sudo su - $local_user -c "rsync -rv '${local_file_dir}/$local_file' '$authorize_user@$authorize_ip:$remote_path'" # >/dev/null
    #    # print_result $ret
    #fi
    print_msg "sudo su - $local_user -c \"rsync -rv '${local_file_dir}/$local_file' '$authorize_user@$authorize_ip:$remote_path'\" >/dev/null"
    sudo su - $local_user -c "rsync -rv '${local_file_dir}/$local_file' '$authorize_user@$authorize_ip:$remote_path'" # >/dev/null
    return $?
}

###### 远程通过md5sum 检查文件完整性
### su - parauser -c " ssh  parauser@192.168.138.71 'md5sum /opt/wotung/parafs-install.tar.gz' "
### local_user $1
### authorize_ip $2
### authorize_user $3
### md5 $4
### zippedfile_dir $5
### zippedfile $6
### return: 0 md5检查通过 1检查不通过
function check_zip_file() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local md5=$4
    local zippedfile_dir=$5
    local zippedfile=$6
    
    print_bgblack_fgwhite "function call ......check_zip_file.....  at $authorize_ip for $zippedfile" $common_zip_output_tabs
    local remote_zip_md5="md5sum ${zippedfile_dir}/$zippedfile |grep $md5"
    if [[ $authorize_ip = $CLUSTER_LOCAL_IP ]]; then
        print_msg "sudo su - $local_user -c \"md5sum ${zippedfile_dir}/$zippedfile |grep $md5\" "
        sudo su - $local_user -c "md5sum ${zippedfile_dir}/$zippedfile |grep $md5" 
        print_result $ret
    else
        print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_zip_md5'\""
        ret=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_zip_md5'" `
        print_result $ret
    fi
    # return $?
}

###### 将文件解压到指定目录下
### local_user $1
### authorize_ip $2
### authorize_user $3
### zippedfile_dir $4
### zip_file $5
### 0 运行正常
function unzip_file() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local zippedfile_dir=$4
    local zip_file=$5

    print_bgblack_fgwhite "function call ......unzip_file.....  at $authorize_ip for $zip_file" $common_zip_output_tabs
    local remote_command="tar xvzf $zippedfile_dir/$zip_file -C $zippedfile_dir "
    if [[ $authorize_ip = $CLUSTER_LOCAL_IP ]]; then
        print_msg "sudo su - $local_user -c \"tar xvzf $zippedfile_dir/$zip_file -C $zippedfile_dir\" "
        sudo su - $local_user -c "tar xvzf $zippedfile_dir/$zip_file -C $zippedfile_dir "
        # print_result $ret
    else
        print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_command'\""
        # ret=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" `
        # print_result "$ret"
        # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'"  >> $INSTALL_LOG 
        sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'"  |tee -a $INSTALL_LOG
    fi
    return $?
}
###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
ZIP_BASH_NAME=common_zip.sh
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi
common_zip_output_tabs="3"
##################
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
#zip_dir parauser 192.168.138.70 parauser /opt/wotung/parafs-install /opt/wotung
#file_md5sum parauser 192.168.138.70 parauser /opt/wotung/parafs-install.tar.gz
# file_dist parauser 192.168.138.71 parauser  /opt/wotung  parafs-install.tar.gz /opt/wotung
# check_zip_file  parauser 192.168.138.71 parauser "f40b7a7217aa973dedc11b929334e3aa"  /opt/wotung parafs-install.tar.gz 
# unzip_file parauser 192.168.138.71 parauser /opt/wotung parafs-install.tar.gz 
# echo $?
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
