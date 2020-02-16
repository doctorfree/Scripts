#!/bin/bash
#
## @file mirror.sh
## @brief Convenience script to manage multiple MagicMirror configurations
## @author Ronald Joe Record (rr at ronrecord dot com)
## @copyright Copyright (c) 2020, Ronald Joe Record, all rights reserved.
## @date Written 1-feb-2020
## @version 1.0.0
##
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# The Software is provided "as is", without warranty of any kind, express or
# implied, including but not limited to the warranties of merchantability,
# fitness for a particular purpose and noninfringement. In no event shall the
# authors or copyright holders be liable for any claim, damages or other
# liability, whether in an action of contract, tort or otherwise, arising from,
# out of or in connection with the Software or the use or other dealings in
# the Software.
#
# User configurable settings. Make sure these are correct for your system.
# -----------------------------------------------------------------------
# Set this to your MagicMirror installation directory
MM="${HOME}/MagicMirror"
# Set the IP and PORT to the values on your system
IP="10.0.1.67"
PORT="8080"
# Set this to the X11 DISPLAY you are using. DISPLAY=:0 works for most systems.
export DISPLAY=:0
# -----------------------------------------------------------------------
CONFDIR="${MM}/config"
CONFS=
INFO="all"
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
usejq=`type -p jq`

[ -d "${CONFDIR}" ] || {
    printf "\nCONFDIR does not exist or is not a directory. Exiting.\n"
    exit 1
}
cd "${CONFDIR}"

getconfs() {
    numconfs=0
    for i in config-*.js
    do
        j=`echo $i | awk -F "-" ' { print $2 } ' | sed -e "s/.js//"`
        CONFS="${CONFS} $j"
        [ "$1" == "usage" ] && {
            numconfs=`expr $numconfs + 1`
            [ $numconfs -gt 8 ] && {
                CONFS="${CONFS}\n\t"
                numconfs=0
            }
        }
    done
}

usage() {
    getconfs usage
    printf "\n${BOLD}Usage:${NORMAL} mirror <command> [args]"
    printf "\nWhere <command> can be one of the following:"
    printf "\n\tinfo [temp|mem|disk|usb|net|wireless|screen], list <active|installed|configs>,"
    printf " select, restart, start, stop, status, getb, setb <num>"
    printf "\nor specify a config file to use with one of:"
    printf "\n\t${CONFS}"
    printf "\nor any other config file you have created in ${CONFDIR} of the form:"
    printf "\n\tconfig-<name>.js"
    printf "\nA config filename argument will be resolved into a config filename of the form:"
    printf "\n\tconfig-\$argument.js"
    printf "\n\n${BOLD}Examples:${NORMAL}"
    printf "\n\tmirror\t\t# Invoked with no arguments the mirror command displays a command menu"
    printf "\n\tmirror list active\t\t# lists active modules"
    printf "\n\tmirror list configs\t\t# lists available configuration files"
    printf "\n\tmirror restart\t\t# Restart MagicMirror"
    printf "\n\tmirror fractals\t\t# Installs configuration file config-fractals.js"
    printf " and restarts MagicMirror"
    printf "\n\tmirror info\t\t# Displays all MagicMirror system information"
    printf "\n\tmirror info screen\t\t# Displays MagicMirror screen information"
    printf "\n\tmirror status\t\t# Displays MagicMirror status"
    printf "\n\tmirror getb\t\t# Displays current MagicMirror brightness level"
    printf "\n\tmirror setb 150\t\t# Sets MagicMirror brightness level to 150"
    printf "\n\tmirror -u\t\t# Display this usage message\n"
    exit 1
}

list_usage() {
    printf "\n${BOLD}List Usage:${NORMAL} mirror list <active|installed|configs>"
    printf "\nWhere 'active', 'installed', or 'configs' must be specified."
    printf "\nThis command will list either all active or installed modules or all configs.\n"
    usage
}

