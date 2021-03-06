#!/bin/bash
#
## @file Wallpapers/saver.sh
## @brief Convenience frontend for xscreensaver to manage slideshow screen saver folders
## @author Ronald Joe Record (rr at ronrecord dot com)
## @copyright Copyright (c) 2018, Ronald Joe Record, all rights reserved.
## @date Written 17-Oct-2018
## @version 1.0.5
##
# --------------------------------------------------------------------------------------
# Modify the following to reflect the location and names of image folders on your system
# (Alternately, these settings can be specified on the command line)
# --------------------------------------------------------------------------------------
# These two define the location of pre-created folders of links to background images
PICDIR="$HOME/Pictures"
BGNDS="Backgrounds"

# The xscreensaver configuration file to be edited and the command to look for in it
CONF="$HOME/.xscreensaver"
SHOW="glslideshow -root -duration"

# The top of the directory hierarchy that contains the original image folders
ITOP="/u/pictures"
# The names of those original image folders
DBACK="Domai"
FBACK="Femjoy"
PBACK="Playboy"
SBACK="Safe"
WBACK="Wallhaven"
XBACK="X-Art"
# ----------------------------
# End of user-defined settings
# ----------------------------

# Default paths and folder names for original images and pre-created folders of links
WHVN="$ITOP/$WBACK"
SAFE="$ITOP/$SBACK"
DMAI="$ITOP/$DBACK"
FMJY="$ITOP/$FBACK"
PLBY="$ITOP/$PBACK"
XART="$ITOP/$XBACK"
WDIR="$WHVN"
WBCK="$WBACK"
BACK="$PICDIR/$BGNDS/$WBCK"

current() {
    echo ""
    echo "Current XScreenSaver image directory set to $BGDIR"
    echo "Current XScreenSaver glslideshow duration set to $ODUR"
    echo "Current XScreenSaver mode set to $MODE"
}

usage() {
    echo "Usage: saver [-BDFHIPWX path] [-adflnprsxu] [-b backgrounds_dir] [-c command] [-t duration]"
    echo ""
    echo "Where <backgrounds dir> can be one of:"
    echo -e "\tAny subdir in $WHVN"
    echo -e "\tAny subdir in $DMAI if -d has been specified"
    echo -e "\tAny subdir in $FMJY if -f has been specified"
    echo -e "\tAny subdir in $PLBY if -p has been specified"
    echo -e "\tAny subdir in $SAFE if -s has been specified"
    echo -e "\tAny subdir in $XART if -x has been specified"
    echo -e "\tOne of the pre-created dirs in $BACK"
    echo -e "\n\tCurrent pre-created dirs include"
    echo -e "\n\tModels:"
    echo -e "\t[Alisa|Carisha|Corinna|Jasmine_A|Li_Moon|Mila]"
    echo -e "\n\tPhotographers/Artists/Sites:"
    echo -e "\t[Femjoy|Nikolaev|Russians|Safin|Sakimichan|Soell|Tuigirl]"
    echo -e "\n\tGeneral:"
    echo -e "\t[All|Anime|Favs|Fractals|Hentai|Owls|Waterfalls]"
    echo -e "\n\tSafe:"
    echo -e "\t[All|Favs|Dragonflies|Fractals|Owls|Space|Waterfalls]"
    echo ""
    echo "<command> can be one of:"
    echo "    [activate|deactivate|blank|demo|exit|lock|restart|slides|start]"
    echo ""
    echo "<duration> is specified in seconds"
    echo ""
    echo "-a indicates do not remove portrait format images"
    echo "-d indicates use $DMAI rather than $WHVN"
    echo "-f indicates use $FMJY rather than $WHVN"
    echo "-l indicates list the pre-created wallpaper subdirs available for the selected type"
    echo "-n indicates tell me what you would do without doing anything"
    echo "-p indicates use $PLBY rather than $WHVN"
    echo "-r indicates restart xscreensaver prior to running command"
    echo "-s indicates use $SAFE rather than $WHVN"
    echo "-x indicates use $XART rather than $WHVN"
    echo "-u displays this usage message"
    echo ""
    echo "The '-BFIPSWX path' options control the filesystem paths to original image folders"
    echo "and pre-created folders of links to selected image folders."
    echo ""
    echo "-I path indicates use path as the top-level pathname to folders of original images"
    echo "-D n1,-F n2,-S n3,-W n4, and -X n5 are the names of subfolders in the top-level folder"
    echo "-H path indicates use path as the full pathname to PICDIR where links will be created"
    echo "-B name indicates use name as the subfolder in PICDIR where folders of links live"
    echo ""
    echo "Current settings for these user defined paths and folder names are:"
    echo ""
    echo "Top-level original image folder ITOP = $ITOP"
    echo "-D n1 specified \$ITOP/\$n1 = $ITOP/$DBACK"
    echo "-F n2 specified \$ITOP/\$n2 = $ITOP/$FBACK"
    echo "-P n3 specified \$ITOP/\$n3 = $ITOP/$PBACK"
    echo "-S n4 specified \$ITOP/\$n4 = $ITOP/$SBACK"
    echo "-W n5 specified \$ITOP/\$n5 = $ITOP/$WBACK"
    echo "-X n6 specified \$ITOP/\$n6 = $ITOP/$XBACK"
    echo "-H path, -B name specified path/name/back = $PICDIR/$BGNDS/$WBCK"
    if [ "$LIST" ]
    then
        listem
    else
        current
    fi
    exit 1
}

