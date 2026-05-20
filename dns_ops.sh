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

# IBM Quad9
ibm91=9.9.9.9
ibm92=149.112.112.112

# IBM Corporate DNS
ibmc1=9.0.128.50
ibmc2=9.0.130.50

#--- End DNS Table entries

# Variables (interface is detected at startup; fallback is "Wi-Fi")
interface="Wi-Fi"
this_machine=$(hostname)
osx=""
osx_major=""
osx_minor=""

prog=$(basename "$0")

initialize_ANSI()
{
    esc=$'\033'
    blackf="${esc}[30m"
    redf="${esc}[31m"
    greenf="${esc}[32m"
    yellowf="${esc}[33m"
    bluef="${esc}[34m"
    purplef="${esc}[35m"
    cyanf="${esc}[36m"
    whitef="${esc}[37m"
    reset="${esc}[0m"
}

highlight_after_colon()
{
    # If there's no colon, just print the line as-is (no duplication).
    if [[ "$1" != *:* ]]; then
        echo "$1"
        return
    fi
    echo "${1%%:*}:${greenf}${1#*:}${reset}"
}

check_err()
{
    local error_state=$?
    if [[ "$error_state" != "0" ]]; then
        echo "$1" >&2
        exit "$error_state"
    fi
}

determine_osx_release()
{
    osx=$(sw_vers -productVersion)
    osx_major=$(echo "$osx" | awk -F. '{print $1}')
    osx_minor=$(echo "$osx" | awk -F. '{print $2}')
}

detect_active_interface()
{
    local default_device hwport
    default_device=$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')
    if [ -n "$default_device" ]; then
        hwport=$(networksetup -listallhardwareports 2>/dev/null | awk -v dev="$default_device" '
            /^Hardware Port:/ {
                port = substr($0, index($0, ":") + 2)
            }
            /^Device:/ {
                if ($2 == dev) { print port; exit }
            }')
    fi
    if [ -n "$hwport" ]; then
        interface="$hwport"
    else
        interface="Wi-Fi"
    fi
}

print_usage()
{
    echo "usage: $prog [-1] [-a] [-c] [-d] [-g] [-h] [-i] [-o] [-p] [-r] [-z]"
    echo "  Sets DNS entries on the active interface [$interface]:"
    echo "    -1  Cloudflare (1.1.1.1 only, single server)"
    echo "    -a  Auto (DHCP assigned)"
    echo "    -c  Cloudflare (1.1.1.1 + 1.0.0.1)"
    echo "    -d  DynDNS"
    echo "    -g  Google"
    echo "    -h  Help"
    echo "    -i  IBM Quad9"
    echo "    -o  OpenDNS"
    echo "    -p  Print current DNS settings"
    echo "    -r  Reset DNS cache"
    echo "    -z  IBM Corporate DNS"
    exit
}

print_dns_entry()
{
    test_for_active_interface

    local dns_value
    dns_value=$(networksetup -getdnsservers "$interface")

    if [[ "$dns_value" == "There aren't any DNS Servers set on"* ]]; then
        echo "$interface DNS is set to autoassigned DHCP values"
        dns_value=$(grep nameserver <(scutil --dns) | awk '{print $NF}' | sort -u | paste - -)
    fi

    echo "Current DNS server entries on [${bluef}${this_machine}${reset}]:"
    echo "${yellowf}${dns_value}${reset}"
}

test_for_active_interface()
{
    echo "Networked interface overview:"

    local device
    device=$(networksetup -listallhardwareports 2>/dev/null | awk -v port="$interface" '
        /^Hardware Port:/ {
            current = substr($0, index($0, ":") + 2)
            match_port = (current == port)
        }
        /^Device:/ {
            if (match_port) { print $2; exit }
        }')

    highlight_after_colon "Interface: $interface"
    [ -n "$device" ] && highlight_after_colon "Device: $device"

    # Wi-Fi specific extras
    if [ "$interface" = "Wi-Fi" ] && [ -n "$device" ]; then
        local power_state ssid
        power_state=$(networksetup -getairportpower "$device" 2>/dev/null)
        [ -n "$power_state" ] && highlight_after_colon "$power_state"

        # macOS 14+ redacts SSID from every userspace source unless the
        # caller has Location Services permission. The "<redacted>"
        # literal coming back IS the detector — no separate API needed.
        local ssid
        ssid=$(ipconfig getsummary "$device" 2>/dev/null \
            | awk -F ' SSID : ' '/ SSID : / {print $2; exit}')
        if [ "$ssid" = "<redacted>" ]; then
            echo "${yellowf}Warning:${reset} Location Services not granted to this terminal — SSID unavailable"
        elif [ -n "$ssid" ]; then
            highlight_after_colon "SSID: $ssid"
        fi
        # ssid empty => not connected to Wi-Fi; stay quiet
    fi
}

edit_nameserver_interface()
{
    if [ "$1" = "empty" ]; then
        echo "${yellowf}DHCP set${reset}"
        sudo networksetup -setdnsservers "$interface" empty
    else
        echo "New entries: ${yellowf}$*${reset}"
        sudo networksetup -setdnsservers "$interface" "$@"
    fi
    check_err "Failed to update DNS servers on [$interface]"
}

reset_dns_cache()
{
    # macOS Lion (10.7) and later all use mDNSResponder.
    # Anything older is no longer supported.
    if (( osx_major >= 11 )) || (( osx_major == 10 && osx_minor >= 7 )); then
        echo "Stopping mDNSResponder..."
        sudo killall -HUP mDNSResponder
        check_err "DNS cache reset failed"
        echo "DNS cache successfully reset"
    else
        echo "Unsupported macOS version: $osx" >&2
        exit 1
    fi
}

### START HERE

determine_osx_release
initialize_ANSI
detect_active_interface

if [ "$#" -lt 1 ]; then
    echo "$prog: too few arguments"
    echo "Try '$prog -h' for more information."
    exit 1
fi

while getopts ":1acdghioprz" option; do
    case "${option}" in
        1)
            echo "Setting [$interface] interface to Cloudflare DNS (single server)"
            edit_nameserver_interface "$cdns1"
            exit;;
        a)
            echo "Setting [$interface] interface to DNS autoassign from DHCP"
            edit_nameserver_interface empty
            exit;;
        c)
            echo "Setting [$interface] interface to Cloudflare DNS"
            edit_nameserver_interface "$cdns1" "$cdns2"
            exit;;
        d)
            echo "Setting [$interface] interface to DynDNS"
            edit_nameserver_interface "$dyndns1" "$dyndns2"
            exit;;
        g)
            echo "Setting [$interface] interface to Google DNS"
            edit_nameserver_interface "$gdns1" "$gdns2"
            exit;;
        h)
            print_usage
            exit;;
        i)
            echo "Setting [$interface] interface to IBM Quad9 DNS"
            edit_nameserver_interface "$ibm91" "$ibm92"
            exit;;
        o)
            echo "Setting [$interface] interface to OpenDNS"
            edit_nameserver_interface "$odns1" "$odns2"
            exit;;
        p)
            print_dns_entry
            exit;;
        r)
            echo "Resetting DNS Cache"
            reset_dns_cache
            exit;;
        z)
            echo "Setting [$interface] interface to IBM Corp DNS"
            edit_nameserver_interface "$ibmc1" "$ibmc2"
            exit;;
        *)
            echo "$prog: illegal option -- ${OPTARG}" >&2
            print_usage
            ;;
    esac
done
