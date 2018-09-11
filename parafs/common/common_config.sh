#!/bin/bash
###############################################################################
#-*- coding: utf-8 -*-
# Copyright (C) 2015-2050 Wotung.com.
###############################################################################
###############################################################################
###### 以下指令执行指定ssh免密用户执行
###############################################################################
###### 远程 bashrc 更新
function update_bashrc() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local authorize_home=$4
    local bashrc_file=$5

    echo -e "\tdo update_bashrc at $authorize_ip"
    ### parafs_config_path_begin 需要与 conf/bashrc 中的相同，表示配置文件中的唯一
    local check_bashrc="grep parafs_config_path_begin $authorize_home/.bashrc"
    local append_bashrc="cat $bashrc_file|tee -a $authorize_home/.bashrc "
    local source_bashrc="source  $authorize_home/.bashrc"
    local remote_command="$check_bashrc || $append_bashrc && $source_bashrc"
    print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_command'\" "
    ret=`sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" `
    print_result "$ret"
    # return $?
}

function check_local_config_file() {
    test ! -f $HADOOP_SLAVES         && print_msg "$HADOOP_SLAVES         is not exist" && exit 1
    test ! -f $HADOOP_YARN_XML       && print_msg "$HADOOP_YARN_XML       is not exist" && exit 1
    test ! -f $SPARK_SLAVES          && print_msg "$SPARK_SLAVES          is not exist" && exit 1
    test ! -f $SPARK_ENV             && print_msg "$SPARK_ENV             is not exist" && exit 1
    test ! -f $SPARK_CONF            && print_msg "$SPARK_CONF            is not exist" && exit 1
    test ! -f $ZOOKEEPER_CONF        && print_msg "$ZOOKEEPER_CONF        is not exist" && exit 1
    test ! -f $ZOOKEEPER_MY_ID       && print_msg "$ZOOKEEPER_MY_ID       is not exist" && exit 1
#    test ! -f $ZOOKEEPER_DATA        && print_msg "$ZOOKEEPER_DATA        is not exist" && exit 1
#    test ! -f $ZOOKEEPER_DATA_LOG    && print_msg "$ZOOKEEPER_DATA_LOG    is not exist" && exit 1
    test ! -f $HBASE_REGEION_SERVERS && print_msg "$HBASE_REGEION_SERVERS is not exist" && exit 1
    test ! -f $HBASE_CONF            && print_msg "$HBASE_CONF            is not exist" && exit 1
    test ! -f $HIVE_CONF             && print_msg "$HIVE_CONF             is not exist" && exit 1
    test ! -f $KAFKA_CONF            && print_msg "$KAFKA_CONF            is not exist" && exit 1
    test ! -f $AZKABAN_EXEC_CONF     && print_msg "$AZKABAN_EXEC_CONF     is not exist" && exit 1
    test ! -f $AZKABAN_WEB_CONF      && print_msg "$AZKABAN_WEB_CONF      is not exist" && exit 1
    return 0
}
###### slave 应该为空文件
function config_local_hadoop_slaves() {
    local slaves_file=$1
    local cluster_ips=$2
    test -f $slaves_file && truncate -s 0 $slaves_file || touch $slaves_file
    for ip in ${cluster_ips[*]}; do
        grep $ip $slaves_file >/dev/null || echo $ip >>$slaves_file  
#        grep $ip $slaves_file >/dev/null || echo $ip |tee -a $slaves_file  
    done
    print_msg $slaves_file
}

###### 远程获取信息行号等，声称本地sed_script文件
function sed_xml_script() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local xml_key=$6
    local xml_value=$7
    local is_append=$8

    ### 1, 远程获取需要更新的行数，
    local name_label="\\name\>" ## <name> <\name> '<是特殊字符需要注意'
    local remote_line="grep -n $xml_key $filename |grep $name_label"
    local remote_line_ret=`su - $local_user -c "ssh $authorize_user@$authorize_ip '$remote_line'"` 
    if [ -z "$remote_line_ret" ]; then 
        echo "pls check $filename at $authorize_ip"
    fi

    ### 2, 在本地生成sed_script 然后复制到远端脚本所在地
    local line_num=`echo "$remote_line_ret" | awk -F ':' '{print $1}'`