linkem() {
    case $WDIR in
        $WHVN|$SAFE|$DMAI|$PLBY)
            for pic in "$1"/*
            do
                [ "$pic" == "$1/*" ] && {
                    echo "No images found for $1 in $WDIR"
                    continue
                }
                ln -s "$pic" .
            done
            ;;
        *)
            for pic in "$1"/*/*
            do
                [ "$pic" == "$1/*/*" ] && {
                    echo "No images found for $1 in $WDIR"
                    continue
                }
                ln -s "$pic" .
            done
            ;;
    esac
    rm -f *.txt
    rm -f *.gif

    [ "$rmportrait" ] && {
        inst=`type -p identify`
        [ "$inst" ] && {
            for i in *.jpg *.jpeg *.png
            do
                [ "$i" == "*.jpg" ] && continue
                [ "$i" == "*.jpeg" ] && continue
                [ "$i" == "*.png" ] && continue
                GEO=`identify "$i" | awk ' { print $(NF-6) } '`
                W=`echo $GEO | awk -F "x" ' { print $1 } '`
                # Remove if width not greater than 1000
                [ "$W" ] && [ $W -gt 1000 ] || {
                    rm -f "$i"
                    continue
                }
                H=`echo $GEO | awk -F "x" ' { print $2 } '`
                # Remove if height not greater than 750
                [ "$H" ] && [ $H -gt 750 ] || {
                    rm -f "$i"
                    continue
                }
                # Remove if width not greater than height
                [ "$W" ] && [ "$H" ] && [ $W -gt $H ] || rm -f "$i"
            done
        }
    }
}

listem() {
    echo -e "\nPre-Created Wallpaper folders available for $WBCK :\n"
    ls --color=auto $BACK
    current
}

mkbgdir() {
    [ -d $BACK ] || {
        echo "$BACK does not exist or is not a directory. Exiting."
        exit 1
    }
    cd $BACK
    sub="$1"
    [ -d $sub ] || {
        mkdir $sub
        cd $sub
        if [ -d $WDIR/$sub ]
        then
            linkem $WDIR/$sub
        else
            if [ -d $WDIR/Models/$sub ]
            then
                linkem $WDIR/Models/$sub
            else
                if [ -d $WDIR/Photographers/$sub ]
                then
                    linkem $WDIR/Photographers/$sub
                else
                    echo "No $WDIR subfolder found for $sub. Exiting"
                    exit 1
                fi
            fi
        fi
        cd $HERE
    }
}

HERE=`pwd`
BGDIR=`grep imageDirectory: $CONF | awk ' { print $2 } '`
ODUR=`grep glslideshow $CONF | awk -F ":" ' { print $2 } ' | awk ' { print $4 } '`
MODE=`grep mode: $CONF | awk ' { print $2 } '`

# No arguments we take to mean activate the screensaver
[ "$1" ] || {
    xscreensaver-command -activate > /dev/null
    exit 0
}

BDIR=
COMM=
SECS=
LIST=
TELL=
REST=
USAGE=
dir_arg=
com_arg=
dom_arg=
fem_arg=
pby_arg=
art_arg=
saf_arg=
switch=0
rmportrait=1