setb_usage() {
    printf "\n${BOLD}Setb Usage:${NORMAL} mirror setb [number]"
    printf "\nWhere 'number' is an integer value in the range 0-200\n"
    usage
}

setconf() {
    conf=$1
    mv config.js config-$$.js
    ln -s config-${conf}.js config.js
    npm run --silent config:check > /dev/null
    [ $? -eq 0 ] || {
        printf "\nMagicMirror configuration config-${conf}.js needs work."
        printf "\nTry again after you have addressed these issues:\n"
        npm run --silent config:check
        rm -f config.js
        mv config-$$.js config.js
        exit 1
    }
    [ -L config-$$.js ] && rm -f config-$$.js
    pm2 restart mm --update-env
    sleep 10
    if [ "${conf}" == "blank" ]
    then
        if [ "$usejq" ]
        then
            curl -X GET http://${IP}:${PORT}/api/brightness/0 2> /dev/null | jq .
        else
            curl -X GET http://${IP}:${PORT}/api/brightness/0
            echo ""
        fi
    else
        if [ "$usejq" ]
        then
            curl -X GET http://${IP}:${PORT}/api/brightness/180 2> /dev/null | jq .
        else
            curl -X GET http://${IP}:${PORT}/api/brightness/180
            echo ""
        fi
    fi
}

system_info() {
    printf "\n${BOLD}System information for:${NORMAL}\n"
    uname -a
    [ "$INFO" == "all" ] || [ "$INFO" == "temp" ] && {
        printf "\nCPU `vcgencmd measure_temp`\n"
    }
    [ "$INFO" == "all" ] || [ "$INFO" == "mem" ] && {
        printf "\n${BOLD}Memory:${NORMAL}\n"
        free -h
    }
    [ "$INFO" == "all" ] || [ "$INFO" == "disk" ] && {
        printf "\n${BOLD}Disk and filesystem usage:${NORMAL}\n"
        findmnt --fstab --evaluate
        printf "\n"
        df -h -x tmpfs -x udev -x devtmpfs
    }
    [ "$INFO" == "all" ] || [ "$INFO" == "usb" ] && {
        printf "\n${BOLD}USB Devices:${NORMAL}\n"
        lsusb
    }
    [ "$INFO" == "all" ] || [ "$INFO" == "net" ] && {
        printf "\n${BOLD}Network IP/mask:${NORMAL}\n"
        ifconfig | grep inet | grep netmask
    }
    [ "$INFO" == "all" ] || [ "$INFO" == "wireless" ] && {
        printf "\n${BOLD}Wireless info:${NORMAL}\n"
        iwconfig 2> /dev/null | grep ESSID | while read entry
        do
            interface=`echo $entry | awk ' { print $1 } '`
            iwconfig $interface
        done
    }
    [ "$INFO" == "all" ] || [ "$INFO" == "screen" ] && {
        printf "${BOLD}Screen dimensions and resolution:${NORMAL}\n"
        xrandr | grep Screen
        xdpyinfo | grep dimensions
        xdpyinfo | grep resolution
    }
}

get_info_type() {
    PS3="${BOLD}Please enter desired system info type (numeric or text): ${NORMAL}"
    options=(all temp mem disk usb net wireless screen quit back)
    select opt in "${options[@]}"
    do
        case "$opt,$REPLY" in
            "back",*|*,"back")
                break
                ;;
            "quit",*|*,"quit")
                exit 0
                ;;
            "all",*|*,"all")
                INFO="all"
                system_info
                break
                ;;
            "temp",*|*,"temp")
                INFO="temp"
                system_info
                break
                ;;
            "mem",*|*,"mem")
                INFO="mem"
                system_info
                break
                ;;
            "disk",*|*,"disk")
                INFO="disk"
                system_info
                break
                ;;
            "usb",*|*,"usb")
                INFO="usb"
                system_info
                break
                ;;
            "net",*|*,"net")
                INFO="net"
                system_info
                break
                ;;
            "wireless",*|*,"wireless")
                INFO="wireless"
                system_info
                break
                ;;
            "screen",*|*,"screen")
                INFO="screen"
                system_info
                break
                ;;
            *)
                printf "\nInvalid entry. Please try again"
                printf "\nEnter either a number or text of one of the menu entries\n"
                ;;
        esac
    done
}