#    echo line_num=$line_num
    local sed_script="$(($line_num+1)),$(($line_num+1))c $xml_value "   
    print_msg "sed_script_file `basename $sed_script_file` for `basename $filename`"
    print_msg "sed_script=$sed_script"
    if [ x${is_append} = 'xtrue' ] ; then
        echo $sed_script >> $sed_script_file
    else
        echo $sed_script > $sed_script_file 
    fi
    ### 修改sed文件 
    return $?
}

### 配置yarn_ip
function update_hadoop_yarn_ip() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local master_ip=$6

    print_bgblack_fgwhite "function call ...... update_hadoop_yarn_ip ..... at $authorize_ip " $common_conf_outpus_tabs
    ### 1 远程获取信息生成本地sed文件
    local xml_key="yarn.resourcemanager.hostname"
    local xml_value="\<value\>${master_ip}\</value\>  \<!-- yarn主节点 --\>"
    sed_xml_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$xml_key" "$xml_value"
    ### 2，同步sed_script 
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  >> $INSTALL_LOG 
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  |tee -a $INSTALL_LOG
    ### 3, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'\" "
    # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'"  >> $INSTALL_LOG 
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'"  |tee -a $INSTALL_LOG
    return $?
}

### 配置yarn_mem
function update_hadoop_yarn_mem() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5

    print_bgblack_fgwhite "function call ...... update_hadoop_yarn_mem ..... at $authorize_ip " $common_conf_outpus_tabs
    ### 1 远程获取内存
    local remote_mem_kb="grep MemTotal /proc/meminfo"
    local remote_mem_kb_result=` su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_mem_kb'" `
    local mem_kb=`echo $remote_mem_kb_result | awk '{print $2}' `
    # local mem_mb_2=$(($mem_kb/512))  # XXX/1024*2

    ### 2,远程获取 总内存 需要更新的行数， 更新本地的sed_script
    local xml_key="yarn.nodemanager.resource.memory-mb"
    local xml_value="\<value\>$(($mem_kb/512))\</value\>  \<!-- yarn使用总内存 --\>"
    sed_xml_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$xml_key" "$xml_value"
    
    ### 2,远程获取需要更新的行数， 单个scheduler 内存  更新本地的sed_script
    local xml_key="yarn.scheduler.maximum-allocation-mb"
    local xml_value="\<value\>$(($mem_kb/1024))\</value\>  \<!-- 单个进程最大占用内存 --\>"
    sed_xml_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$xml_key" "$xml_value" "true"

    ### 3,同步到authorize_ip位置
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'" >> $INSTALL_LOG 
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'" |tee -a $INSTALL_LOG

    ### 6, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'\" "
    # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'"  >> $INSTALL_LOG 
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'"  |tee -a $INSTALL_LOG
    return $?
}

### 配置yarn_cpu
function update_hadoop_yarn_cpu() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5

    print_bgblack_fgwhite "function call ...... update_hadoop_yarn_cpu ..... at $authorize_ip " $common_conf_outpus_tabs
    ### 1 远程获取cpu
    local remote_cpus="grep processor /proc/cpuinfo |wc -l"
    local remote_cpus_result=`ssh "$authorize_user@$authorize_ip" "$remote_cpus"`

    ### 2,远程获取需要更新的行数， 更新本地的sed_script
    local xml_key="yarn.nodemanager.resource.cpu-vcores"
    local xml_value="\<value\>${remote_cpus_result}\</value\>  \<!-- cpu 数量--\>"
    sed_xml_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$xml_key" "$xml_value"

    ### 3,同步到authorize_ip位置
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  >> $INSTALL_LOG 
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'" |tee -a $INSTALL_LOG

    ### 4, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    print_msg "sudo su - $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'\""
    # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" >>$INSTALL_LOG 
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" |tee -a $INSTALL_LOG
    return $?
}

###### 远程获取信息行号等，生成本地sed_script文件
function sed_shell_script() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local shell_key=$6
    local shell_value=$7
    local is_append=$8

    ### 1, 远程获取需要更新的行数，
    local remote_line="grep -n '^export ' $filename |grep ${shell_key} "
    local remote_line_ret=`su - $local_user -c "ssh $authorize_user@$authorize_ip '$remote_line'"` 