while getopts B:D:F:H:I:P:W:X:b:c:t:adflnprsxu flag; do
    case $flag in
        B)
            BGNDS="$OPTARG"
            ;;
        I)
            ITOP="$OPTARG"
            ;;
        D)
            DBACK="$OPTARG"
            ;;
        F)
            FBACK="$OPTARG"
            ;;
        H)
            PICDIR="$OPTARG"
            ;;
        P)
            PBACK="$OPTARG"
            ;;
        S)
            SBACK="$OPTARG"
            ;;
        W)
            WBACK="$OPTARG"
            ;;
        X)
            XBACK="$OPTARG"
            ;;
        a)
            rmportrait=
            ;;
        b)
            dir_arg="$OPTARG"
            ;;
        c)
            com_arg="$OPTARG"
            ;;
        d)
            WDIR="$DMAI"
            WBCK="$DBACK"
            BACK="$PICDIR/$BGNDS/$WBCK"
            dom_arg=1
            switch=`expr $switch + 1`
            ;;
        f)
            WDIR="$FMJY"
            WBCK="$FBACK"
            BACK="$PICDIR/$BGNDS/$WBCK"
            fem_arg=1
            switch=`expr $switch + 1`
            ;;
        l)
            LIST=1
            ;;
        n)
            TELL=1
            ;;
        p)
            WDIR="$PLBY"
            WBCK="$PBACK"
            BACK="$PICDIR/$BGNDS/$WBCK"
            pby_arg=1
            switch=`expr $switch + 1`
            ;;
        r)
            REST=1
            ;;
        s)
            WDIR="$SAFE"
            WBCK="$SBACK"
            BACK="$PICDIR/$BGNDS/$WBCK"
            saf_arg=1
            switch=`expr $switch + 1`
            ;;
        t)
            SECS="$OPTARG"
            ;;
        x)
            WDIR="$XART"
            WBCK="$XBACK"
            BACK="$PICDIR/$BGNDS/$WBCK"
            art_arg=1
            switch=`expr $switch + 1`
            ;;
        u)
            USAGE=1
            ;;
    esac
done
shift $(( OPTIND - 1 ))

# Only one of -f, -s, and -x can be specified
[ $switch -gt 1 ] && {
    echo "Command line options -d,-f,-p,-s, and -x are mutually exclusive. Use only one or none."
    echo "Exiting."
    exit 1
}

# Reset these just in case they were specified on the command line
WHVN="$ITOP/$WBACK"
DMAI="$ITOP/$DBACK"
FMJY="$ITOP/$FBACK"
PLBY="$ITOP/$PBACK"
SAFE="$ITOP/$SBACK"
XART="$ITOP/$XBACK"
if [ "$fem_arg" ]
then
    WDIR="$FMJY"
    WBCK="$FBACK"
else
    if [ "$art_arg" ]
    then
        WDIR="$XART"
        WBCK="$XBACK"
    else
        if [ "$saf_arg" ]
        then
            WDIR="$SAFE"
            WBCK="$SBACK"
        else
            if [ "$dom_arg" ]
            then
                WDIR="$DMAI"
                WBCK="$DBACK"
            else
                if [ "$pby_arg" ]
                then
                    WDIR="$PLBY"
                    WBCK="$PBACK"
                else
                    WDIR="$WHVN"
                    WBCK="$WBACK"
                fi
            fi
        fi
    fi
fi
BACK="$PICDIR/$BGNDS/$WBCK"

[ "$USAGE" ] && usage
[ "$LIST" ] && listem