# If invoked with no arguments present a menu of options to select from
[ "$1" ] || {
  while true
  do
    PS3="${BOLD}Please enter your MagicMirror command choice (numeric or text): ${NORMAL}"
    options=("list active modules" "list installed modules" "list configurations" "select configuration" "restart" "start" "stop" "status" "get brightness" "set brightness" "system info" "quit")
    select opt in "${options[@]}"
    do
        case "$opt,$REPLY" in
            "list active modules",*|*,"list active modules")
                mirror list active
                break
                ;;
            "list installed modules",*|*,"list installed modules")
                mirror list installed
                break
                ;;
            "list configurations",*|*,"list configurations")
                mirror list configs
                break
                ;;
            "select configuration",*|*,"select configuration")
                printf "======================================================\n\n"
                mirror select
                break
                ;;
            "get brightness",*|*,"get brightness")
                mirror getb
                break
                ;;
            "set brightness",*|*,"set brightness")
                while true
                do
                  read -p "Enter a brightness level between 0 and 200 or 'exit' to quit" answer
                  [ "$answer" == "exit" ] && break
                  if [ $answer -ge 0 ] && [ $answer -le 200 ]
                  then
                      printf "\nSetting MagicMirror Brightness Level to $answer\n"
                      if [ "$usejq" ]
                      then
                          curl -X GET http://${IP}:${PORT}/api/brightness/$answer 2> /dev/null | jq .
                      else
                          curl -X GET http://${IP}:${PORT}/api/brightness/$answer
                          echo ""
                      fi
                  else
                      printf "\nBrightness setting $answer out of range or not a number"
                      printf "\nValid brightness values are integer values [0-200]\n"
                  fi
                done
                break
                ;;
            "system info",*|*,"system info")
                get_info_type
                break
                ;;
            "start",*|*,"start")
                mirror start
                break
                ;;
            "stop",*|*,"stop")
                mirror stop
                break
                ;;
            "status",*|*,"status")
                mirror status
                break
                ;;
            "restart",*|*,"restart")
                mirror restart
                break
                ;;
            "quit",*|*,"quit")
                printf "\nExiting\n"
                exit 0
                ;;
        esac
    done
  done
}

# TODO: convert use of "$1" to getopts argument processing
while getopts u flag; do
    case $flag in
        u)
            usage
            ;;
    esac
done

[ "$1" == "select" ] && {
    getconfs select
    PS3="${BOLD}Please enter your MagicMirror configuration choice (numeric or text): ${NORMAL}"
    options=(${CONFS} quit)
    select opt in "${options[@]}"
    do
        case "$opt,$REPLY" in
            "quit",*|*,"quit")
                printf "\nExiting\n"
                exit 0
                ;;
            *)
                if [ -f config-${opt}.js ]
                then
                    printf "\nInstalling config-${opt}.js MagicMirror configuration file\n"
                    setconf ${opt}
                    break
                else
                    if [ -f config-${REPLY}.js ]
                    then
                        printf "\nInstalling config-${REPLY}.js MagicMirror configuration file\n"
                        setconf ${REPLY}
                        break
                    else
                        printf "\nInvalid entry. Please try again"
                        printf "\nEnter either a number or text of one of the menu entries\n"
                    fi
                fi
                ;;
        esac
    done
    exit 0
}

[ "$1" == "info" ] && {
    [ "$2" ] && INFO="$2"
    system_info
    exit 0
}