#    echo "remote_line $remote_line_ret"
    if [ -z "$remote_line_ret" ]; then 
        echo "pls check $filename at $authorize_ip"
    fi

    ### 2, 在本地生成sed_script 然后复制到远端脚本所在地
    local line_num=`echo "$remote_line_ret" | awk -F ':' '{print $1}'`
    local sed_script="$(($line_num)),$(($line_num))c export $shell_key\=$shell_value"   
    print_msg "sed_script_file `basename $sed_script_file` for `basename $filename`"
    print_msg "sed_script=$sed_script"
    if [ x${is_append} = 'xtrue' ] ; then
        echo $sed_script >> $sed_script_file
    else
        echo $sed_script > $sed_script_file 
    fi
    ### 修改sed文件 
    return $?
}
###### 远程 更改spark配置 spark-env.sh
function update_spark_env() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local master_ip=$6
    
    print_bgblack_fgwhite "function call ...... update_spark_env ..... at $authorize_ip " $common_conf_outpus_tabs
    ### SPARK_MASTER_IP
    local shell_key="SPARK_MASTER_IP"
    local shell_value=$master_ip
    sed_shell_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$shell_key" "$shell_value"
    
    ### SPARK_MASTER_HOST
    local shell_key="SPARK_MASTER_HOST"
    local shell_value=$master_ip
    sed_shell_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$shell_key" "$shell_value" "true"

    ### SPARK_MASTER_HOST
    local shell_key="SPARK_LOCAL_IP"
    local shell_value=$authorize_ip
    sed_shell_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$shell_key" "$shell_value" "true"

    ### 2,同步到authorize_ip位置
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  >> $INSTALL_LOG 
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  |tee -a $INSTALL_LOG
 
    ### 3, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" >>$INSTALL_LOG 
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" |tee -a $INSTALL_LOG
    return $?
}

function sed_conf_script() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local property_key=$6
    local property_value=$7
    local is_append=$8

    ### 1, 远程获取需要更新的行数，
    local remote_line="grep -n ${property_key} $filename "
    local remote_line_ret=`su - $local_user -c "ssh $authorize_user@$authorize_ip '$remote_line'"` 
#    echo "remote_line $remote_line_ret"
    if [ -z "$remote_line_ret" ]; then 
        echo "pls check $filename at $authorize_ip"
    fi

    ### 2, 在本地生成sed_script 然后复制到远端脚本所在地
    local line_num=`echo "$remote_line_ret" | awk -F ':' '{print $1}'`
    local sed_script="$(($line_num)),$(($line_num))c  $property_key $property_value"   
    print_msg "sed_script_file `basename $sed_script_file` for `basename $filename`"
    print_msg "sed_script=$sed_script"
    if [ x${is_append} = 'xtrue' ] ; then
        echo $sed_script >> $sed_script_file
    else
        echo $sed_script > $sed_script_file 
    fi
    #echo "sed_script_file=$sed_script_file" && cat $sed_script_file
    ### 修改sed文件 
    return $?
}
###### 远程 更改spark配置 spark-defaults.conf,暂时手工配置。。。
function update_spark_conf() {
#    local local_user=$1
#    local authorize_ip=$2
#    local authorize_user=$3
#    local filename=$4
#    local sed_script_file=$5
##    local memory=
##    local instances=
##    local cores=
#    
#    echo "do update_spark_conf at $authorize_ip"
#    local temp_file="/tmp/parafs_update_spark_conf$authorize_ip"
#    ### 0 远程获取并在本地保存sed脚本
#    ### spark.executor.memory 1G 默认就是1G
#    local property_key="spark.executor.memory"
#    local property_value="5G"
#    sed_conf_script "$local_user" "$authorize_ip" "$authorize_user" \
#        "$filename" "$sed_script_file" "$property_key" "$property_value" 
# 
#    ### spark.executor.instances  8  默认是2个
#    local property_key="spark.executor.instances"
#    local property_value="1"
#    sed_conf_script "$local_user" "$authorize_ip" "$authorize_user" \
#        "$filename" "$sed_script_file" "$property_key" "$property_value" "true"
#
#    ### spark.executor.cores 1   执行cpu核数
#    local property_key="spark.executor.cores"
#    local property_value="1"
#    sed_conf_script "$local_user" "$authorize_ip" "$authorize_user" \
#        "$filename" "$sed_script_file" "$property_key" "$property_value" "true"
#
#    ### 1, 同步sed脚本
#    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'" >>$temp_file   
#
#    ### 2, 远程执行sed脚本
#    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
#    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" >>$temp_file
#    
    return $?
}

###### 远程 更改sparkSQL配置
function update_spark_sql_config() {
    ### 远程操作 复制文件
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local spark_sql_filename=$5
    
    local remote_command="cp $filename $spark_sql_filename"
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'"

    echo $?
}

