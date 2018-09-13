#!/bin/bash
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# ### ssh_login.exp
#  ./ssh_login.exp "192.168.138.71" "root" "Tianpusen@2" "/root" 
#  ./ssh_login.exp "192.168.138.72" "root" "Tianpusen@1" "/root" 
#  ./ssh_login.exp "192.168.1.99" "parafs" "tianpusen" "/home/parafs"


# ### ssh_remote_exec.exp
#  ./ssh_remote_exec.exp "192.168.138.71" "root" "Tianpusen@1" "ls -la /root" 
#  ./ssh_remote_exec.exp "192.168.138.72" "root" "Tianpusen@1" "ls -la /aaa"
# ./ssh_remote_exec.exp "192.168.1.99" "root" "Tianpusen@1" "grep defaults /root/fstab | grep -v ext4  |grep -v ^# |grep -v swap" 
# result=`./ssh_remote_exec.exp "192.168.1.99" "root" "Tianpusen@1" "df -T >/tmp/res " `
# echo $result
# ./ssh_remote_exec.exp "192.168.1.99" "root" "Tianpusen@1" "df -T  " >/tmp/res2

# ### current_authorize.exp
# ./current_authorize.exp "192.168.138.71" 'parauser' "hetong@2015" "/home/parauser"  \
#     "192.168.138.71" "parauser" "hetong@2015" "/home/parauser"
# ./current_authorize.exp "192.168.138.71" 'parauser' "hetong@2015" "/home/parauser"  \
#     "192.168.138.72" "parauser" "hetong@2015" "/home/parauser"
# /opt/wotung/parafs-install/ssh_authorize/ssh_remote_exec.sh "192.168.1.99" "parafs" "tianpusen" "/home/parafs" "ls -d"
# ### ssh_copy.exp
# ./ssh_copy.exp "/opt/4G.data" "192.168.1.99" 'root' 'hetong@2018' '/tmp'
# ./ssh_copy.exp "$0" "192.168.1.99" 'parafs' 'tianpusen' '/opt'
#
# ./ssh_second_login.exp "ht2.r2.n71" 'parauser' "hetong@2015"  \
#     "ht2.r2.n72" "parauser" "hetong@2015" 
# ./ssh_second_login.exp "ht2.r2.n71" 'parauser' "hetong@2015"  \
#     "ht2.r2.n72" "parauser" "hetong@2015" 
# echo $?
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