[ "$1" == "restart" ] && {
    printf "\n${BOLD}Restarting MagicMirror${NORMAL}\n"
    pm2 restart mm --update-env
    printf "\n${BOLD}Done${NORMAL}\n"
    exit 0
}

[ "$1" == "start" ] && {
    printf "\n${BOLD}Starting MagicMirror${NORMAL}\n"
    pm2 start mm --update-env
    printf "\n${BOLD}Done${NORMAL}\n"
    exit 0
}

[ "$1" == "stop" ] && {
    printf "\n${BOLD}Stopping MagicMirror${NORMAL}\n"
    pm2 stop mm --update-env
    printf "\n${BOLD}Done${NORMAL}\n"
    exit 0
}

[ "$1" == "status" ] && {
    printf "\n${BOLD}MagicMirror Status:${NORMAL}\n"
    pm2 status mm --update-env
    CONF=`readlink -f ${CONFDIR}/config.js`
    printf "\nUsing config file `basename ${CONF}`"
    printf "\n${BOLD}Done${NORMAL}\n"
    exit 0
}

[ "$1" == "getb" ] && {
    printf "\n${BOLD}Getting MagicMirror Brightness Level${NORMAL}\n"
    if [ "$usejq" ]
    then
        curl -X GET http://${IP}:${PORT}/api/brightness 2> /dev/null | jq .
    else
        curl -X GET http://${IP}:${PORT}/api/brightness
        echo ""
    fi
    exit 0
}

[ "$1" == "list" ] && {
    [ "$2" ] || {
        printf "\nArgument of 'active', 'installed', or 'configs' required to list modules."
        list_usage
    }
    if [ "$2" == "active" ]
    then
        printf "\n${BOLD}Listing Active MagicMirror modules${NORMAL}\n"
        if [ "$usejq" ]
        then
            curl -X GET http://${IP}:${PORT}/api/modules 2> /dev/null | jq .
        else
            curl -X GET http://${IP}:${PORT}/api/modules
            echo ""
        fi
    else
        if [ "$2" == "installed" ]
        then
            printf "\n${BOLD}Listing Installed MagicMirror modules${NORMAL}\n"
            if [ "$usejq" ]
            then
                curl -X GET http://${IP}:${PORT}/api/modules/installed 2> /dev/null | jq .
            else
                curl -X GET http://${IP}:${PORT}/api/modules/installed
                echo ""
            fi
        else
            if [ "$2" == "configs" ]
            then
                printf "\n${BOLD}Listing MagicMirror configuration files:${NORMAL}\n\n"
                ls -1 *.js
            else
                printf "\nmirror list $2 is not an accepted 2nd argument."
                printf "\nValid 2nd arguments to the list command are 'active', 'installed', and 'configs'"
                list_usage
            fi
        fi
    fi
    exit 0
}

[ "$1" == "setb" ] && {
    [ "$2" ] || {
        printf "\nNumeric argument required to specify Mirror brightness.\n"
        setb_usage
    }
    if [ "$2" -ge 0 ] && [ "$2" -le 200 ]
    then
        printf "\n${BOLD}Setting MagicMirror Brightness Level to $2${NORMAL}\n"
        if [ "$usejq" ]
        then
            curl -X GET http://${IP}:${PORT}/api/brightness/$2 2> /dev/null | jq .
        else
            curl -X GET http://${IP}:${PORT}/api/brightness/$2
            echo ""
        fi
    else
        printf "\nBrightness setting $2 out of range or not a number"
        printf "\nValid brightness values are integer values [0-200]\n"
        setb_usage
    fi
    exit 0
}

if [ "$1" == "normal" ]
then
    mode="default"
else
    mode="$1"
fi
[ "$1" == "waterfall" ] && mode="waterfalls"
[ "$1" == "fractal" ] && mode="fractals"

if [ -f config-${mode}.js ]
then
    setconf ${mode}
else
    printf "\nNo configuration file config-${mode}.js found.\n\n"
    usage
fi
exit 0
