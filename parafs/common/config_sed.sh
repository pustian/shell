#!/bin/bash
# configure files by using sed

# configure hadoop yarn-site.xml
# $1	resourcemanager_ip
# $2	local_user
# $3	remote_user
# $4	remote_ip
function config_hadoop()
{
	local resourcemanager_ip=$1
	local local_user=$2
	local remote_user=$3
	local remote_ip=$4
	local log_file="/tmp/parafs_config_hadoop$remote_ip"
#	local config_file=$HADOOP_HOME/etc/hadoop/yarn-site.xml	
	local config_file="/tmp/fake-yarn-site.xml" #test
	
	#设置resourcemanager_ip
	local target_string="<name>yarn.resourcemanager.hostname</name>"
	local target_line=`grep $target_string $config_file -n | awk -F ":" '{print $1}'`
	local next_line=$(($target_line+1))
	local string_writed="<value>$resourcemanager_ip</value>"
	#TODO put this cmd in a script, remote create the script
	local cmd="sed -i '${next_line},${next_line}c $string_writed' $config_file"
	sudo su - $local_user -c "ssh $remote_user@$remote_ip $cmd" >>$log_file

#	#设置总内存的两倍
#	local total_mem=`awk '($1 == "MemTotal:"){print $2/1024}' /proc/meminfo`
#	local total_mem=$((${total_mem%.*}/1)) #ignore numbers after '.'
#	local target_string="<name>yarn.nodemanager.resource.memory-mb</name>"
#	local target_line=`grep $target_string $config_file -n | awk -F ":" '{print $1}'`
#	local next_line=$(($target_line+1))
#	local double_mem=$(($total_mem*2)) 
#	local string_writed="<value>$double_mem</value> <!-- yarn使用总内存 -->"
#	sed -i "${next_line},${next_line} c $string_writed" $config_file
#
#	#设置单个最大内存 是总内存的
#	local target_string="<name>yarn.scheduler.maximum-allocation-mb</name>"
#	local target_line=`grep $target_string $config_file -n | awk -F ":" '{print $1}'`
#	local next_line=$(($target_line+1))
#	local string_writed="<value>$total_mem</value> <!-- 单个进程最大占用内存  -->"
#	sed -i "${next_line},${next_line} c $string_writed" $config_file
#
#	#设置cpu_count
#	local cpu_count=`cat /proc/cpuinfo |grep "processor"|sort -u|wc -l`
#	local cpu_count=${cpu_count%.*}
#	local string_writed="<value>$cpu_count</value> <!-- cpu数量 -->"
#	local target_string="<name>yarn.nodemanager.resource.cpu-vcores</name>"
#	local target_line=`grep $target_string $config_file -n | awk -F ":" '{print $1}'`
#	local next_line=$(($target_line+1))
#	sed -i "${next_line},${next_line} c $string_writed" $config_file
}

# internal function, do not call from outside
# $1:target_line	(string)
# $2:string_writed	(string)
# $3:config_file	(string)
# return:1 if success, 0 if fail
#function __write_to_nextline(){ # TODO remote call, may need one more parameter
#	local target_line=$1
#	local string_writed=$2
#	local config_file=$3
#
#	local next_line=$(($target_line+1))
#	sed -i "${next_line},${next_line}c $string_writed" $config_file
#}

##### main #####
config_hadoop my_own_ip root root 192.168.1.16 
