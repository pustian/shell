#!/bin/bash

My_DIR=$1
source $My_DIR/variable.sh
source $My_DIR/parafs/InstallCommFunc.sh

# ��ʹ����������Ч
source ~/.bash_profile

# �޸Ļ�������
InstallHadoop "${IP_ARRAY[@]}" $Master_IP 

InstallHive $Master_IP

InstallSpark "${IP_ARRAY[@]}"
InstallSparkRemote $Master_IP $Local_IP 
InstallSparksql

InstallZooKeeper "${IP_ARRAY[@]}"
InstallZooKeeperRemote $Local_IP

InstallHbase "${IP_ARRAY[@]}" $Master_IP

InstallAzkaban $Master_IP

Installkafka  "${IP_ARRAY[@]}" $Local_IP 

