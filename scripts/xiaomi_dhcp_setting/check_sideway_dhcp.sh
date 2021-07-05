#!/bin/sh

########################################################################################
# Check smartvpn switch: add or delelte DHCP gateway and DNS option for sideway route
# Created by Daniel.y 2021-06-27
#
# Notice:
# 1. let this script scheduled to run very minute (placed in crontab).
# 2. This script only works on XiaoMi router R3D or R3P.
########################################################################################

. /lib/functions.sh


smartvpn_status_get()
{    
    __tmp="$(ip rule | grep "fwmark 0x10/0x10 lookup vpn" 2>/dev/null)"
    if  [ -n "$__tmp" ]; then
        smartvpn_status="on"
    else
        smartvpn_status="off"
    fi
    return
}


smartvpn_status_get  # checking if smartvpn is running on this machine
if [ $smartvpn_status == "on" ];
then
    echo "smartvpn is running locally. sideway router checking is disabled."
    return    
fi

config_load "smartvpn"
config_get smartvpn_cfg_switch vpn switch &>/dev/null;
config_get samrtvpn_dhcp_sideway dhcp sideway &>/dev/null;

date
echo "smartvpn_cfg_switch = $smartvpn_cfg_switch"
echo "smartvpn_dhcp_sideway = $samrtvpn_dhcp_sideway"

if [ $samrtvpn_dhcp_sideway == "1" ];
then
    if [ $smartvpn_cfg_switch != "1" ];
    then
        touch /tmp/smartvpn_set_main_router
        /usr/sbin/sideway_dhcp.sh off           # 关闭旁路由
        /usr/sbin/softeher_vpn.sh on            # 启动主路由的智能上网
    fi
else
    if [ $smartvpn_cfg_switch == "1" ];
    then
        touch /tmp/smartvpn_set_sideway_router
        /usr/sbin/sideway_dhcp.sh on            # 启动旁路由，不主动关闭组路由的智能上网（需关闭请重启路由）
    fi
fi