###### zoo.cfg 应该为空文件
function config_local_zookeeper_conf() {
    local zookeeper_config=$1
    local zookeeper_data_dir=$2
    local zookeeper_data_log_dir=$3
    local cluster_ips=$4
    print_bgblack_fgwhite "function call ...... config_local_zookeeper_conf ..... at $authorize_ip " $common_conf_outpus_tabs
    ###
    sed -i '/^dataDir/'d $zookeeper_config
    echo "dataDir=$zookeeper_data_dir" | tee -a $zookeeper_config >/dev/null
    sed -i '/^dataLogDir/'d $zookeeper_config 
    echo "dataLogDir=$zookeeper_data_log_dir" | tee -a $zookeeper_config >/dev/null

    ### 删除当前已有的server.xxx
    sed -i '/^server./'d $zookeeper_config
    ### 在文件尾增加新行
    for ip in $cluster_ips; do
        echo "server.${ip##*.}=${ip}:2888:3888" |tee -a $zookeeper_config >/dev/null
    done
}

###### 远程 更改zookeeper配置
function update_zookeeper_myid() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    
    print_bgblack_fgwhite "function call ...... update_zookeeper_myid ..... at $authorize_ip " $common_conf_outpus_tabs
    local remote_command="echo ${authorize_ip##*.} |tee $filename"
    print_msg "sudo su -  $local_user -c \"ssh '$authorize_user@$authorize_ip' '$remote_command'\""
    # sudo su -  $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" >>$INSTALL_LOG 
    sudo su -  $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_command'" |tee -a $INSTALL_LOG
    return $?
}

###### 远程 更改hbase配置
function update_hbase_config() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local master_ip=$6
    local cluster_ips=$7

    print_bgblack_fgwhite "function call ...... update_hbase_config ..... at $authorize_ip " $common_conf_outpus_tabs
    local name_label="\\name\>" ## <name> <\name> '<是特殊字符需要注意'
    ###master 1.1, 远程获取需要更新的行数，
    local xml_key="hbase.master"
    local xml_value="\<value\>parafs://${master_ip}:60000\</value\> "
    sed_xml_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$xml_key" "$xml_value"

    ###zookeeper.quoru 2.1, 在本地生成sed_script 然后复制到远端脚本所在地
    local xml_key="hbase.zookeeper.quorum"
    local xml_value="\<value\>`echo ${cluster_ips[@]:0}|awk -vOFS="," '{$1=$1}1'`\</value\> "
    sed_xml_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$xml_key" "$xml_value" "true"

    ### 2,同步到authorize_ip位置
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  >> $INSTALL_LOG 
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  |tee -a $INSTALL_LOG
 
    ### 3, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" >>$INSTALL_LOG 
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" |tee -a $INSTALL_LOG
    return $?
}

### 本地进行hbase的backup-masters
function local_hbase_backup(){
    local cluster_ips=$1
    local master_ip=$2
    local file=$3

    if [ -f $file ];then
        rm $file
        touch $file
    else
        touch $file
    fi  

    local backup_num=0
    # backup_limit cat't be more than 9
    local backup_limit=2
    for ip in $cluster_ips
    do  
        if [[ $ip = $master_ip ]];then
            echo "master_ip can't be chosen" >> /dev/null
        elif (( $backup_num >= $backup_limit ));then
            echo "beyond the limit" >> /dev/null
            break
        else
            echo "write ip" $ip >> /dev/null
            echo $ip >> $file
            let backup_num++
        fi  
    done
}

###### 远程 更改hive配置
function update_hive_config() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local master_ip=$6

    print_bgblack_fgwhite "function call ...... update_hive_config ..... at $authorize_ip " $common_conf_outpus_tabs
    ###master 1.1, 远程获取需要更新的行数，
    local xml_key="javax.jdo.option.ConnectionURL"
    local xml_value="\<value\>jdbc:mysql://${master_ip}:3306/hive?createDatabaseIfNotExist=true&amp;useSSL=false\</value\> "
    sed_xml_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$xml_key" "$xml_value"

    ###master 1.1, 远程获取需要更新的行数，
    local xml_key="hive.hwi.listen.host"
    local xml_value="\<value\>${master_ip}\</value\> "
    sed_xml_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$xml_key" "$xml_value" "true"

    ###master 1.1, 远程获取需要更新的行数，
    local xml_key="hive.server2.thrift.bind.host" 
    local xml_value="\<value\>${master_ip}\</value\> "
    sed_xml_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$xml_key" "$xml_value" "true"

    ###master 1.1, 远程获取需要更新的行数，
    local xml_key="hive.server2.webui.host" 
    local xml_value="\<value\>${master_ip}\</value\> "
    sed_xml_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$xml_key" "$xml_value" "true"

    ### 2,同步到authorize_ip位置
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  >> $INSTALL_LOG 
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  |tee -a $INSTALL_LOG
 
    ### 3, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" >>$INSTALL_LOG 
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" |tee -a $INSTALL_LOG
    return $?
}