[ "$dir_arg" ] && {
    case "$dir_arg" in
        alisa|alisa_i|Alisa_I|Alisa) BDIR="Alisa_I"
               ;;
        all|All) BDIR="All"
               ;;
        anime|Anime) BDIR="Anime"
               ;;
        carisha|Carisha) BDIR="Carisha"
               ;;
        corinna|Corinna) BDIR="Corinna"
               ;;
        favs|Favs) BDIR="Favs"
               ;;
        femjoy|Femjoy) BDIR="All"
               ;;
        fractals|Fractals) BDIR="Fractals"
               ;;
        hentai|Hentai) BDIR="Hentai"
               ;;
        jasmine*|Jasmine*) BDIR="Jasmine_A"
               ;;
        li_moon|Li_Moon|li|Li) BDIR="Li_Moon"
               ;;
        mila_a|Mila_A) BDIR="Mila_A"
               ;;
        mila_k|Mila_K) BDIR="Mila_K"
               ;;
        milla|Milla) BDIR="Milla"
               ;;
        mila|Mila)
               if [ "$WBCK" == "$XBACK" ]
               then
                   BDIR="Mila_K"
               else
                   BDIR="Mila_A"
               fi
               ;;
        natalia_andreeva|Natalia_Andreeva) BDIR="Natalia_Andreeva"
               ;;
        owls|Owls) BDIR="Owls"
               ;;
        russian*|Russian*) BDIR="Russian_women"
               ;;
        safe|Safe) BDIR="Fractals"
               ;;
        safin|Safin|Marat*|marat*) BDIR="Marat_Safin"
               ;;
        saki|sakimichan|Sakimichan|Saki) BDIR="Sakimichan"
               ;;
        soell|Soell) BDIR="Stefan_Soell"
               ;;
        sybil*|Sybil*)
               if [ "$WBCK" == "$XBACK" ]
               then
                   BDIR="Sybil"
               else
                   BDIR="Sybil_A"
               fi
               ;;
        tui|tuigirl|Tui|Tuigirl) BDIR="Tuigirl"
               ;;
        vlad|vladimir|Vlad|Vladimir|*Nikolaev) BDIR="Vladimir_Nikolaev"
               ;;
        waterfalls|Waterfalls) BDIR="Waterfalls"
               ;;
        xart|Xart|x-art|X-Art) BDIR="All"
               ;;
        *) BDIR="$dir_arg"
               ;;
    esac
}

[ "$com_arg" ] && {
    case "$com_arg" in
        activate|deactivate|demo|exit|lock|restart) COMM="$com_arg"
            ;;
        blank|noslides)
            if [ "$TELL" ]
            then
                echo "cat $CONF | sed -e s/mode:\t\tone/mode:\t\tblank/ > /tmp/xscr$$"
                echo "cp /tmp/xscr$$ $CONF"
                echo "rm -f /tmp/xscr$$"
            else
                cat $CONF | sed -e "s/mode:\t\tone/mode:\t\tblank/" > /tmp/xscr$$
                cp /tmp/xscr$$ $CONF
                rm -f /tmp/xscr$$
            fi
            ;;
        one|noblank|slides)
            if [ "$TELL" ]
            then
                echo "cat $CONF | sed -e s/mode:\t\tblank/mode:\t\tone/ > /tmp/xscr$$"
                echo "cp /tmp/xscr$$ $CONF"
                echo "rm -f /tmp/xscr$$"
            else
                cat $CONF | sed -e "s/mode:\t\tblank/mode:\t\tone/" > /tmp/xscr$$
                cp /tmp/xscr$$ $CONF
                rm -f /tmp/xscr$$
            fi
            ;;
        start)
            if [ "$TELL" ]
            then
                echo "xscreensaver &"
            else
                xscreensaver &
            fi
            ;;
        *)  echo "Unrecognized xscreensaver-command $com_arg - exiting"
            exit 1
            ;;
    esac
}

[ "$BDIR" ] && {
  [ -d "$PICDIR/$BGNDS/$WBCK/$BDIR" ] || mkbgdir $BDIR
  [ "$PICDIR/$BGNDS/$WBCK/$BDIR" == "$BGDIR" ] || {
    ODIR=`basename $BGDIR`
    T_OWBK=`dirname $BGDIR`
    OWBK=`basename $T_OWBK`
    if [ "$TELL" ]
    then
        echo "cat $CONF | sed -e s/$BGNDS\/$OWBK\/$ODIR/$BGNDS\/$WBCK\/$BDIR/ > /tmp/xscr$$"
        echo "cp /tmp/xscr$$ $CONF"
        echo "rm -f /tmp/xscr$$"
    else
        cat $CONF | sed -e "s/$BGNDS\/$OWBK\/$ODIR/$BGNDS\/$WBCK\/$BDIR/" > /tmp/xscr$$
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
        [ "$REST" ] && {
          echo -e "\nxscreensaver-command -exit > /dev/null"
          echo "xscreensaver &"
        }
        echo -e "\nxscreensaver-command -$COMM > /dev/null"
    else
        [ "$REST" ] && {
          xscreensaver-command -exit > /dev/null
          xscreensaver &
        }
        xscreensaver-command -$COMM > /dev/null
    fi
}
