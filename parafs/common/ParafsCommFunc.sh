#!/bin/bash
# 工具类

#  vi /etc/hosts	
#   修改hostname
EditHostName()
{
	echo "修改 hostname"
	local iplongshortarray=$1
  for IPLongShort in ${iplongshortarray}; do
  	local ipdes=` echo ${IPLongShort} |sed -e 's/,/ /g' `
  	local ip_exist=`grep "${ipdes}" /etc/hosts`
    if [  x"${ip_exist}" = 'x' ]; then
        echo ${ipdes} >> /etc/hosts
    fi
	done
}


# 	将主机名改成长名：
EditHostsRemote()
{
	  echo "将主机名改成长名"
	  local host=$1
	  local itself=`grep ${host} /etc/hostname`
	  if [ x"${itself}" = "x" ]; then
			echo "${host} " > /etc/hostname
		fi	 
}

# 命令行前面完整显示主机名
EditShowLongHostName()
{
		echo "命令行前面完整显示主机名"
		sed -i 's/\\h \\W/\\H \\W/g' /etc/bashrc
}

# 关闭CentOS防火墙firewalld  
CloseFirewallRemote()
{
		echo "关闭CentOS防火墙firewalld"
		systemctl disable firewalld
		systemctl stop firewalld
		sed -i '7,7c SELINUX=disabled' /etc/selinux/config
}

# 安装依赖软件
InstallSoftToolRemote()
{
	  echo "安装依赖软件"
	  yum -q -y install ntp ntpdate net-tools redhat-lsb gcc libffi-devel python python-devel openssl-devel numactl epel-release
	  yum -q -y install python-pip
	  pip install paramiko
}

# 对时
SyschrTimeRemote()
{
	  echo "对时"
		#对时放入开机计划任务中
		ntpdate_exist=`grep ntpdate /etc/rc.d/rc.local`
    if [  x"${ntpdate_exist}" = 'x' ]; then
        sed -i '$a\ntpdate 202.112.10.36' /etc/rc.d/rc.local 
    fi
		chmod +x /etc/rc.d/rc.local
		
		#一小时对时一次
		ntpdate_exist2=`grep 'ntpdate -u time.windows.com' /etc/crontab`
    if [  x"${ntpdate_exist2}" = 'x' ]; then
        sed -i '$a\  0 */1 *  *  * root  /usr/sbin/ntpdate -u time.windows.com ' /etc/crontab
    fi
}


# 导入环境变量
SouceBashrc()
{
	 echo "导入环境变量"
	 path=$1
   javahome_exist=`grep JAVA_HOME ~/.bashrc`
   if [  x"${javahome_exist}" = 'x' ]; then
     cat ${path}/sourcecontect >> ~/.bashrc
   fi
   source ~/.bash_profile
}

# 添加权限
ChmodPrivilege()
{
		echo "$HADOOP_PARAFS_HOM加权限"
		chmod -R 711 $HADOOP_PARAFS_HOME
}


# 安装Hadoop
InstallHadoop()
{
	  echo "安装Hadoop"
		rm	$HADOOP_HOME/etc/hadoop/slaves
		local My_ARRAY=$1
		local ipfirst=$2
		for ip in ${My_ARRAY}; do
			echo "${ip}" >> $HADOOP_HOME/etc/hadoop/slaves	
		done
		
		local hang=`grep '<name>yarn.resourcemanager.hostname</name>' $HADOOP_HOME/etc/hadoop/yarn-site.xml -n |awk -F ":" '{print $1}'`
		local hang1=$((${hang}+1))
		sed -i "${hang1},${hang1}c  <value>${ipfirst}</value>  <!-- yarn主节点 -->" $HADOOP_HOME/etc/hadoop/yarn-site.xml
		
		#设置总内存的2倍
		local menP=`awk '($1 == "MemTotal:"){print $2/1024}' /proc/meminfo`
		local hang2=`grep '<name>yarn.nodemanager.resource.memory-mb</name>' $HADOOP_HOME/etc/hadoop/yarn-site.xml -n |awk -F ":" '{print $1}'`
		local hang3=$((${hang2}+1))
		local menP2=$((${menP%.*}*2))
		sed -i "${hang3},${hang3}c  <value>${menP2%.*}</value>  <!-- yarn使用总内存 -->" $HADOOP_HOME/etc/hadoop/yarn-site.xml
		
		#设置单个最大内存 是总内存的
		local hang4=`grep '<name>yarn.scheduler.maximum-allocation-mb</name>' $HADOOP_HOME/etc/hadoop/yarn-site.xml -n |awk -F ":" '{print $1}'`
		local hang5=$((${hang4}+1))
		local menP1d4=$((${menP%.*}/1))
		sed -i "${hang5},${hang5}c  <value>${menP1d4%.*}</value>  <!-- 单个进程最大占用内存 -->" $HADOOP_HOME/etc/hadoop/yarn-site.xml
		
		local CPUcount=`cat /proc/cpuinfo |grep "processor"|sort -u|wc -l`
		local hang6=`grep '<name>yarn.nodemanager.resource.cpu-vcores</name>' $HADOOP_HOME/etc/hadoop/yarn-site.xml -n |awk -F ":" '{print $1}'`
		local hang7=$((${hang6}+1))
		sed -i "${hang7},${hang7}c  <value>${CPUcount%.*}</value>  <!-- cpu数量 -->" $HADOOP_HOME/etc/hadoop/yarn-site.xml
		
		
}

