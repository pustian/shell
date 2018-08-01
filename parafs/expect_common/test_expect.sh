#!/bin/bash
# ###++++++++++++++++++++++++      test begin       ++++++++++++++++++++++++++###
# ### ssh_login.exp
#  ./ssh_login.exp "192.168.138.71" "root" "Tianpusen@2" "/root" 
#  ./ssh_login.exp "192.168.138.72" "root" "Tianpusen@1" "/root" 
#  ./ssh_login.exp "192.168.1.99" "parafs" "tianpusen" "/home/parafs"


# ### ssh_remote_exec.exp
#  ./ssh_remote_exec.exp "192.168.138.71" "root" "Tianpusen@1" "ls -la /root" 
#  ./ssh_remote_exec.exp "192.168.138.72" "root" "Tianpusen@1" "ls -la /aaa"
# ./ssh_remote_exec.exp "192.168.138.72" "root" "Tianpusen@1" "cat /etc/passwd"  >aa
#  ./ssh_remote_exec.exp "192.168.1.99" "parafs" "tianpusen" "grep parauser /etc/passwd"

# ### current_authorize.exp
# ./current_authorize.exp "192.168.138.71" 'parauser' "hetong@2015" "/home/parauser"  \
#     "192.168.138.71" "parauser" "hetong@2015" "/home/parauser"
# ./current_authorize.exp "192.168.138.71" 'parauser' "hetong@2015" "/home/parauser"  \
#     "192.168.138.72" "parauser" "hetong@2015" "/home/parauser"
# /opt/wotung/parafs-install/ssh_authorize/ssh_remote_exec.sh "192.168.1.99" "parafs" "tianpusen" "/home/parafs" "ls -d"
# ###++++++++++++++++++++++++      test end         ++++++++++++++++++++++++++###
