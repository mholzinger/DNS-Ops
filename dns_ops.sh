#!/bin/bash

#--- Start DNS Table entries
# GOOGLE DNS
gdns1=8.8.8.8
gdns2=8.8.4.4

# OPENDNS
odns1=208.67.222.222
odns2=208.67.220.220

# DYNDNS
dyndns1=216.146.35.35
dyndns2=216.146.36.36

# CLOUDFLARE
cdns1=1.1.1.1
cdns2=1.0.0.1
#--- End DNS Table entries

# Variables
interface=Wi-Fi
this_machine=$( hostname )
osx=""
osx_minor=""

# OSX Minor rev strings
tiger=4
leopard=5
snow_leopard=6
lion=7
mt_lion=8
mavericks=9
yosemite=10

# This script name
prog=$( echo $0 | sed 's|^\./||' | awk '{gsub(/\/.*\//,"",$1); print}' )

# SHELL MOD
initialize_ANSI()
{
#  esc="\033" # if this doesn't work, enter an ESC directly
    esc=""
    blackf="${esc}[30m";
    redf="${esc}[31m";
    greenf="${esc}[32m";
    yellowf="${esc}[33m";
    bluef="${esc}[34m";
    purplef="${esc}[35m";
    cyanf="${esc}[36m";
    whitef="${esc}[37m";
    reset="${esc}[0m";
}

highlight_after_colon()
{
    color_pattern=$( echo $1 | cut -d ':' -f 2)
    echo ${1%%:*}:${greenf}${color_pattern}${reset}
}

check_err(){
    error_state=$(echo $?)
    if [[ "$error_state" != "0" ]]; then
        echo $1
        exit
    fi
}

determine_osx_release()
{
    osx=$( sw_vers -productVersion )
    osx_minor=$( sw_vers -productVersion | awk -F \. {'print $2}' )
}

print_usage()
{
    echo "usage: "$prog" [-a auto] [-c cloudflare] [-d dyndns] [-g google] [-h help] [-o opendns] [-p print] [-r reset]"
    echo "  This utility sets ["$interface"] DNS entries to CloudFlare, DynDNS, Google, OpenDNS or DHCP host (auto)"
    echo "  eg: $prog -g   <--- sets the "$interface" interface to use Google DNS"
    exit;
}

print_dns_entry()
{
    #debug stuff
    test_for_active_interface
    #end debug stuff

    dns_value=$(networksetup -getdnsservers Wi-Fi)

    if [ "$dns_value" == "There aren't any DNS Servers set on Wi-Fi." ]; then
        echo "Wi-Fi DNS is set to autoassigned DHCP Values"
        dns_value=$(grep nameserver <(scutil --dns)|awk '{print $NF}'|sort -u | paste - -)
    fi

    echo "Current DNS server entries on [${bluef}$this_machine${reset}]:"
    echo ${yellowf}$dns_value${reset}

#    cat /etc/resolv.conf | sed '/#/d'
#    scutil --dns | grep nameserver | cut -d : -f 2 | sort -u
}

test_for_active_interface()
{
    # Check for Wi-Fi interface and test powerstate before testing connection
    wifi_interface=$( networksetup -listallhardwareports \
        | sed -n '/Wi-Fi/{n;p;}' \
        | awk '/Device/ {print $2}' )
    wifi_power_state=$( networksetup -getairportpower $wifi_interface )
    wifi_connected_ssid=$( networksetup -getairportnetwork $wifi_interface )

    echo Networked interface overview:
    highlight_after_colon "$interface Interface: $wifi_interface"
    highlight_after_colon "$wifi_power_state"
    highlight_after_colon "$wifi_connected_ssid"
}

edit_nameserver_interface()
{
    # USING NETWORKSETUP
    if [ "$1" == "empty" ]; then
        echo ${yellowf}"DHCP set"${reset}
    else
        echo "New entries :" ${yellowf}$1 $2${reset}
    fi
    sudo networksetup -setdnsservers $interface $1 $2
}

edit_searchdomain()
{
    sudo networksetup -setsearchdomains $interface $1
}

reset_dns_cache()
{
    # Test OS X Minor version and run command

    # 10.4 and below
    if (( osx_minor <= tiger )); then
        echo "Exec lookupd -flushcache..."
        lookupd -flushcache
    fi

    # 10.5 and 10.6
    if (( ( osx_minor == leopard ) || ( osx_minor == snow_leopard ) )); then
        echo "Exec dscacheutil -flushcache..."
        sudo dscacheutil -flushcache
    fi

    # 10.7 through current
    if (( osx_minor >= lion )); then
        echo "Stopping mDNSResponder..."
        sudo killall -HUP mDNSResponder
    fi

    check_err "DNS cache reset failed"
    echo "DNS cache successfully reset"
}

### START HERE

determine_osx_release
initialize_ANSI

# Test for passed parameters, if none, print out DNS entry and help text
if [ "$#" -lt 1 ]; then
    echo $prog": too few arguments"
    echo "Try '"$prog" -h' for more information."
fi

# Main processing loop
while getopts :acdghopr option; do
  case "${option}" in
    a)
        a=${OPTARG}
        echo "Setting" [$interface] "interface to DNS autoassign from DHCP"
        edit_nameserver_interface empty
        exit;;
    d)
        d=${OPTARG}
        echo "Setting" [$interface] "interface to DynDNS"
        edit_nameserver_interface $dyndns1 $dyndns2
        exit;;
    c)
        a=${OPTARG}
        echo "Setting" [$interface] "interface to Cloudflare DNS"
        edit_nameserver_interface $cdns1 $cdns2
        exit;;
    g)
        a=${OPTARG}
        echo "Setting" [$interface] "interface to Google DNS"
        edit_nameserver_interface $gdns1 $gdns2
        exit;;
    h)
        h=${OPTARG}
        print_usage
        exit;;
    o)
        o=${OPTARG}
        echo "Setting" [$interface] "interface to OpenDNS"
        edit_nameserver_interface $odns1 $odns2
        exit;;
    p)
        p=${OPTARG}
        print_dns_entry
        exit;;
    r)
        r=${OPTARG}
        echo "Resetting DNS Cache"
        reset_dns_cache
        exit;;
    *)
        # Evaluate passed parameters, if none display DNS and exit with help statement
        echo $prog: illegal option -- ${OPTARG}
        print_usage
        ;;
  esac
done