# 安装Spark
InstallSpark()
{
		echo "安装Spark"
		local My_ARRAY=$1
		sed -i '19,$d' $SPARK_HOME/conf/slaves 
		for ip in ${My_ARRAY}; do
	        echo "${ip}" >> $SPARK_HOME/conf/slaves	
		done
}


InstallSparkRemote()
{ 
	 echo "安装Spark env defaults "
	 local firstip=$1
	 local localip=$2
	 local hang=`grep 'export SPARK_MASTER_IP' $SPARK_HOME/conf/spark-env.sh -n |awk -F ":" '{print $1}'`
	 sed -i "${hang},${hang}c export SPARK_MASTER_IP=${firstip}" $SPARK_HOME/conf/spark-env.sh
	 local hang1=`grep 'export SPARK_MASTER_HOST' $SPARK_HOME/conf/spark-env.sh -n |awk -F ":" '{print $1}'`
	 sed -i "${hang1},${hang1}c export SPARK_MASTER_HOST=${firstip}" $SPARK_HOME/conf/spark-env.sh
	 local hang2=`grep 'export SPARK_LOCAL_IP' $SPARK_HOME/conf/spark-env.sh -n |awk -F ":" '{print $1}'`
	 sed -i "${hang2},${hang2}c export SPARK_LOCAL_IP=${localip}" $SPARK_HOME/conf/spark-env.sh
	 
	 
	  # 安装前可以估算后修改   spark.executor.memory            1G 默认就是1G
	 local hang3=`grep 'spark.executor.memory' $SPARK_HOME/conf/spark-defaults.conf  -n | grep -v '#' |awk -F ":" '{print $1}'`
	 sed -i "${hang3},${hang3}c spark.executor.memory            1G" $SPARK_HOME/conf/spark-defaults.conf 
	  #  spark.executor.instances         8      默认是2个
	 hang3=`grep 'spark.executor.instances' $SPARK_HOME/conf/spark-defaults.conf  -n | grep -v '#' |awk -F ":" '{print $1}'`
	 sed -i "${hang3},${hang3}c spark.executor.instances           8" $SPARK_HOME/conf/spark-defaults.conf 
	 # spark.executor.cores             1   执行cpu核数
	 hang3=`grep 'spark.executor.cores' $SPARK_HOME/conf/spark-defaults.conf  -n | grep -v '#' |awk -F ":" '{print $1}'`
	 sed -i "${hang3},${hang3}c spark.executor.cores             1" $SPARK_HOME/conf/spark-defaults.conf 
}


# "安装ZooKeeper"
InstallZooKeeper()
{
	 	echo "安装ZooKeeper"
		local IP_ARRAY=$1
		local hang=`grep 'dataLogDir' $ZOOKEEPER_HOME/conf/zoo.cfg -n |awk -F ":" '{print $1}'`
		local hang1=$((${hang}+1))
		sed -i "${hang1}"',$d' $ZOOKEEPER_HOME/conf/zoo.cfg
		for ip in ${IP_ARRAY}; do
				local str="server.${ip##*.}=${ip}:2888:3888" 
	      echo "${str}" >> $ZOOKEEPER_HOME/conf/zoo.cfg
		done
}

# "安装ZooKeeperRemote"
InstallZooKeeperRemote()
{
		echo "安装ZooKeeperRemote"
		local ip=$1
		sed -i '1,$d' $ZOOKEEPER_HOME/zk-data/myid
    echo "${ip##*.}" >> $ZOOKEEPER_HOME/zk-data/myid
}