###### 远程获取信息行号等，生成本地sed_script文件
function sed_property_script() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local property_key=$6
    local property_value=$7
    local is_append=$8

    ### 1, 远程获取需要更新的行数，
    local remote_line="grep -n ${property_key}= $filename"
    local remote_line_ret=`su - $local_user -c "ssh $authorize_user@$authorize_ip '$remote_line'"` 
#    echo "remote_line $remote_line_ret"
    if [ -z "$remote_line_ret" ]; then 
        echo "pls check $filename at $authorize_ip"
    fi

    ### 2, 在本地生成sed_script 然后复制到远端脚本所在地
    local line_num=`echo "$remote_line_ret" | awk -F ':' '{print $1}'`
#    echo "$line_num --- $property_key --- $property_value"
    local sed_script="$(($line_num)),$(($line_num))c ${property_key}\=${property_value}"   
#    local sed_script="$(($line_num)),$(($line_num))"
#    echo $sed_script
    if [ x${is_append} = 'xtrue' ] ; then
        echo $sed_script >>$sed_script_file
    else
        echo $sed_script >$sed_script_file
    fi
    #echo "sed_script_file=$sed_script_file" && cat $sed_script_file
    ### 修改sed文件 
    return $?
}
###### 远程 更改azkaban配置
function update_azkaban_config() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local master_ip=$6

    print_bgblack_fgwhite "function call ...... update_azkaban_config ..... at $authorize_ip " $common_conf_outpus_tabs
    ###master 1.1, 远程获取需要更新的行数，
    local temp_file="/tmp/parafs_update_azkaban_config${authorize_ip}"
    local property_key="mysql.host"
    local property_value="$master_ip"
    sed_property_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$property_key" "$property_value"

    ### 2,同步到authorize_ip位置
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  >> $INSTALL_LOG 
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  |tee -a $INSTALL_LOG
 
    ### 3, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" >>$INSTALL_LOG 
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" |tee -a $INSTALL_LOG

    return $?
}

###### 远程 更改kafka配置
function update_kafka_config() {
    local local_user=$1
    local authorize_ip=$2
    local authorize_user=$3
    local filename=$4
    local sed_script_file=$5
    local cluster_ips=$6

    print_bgblack_fgwhite "function call ...... update_kafka_config ..... at $authorize_ip " $common_conf_outpus_tabs
    ###master 1.1, 远程获取需要更新的行数，
    local property_key="zookeeper.connect" 
    local property_value=""
    for ip in $cluster_ips ; do
        property_value="${ip}:2181,$property_value"
    done
    property_value=${property_value%,*}
    # echo $property_value
    sed_property_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$property_key" "$property_value"

    ### 2,同步到authorize_ip位置
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  >> $INSTALL_LOG 
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  |tee -a $INSTALL_LOG
 
    ### 3, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" >>$INSTALL_LOG 
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" |tee -a $INSTALL_LOG

    return $?
}

function update_kafka_broker_id() {
	local local_user=$1
	local authorize_ip=$2
	local authorize_user=$3
	local filename=$4
	local sed_script_file=$5
	local broker_id=$6
	
    print_bgblack_fgwhite "function call ...... update_kafka_broker_id ..... at $authorize_ip " $common_conf_outpus_tabs
	###master 1.1, 远程获取需要更新的行数，
    local property_key="broker.id"
    local property_value=$broker_id
    sed_property_script "$local_user" "$authorize_ip" "$authorize_user" \
        "$filename" "$sed_script_file" "$property_key" "$property_value"

    ### 2,同步到authorize_ip位置
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  >> $INSTALL_LOG 
    sudo su - $local_user -c "scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'"  |tee -a $INSTALL_LOG
 
    ### 3, 远程执行sed脚本
    local remote_exec_sed_script="sed -i -f $sed_script_file $filename"
    print_msg "sudo su - $local_user -c \"scp '$sed_script_file' '$authorize_user@$authorize_ip:$sed_script_file'\""
    # sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" >>$INSTALL_LOG 
    sudo su - $local_user -c "ssh '$authorize_user@$authorize_ip' '$remote_exec_sed_script'" |tee -a $INSTALL_LOG

    return $?
}

