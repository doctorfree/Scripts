#!/bin/bash
#
## @file Wallpapers/saver.sh
## @brief Convenience frontend for xscreensaver to manage slideshow screen saver folders
## @author Ronald Joe Record (rr at ronrecord dot com)
## @copyright Copyright (c) 2018, Ronald Joe Record, all rights reserved.
## @date Written 17-Oct-2018
## @version 1.0.1
##


PICDIR="$HOME/Pictures"
BGNDS="Backgrounds"
CONF="$HOME/.xscreensaver"
SHOW="glslideshow -root -duration"

usage() {
    echo "Usage: saver [-u] [-n] [-r] [-b backgrounds_dir] [-c command] [-d duration]"
    echo "Where <backgrounds dir> can be one of"
    echo -e "\n\tModels:"
    echo -e "\t[Alisa|Carisha|Corinna|Mila|Russians|Natalia|Tuigirl]"
    echo -e "\n\tPhotographers/Artists:"
    echo -e "\t[Nikolaev|Safin|Sakimichan|Soell]"
    echo -e "\n\tGeneral:"
    echo -e "\t[All|Favs|Fractals|Models|Owls|Photographers|Waterfalls]"
    echo ""
    echo "<command> can be one of:"
    echo "    [activate|deactivate|demo|exit|lock|restart|start]"
    echo ""
    echo "<duration> is specified in seconds"
    echo ""
    echo "-n indicates tell me what you would do without doing anything"
    echo "-r indicates restart xscreensaver prior to running command"
    echo "-u displays this usage message"
    echo ""
    echo "Current XScreenSaver image directory set to $BGDIR"
    echo "Current XScreenSaver glslideshow duration set to $ODUR"
    exit 1
}

BGDIR=`grep imageDirectory $CONF | awk ' { print $2 } '`
ODUR=`grep glslideshow $CONF | awk -F ":" ' { print $2 } ' | awk ' { print $4 } '`

# No arguments we take to mean activate the screensaver
[ "$1" ] || {
    xscreensaver-command -activate > /dev/null
    exit 0
}

BDIR=
COMM=
SECS=
TELL=
RESTART=
dir_arg=
com_arg=

while getopts b:c:d:nru flag; do
    case $flag in
        b)
            dir_arg="$OPTARG"
            ;;
        c)
            com_arg="$OPTARG"
            ;;
        d)
            SECS="$OPTARG"
            ;;
        n)
            TELL=1
            ;;
        r)
            RESTART=1
            ;;
        u)
            usage
            ;;
    esac
done
shift $(( OPTIND - 1 ))

[ "$dir_arg" ] && {
    case "$dir_arg" in
        alisa|alisa_i|Alisa_I|Alisa) BDIR="Alisa_I"
               ;;
        all|All) BDIR="All"
               ;;
        carisha|Carisha) BDIR="Carisha"
               ;;
        corinna|Corinna) BDIR="Corinna"
               ;;
        favs|Favs) BDIR="Favs"
               ;;
        fractals|Fractals) BDIR="Fractals"
               ;;
        mila_a|Mila_A|mila|Mila) BDIR="Mila_A"
               ;;
        models|Models) BDIR="Models"
               ;;
        natalia|Natalia|Natalia_Andreeva) BDIR="Natalia_Andreeva"
               ;;
        owls|Owls) BDIR="Owls"
               ;;
        photo*|Photo*) BDIR="Photographers"
               ;;
        russian*|Russian*) BDIR="Russians"
               ;;
        safin|Safin|Marat*|marat*) BDIR="Marat_Safin"
               ;;
        saki|sakimichan|Sakimichan|Saki) BDIR="Sakimichan"
               ;;
        soell|Soell) BDIR="Soell"
               ;;
        tui|tuigirl|Tui|Tuigirl) BDIR="Tuigirl"
               ;;
        vlad|vladimir|Vlad|Vladimir|*Nikolaev) BDIR="Vladimir_Nikolaev"
               ;;
        waterfalls|Waterfalls) BDIR="Waterfalls"
               ;;
        *) usage
               ;;
    esac
}

[ "$com_arg" ] && {
    case "$com_arg" in
        activate|deactivate|demo|exit|lock|restart) COMM="$com_arg"
            ;;
        start) 
            if [ "$TELL" ]
            then
                echo "xscreensaver &"
            else
                xscreensaver &
            fi
            ;;
    esac
}

[ "$BDIR" ] && {
  [ "$PICDIR/$BGNDS/$BDIR" == "$BGDIR" ] || {
    ODIR=`basename $BGDIR`
    if [ "$TELL" ]
    then
        echo "cat $CONF | sed -e s/$BGNDS\/$ODIR/$BGNDS\/$BDIR/ > /tmp/xscr$$"
        echo "cp /tmp/xscr$$ $CONF"
        echo "rm -f /tmp/xscr$$"
    else
        cat $CONF | sed -e "s/$BGNDS\/$ODIR/$BGNDS\/$BDIR/" > /tmp/xscr$$
        cp /tmp/xscr$$ $CONF
        rm -f /tmp/xscr$$
    fi
  }
}
[ "$SECS" ] && {
  [ $ODUR -eq $SECS ] || {
    if [ "$TELL" ]
    then
        echo "cat $CONF | sed -e s/$SHOW $ODUR -pan $ODUR/$SHOW $SECS -pan $SECS/ > /tmp/xscr$$"
        echo "cp /tmp/xscr$$ $CONF"
        echo "rm -f /tmp/xscr$$"
    else
        cat $CONF | sed -e "s/$SHOW $ODUR -pan $ODUR/$SHOW $SECS -pan $SECS/" > /tmp/xscr$$
        cp /tmp/xscr$$ $CONF
        rm -f /tmp/xscr$$
    fi
  }
}

[ "$COMM" ] && {
    if [ "$TELL" ]
    then
        [ "$RESTART" ] && {
          echo -e "\nxscreensaver-command -exit > /dev/null"
          echo "xscreensaver &"
        }
        echo -e "\nxscreensaver-command -$COMM > /dev/null"
    else
        [ "$RESTART" ] && {
          xscreensaver-command -exit > /dev/null
          xscreensaver &
        }
        xscreensaver-command -$COMM > /dev/null
    fi
}