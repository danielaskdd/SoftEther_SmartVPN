#!/bin/sh

########################################################################################
# Add or remove DHCP gateway option for sideway router
# Created by Daniel.y 2021-06-27
#
# Notice:
# 1. You should change the sideway router address in this script at your first use.
# 2. This script only works on XiaoMi router R3D or R3P.
########################################################################################

. /lib/functions.sh

sideway_off()
{
    echo "Setting DHCP gateway to main router..."

    uci set smartvpn.dhcp=gateway
    uci set smartvpn.dhcp.sideway=0
    uci commit smartvpn

    uci delete dhcp.@dnsmasq[0].dhcp_option 2>/dev/null
    uci commit dhcp

    uci set smartvpn.vpn.switch=0
    uci commit smartvpn

    /etc/init.d/dnsmasq restart    
}

sideway_on()
{
    echo "Setting DHCP gateway to sideway router..."

    uci set smartvpn.dhcp=gateway
    uci set smartvpn.dhcp.sideway=1
    uci commit smartvpn

    uci delete dhcp.@dnsmasq[0].dhcp_option 2>/dev/null
    uci add_list dhcp.@dnsmasq[0].dhcp_option="3,192.168.3.254"
    uci add_list dhcp.@dnsmasq[0].dhcp_option="6,192.168.3.254"
    uci commit dhcp

    uci set smartvpn.vpn.switch=1
    uci commit smartvpn

    /etc/init.d/dnsmasq restart

}

show_usage()
{
    echo
    echo "add or remove dhcp setting for sideway router"
    echo "usage: ./sideway_dhcp.sh on|off"
    echo
    echo "sideway = $samrtvpn_dhcp_sideway"
    echo "samrtvpn switch = $smartvpn_cfg_switch"
    echo ""
}

# main

OPT=$1

config_load "smartvpn"
config_get smartvpn_cfg_switch vpn switch &>/dev/null;
config_get samrtvpn_dhcp_sideway dhcp sideway &>/dev/null;

#smartvpn_cfg_switch=0
#samrtvpn_dhcp_sideway="0"

check_smartvpn_lock="/var/run/smartvpn_dhcp_check.lock"

trap "lock -u $check_smartvpn_lock; exit 1" SIGHUP SIGINT SIGTERM
lock $check_smartvpn_lock

case $OPT in
    on)
        sideway_on
        lock -u $check_smartvpn_lock
        return $?
    ;;

    off)
        sideway_off
        lock -u $check_smartvpn_lock
        return $?
    ;;

    *)
        show_usage
        lock -u $check_smartvpn_lock
        return 1
    ;;
esac