function config_SELINUX(){
    print_msg "sed -i '7,7c SELINUX=disabled' /etc/selinux/config "
    sed -i '7,7c SELINUX=disabled' /etc/selinux/config 
    return $?
}

# ###### 远程 更改ycsb配置
# function update_ycsb_config() {
#     echo $?
# }
###===========================================================================
###++++++++++++++++++++++++      main begin       ++++++++++++++++++++++++++###
COMMON_CONFIG_BASH_NAME=common_config.sh
if [ -z ${LOG_BASH_NAME} ] ; then 
    . $SCRIPT_BASE_DIR/parafs/common/common_log.sh
fi
common_conf_outpus_tabs="4"
###++++++++++++++++++++++++      main end         ++++++++++++++++++++++++++###
###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# update_bashrc root 192.168.1.99 root /root /opt/wotung/parafs-install/conf/bashrc
# update_hadoop_yarn_ip parauser 192.168.138.71 parauser \
#     /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/yarn-site.xml \
#     /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn_ip \
#     192.168.113.299 
# update_hadoop_yarn_mem parauser 192.168.138.71 parauser \
#     /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/yarn-site.xml \
#     /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn_mem 
# update_hadoop_yarn_cpu parauser 192.168.138.71 parauser \
#     /opt/wotung/hadoop-parafs/hadoop-2.7.3/etc/hadoop/yarn-site.xml \
#     /opt/wotung/parafs-install/conf/sed_script/hadoop/hadoop_yarn_cpus 
##
# update_spark_env root 192.168.1.99 root \
#     /opt/wotung/hadoop-system/spark-2.0.1/conf/spark-env.sh \
#     /opt/wotung/parafs-install/conf/sed_script/spark/spark_env \
#     192.168.138.29
# update_spark_conf parauser 192.168.138.71 parauser \
#     /opt/wotung/hadoop-parafs/spark-2.0.1/conf/spark-defaults.conf \
#     /opt/wotung/parafs-install/conf/sed_script/spark/spark_defaults
# update_zookeeper_myid parauser 192.168.138.71 parauser \
#     /opt/wotung/hadoop-parafs/zookeeper-3.4.10/zk-data/myid 
# CLUSTER_IPS_TEST__=('11.1.1.2'  '12.1.1.4'  '123.435.56')
# config_local_hadoop_slaves /opt/wotung/pusentian "${CLUSTER_IPS_TEST__[*]}"
# config_local_zookeeper_conf \
#     /opt/wotung/hadoop-parafs/zookeeper-3.4.10/conf/zoo.cfg \
#     /opt/wotung/hadoop-parafs/zookeeper-3.4.10/zk-data \
#     /opt/wotung/hadoop-parafs/zookeeper-3.4.10/zk-log  \
#     "${CLUSTER_IPS_TEST___TEST__[*]}"
# update_hbase_config parauser 192.168.138.71 parauser \
#     /opt/wotung/hadoop-parafs/hbase-1.2.5/conf/hbase-site.xml \
#     /opt/wotung/parafs-install/conf/sed_script/hbase/hbase_conf \
#     192..168.1.1214 \
#     "${CLUSTER_IPS_TEST__[*]}"
# update_hive_config parauser 192.168.138.71 parauser \
#     /opt/wotung/hadoop-parafs/hive-2.1.1/conf/hive-site.xml \
#     /opt/wotung/parafs-install/conf/sed_script/hive/hive_conf \
#     192..168.1213.abx 
# update_azkaban_config parauser 192.168.138.71 parauser \
#     /opt/wotung/hadoop-parafs/azkaban/azkaban-exec-server-3.41.0/conf/azkaban.properties \
#     # azkaban/azkaban-web-server-3.41.0/conf/azkaban.properties
#     /opt/wotung/parafs-install/conf/sed_script/azkaban/azkaban_conf \
#     192.168.1213.abx 
# update_kafka_config parauser 192.168.138.71 parauser \
#     /opt/wotung/hadoop-parafs/kafka_2.11-1.0.1/config/server.properties \
#     /opt/wotung/parafs-install/conf/sed_script/kafka/kafka_conf\
#     "${CLUSTER_IPS_TEST__[*]}"
 
#echo $?
###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