# "安装Hbase"
InstallHbase()
{
	  echo "安装Hbase"
	  local IP_ARRAY=$1
	  local firstip=$2
		sed -i '1,$d' $HBASE_HOME/conf/regionservers	
		for ip in ${IP_ARRAY}; do
	      echo "${ip}" >> $HBASE_HOME/conf/regionservers
		done
		
		local hang=`grep '<name>hbase.master</name>' $HBASE_HOME/conf/hbase-site.xml -n |awk -F ":" '{print $1}'`
		local hang1=$((${hang}+1))
		sed -i "${hang1},${hang1}c  <value>parafs://${firstip}:60000</value>" $HBASE_HOME/conf/hbase-site.xml
		
		hang=`grep '<name>hbase.zookeeper.quorum</name>' $HBASE_HOME/conf/hbase-site.xml -n |awk -F ":" '{print $1}'`
		hang1=$((${hang}+1))
		local arrstr=`echo ${IP_ARRAY[@]:0}|awk -vOFS="," '{$1=$1}1'`
		sed -i "${hang1},${hang1}c  <value>${arrstr}</value>" $HBASE_HOME/conf/hbase-site.xml
}

# "安装Hive"
InstallHive()
{
		echo "安装Hive"
		local firstip=$1
		local hang=`grep 'javax.jdo.option.ConnectionURL' $HIVE_HOME/conf/hive-site.xml -n |awk -F ":" '{print $1}'`
		local hang1=$((${hang}+1))
		sed -i "${hang1},${hang1}c  <value>jdbc:mysql://${firstip}:3306/hive?createDatabaseIfNotExist=true&amp;useSSL=false</value>" $HIVE_HOME/conf/hive-site.xml
		
		hang=`grep 'hive.hwi.listen.host' $HIVE_HOME/conf/hive-site.xml -n |awk -F ":" '{print $1}'`
		hang1=$((${hang}+1))
		sed -i "${hang1},${hang1}c    <value>${firstip}</value>" $HIVE_HOME/conf/hive-site.xml
		
		
		hang=`grep 'hive.server2.thrift.bind.host' $HIVE_HOME/conf/hive-site.xml -n |awk -F ":" '{print $1}'`
		hang1=$((${hang}+1))
		sed -i "${hang1},${hang1}c    <value>${firstip}</value>" $HIVE_HOME/conf/hive-site.xml
		
		
		hang=`grep 'hive.server2.webui.host' $HIVE_HOME/conf/hive-site.xml -n |awk -F ":" '{print $1}'`
		hang1=$((${hang}+1))
		sed -i "${hang1},${hang1}c    <value>${firstip}</value>" $HIVE_HOME/conf/hive-site.xml
		
}


# "安装Sparksql"
InstallSparksql()
{
	 echo "安装Sparksql"
	 cp $HIVE_HOME/conf/hive-site.xml 	$SPARK_HOME/conf/
	 cp $HADOOP_HOME/etc/hadoop/core-site.xml $SPARK_HOME/conf/
}


# "安装Azkaban"
InstallAzkaban()
{
		
		echo "安装Azkaban"
		local firstip=$1
		local hang=`grep 'mysql.host' $HADOOP_PARAFS_HOME/azkaban/azkaban-exec-server-3.41.0/conf/azkaban.properties -n |awk -F ":" '{print $1}'`
		sed -i "${hang},${hang}c  mysql.host=${firstip}" $HADOOP_PARAFS_HOME/azkaban/azkaban-exec-server-3.41.0/conf/azkaban.properties
		
	  hang=`grep 'mysql.host' $HADOOP_PARAFS_HOME/azkaban/azkaban-web-server-3.41.0/conf/azkaban.properties -n |awk -F ":" '{print $1}'`
		sed -i "${hang},${hang}c  mysql.host=${firstip}" $HADOOP_PARAFS_HOME/azkaban/azkaban-web-server-3.41.0/conf/azkaban.properties
		
}


# "安装kafka"
Installkafka()
{
	echo "安装kafka"
	local IP_ARRAY=$1
	local localip=$2
	
	local hang=`grep 'zookeeper.connect=' $KAFKA_HOME/config/server.properties -n |awk -F ":" '{print $1}'`
	local arrstr=`echo ${IP_ARRAY[@]:0}|awk -vOFS=":2181," '{$1=$1}1'`
  local arrstr1="${arrstr}:2181" 
	sed -i "${hang},${hang}c  zookeeper.connect=${arrstr1}" $KAFKA_HOME/config/server.properties
	local hh=0
	for ip in ${IP_ARRAY}; do
	  if [  "${ip}" = "${localip}" ]; then
	  	local hang1=`grep 'broker.id=' $KAFKA_HOME/config/server.properties -n |awk -F ":" '{print $1}'`
      sed -i "${hang1},${hang1}c    broker.id=${hh}" $KAFKA_HOME/config/server.properties
    fi
    hh=$(($hh+1))
	done

}