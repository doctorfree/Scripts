#!/bin/bash
#
## @file updflash.sh
## @brief Update flash drive backup storage
## @remark Archive of my movies, pictures, documents, source, etc.
## @author Ronald Joe Record (rr at ronrecord dot com)
## @copyright Copyright (c) 2014, Ronald Joe Record, all rights reserved.
## @date Written 28-Mar-2014
## @version 1.0.1
##
## Note: This script is dependent on my "upd" and "chk" scripts
#
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
# Modify the following default locations to suit your needs.
# This script invokes the upd script. You may also wish to customize
# the default locations in the upd script.
#
########### DEFAULT LOCATIONS ######################
[ "${MEDROOT}" ] || MEDROOT=/u
[ "${PICROOT}" ] || PICROOT=/u/pictures
[ "${VIDROOT}" ] || VIDROOT=/u/movies
[ "${AUDROOT}" ] || AUDROOT=/Audio
[ "${PHOROOT}" ] || PHOROOT=/Photos
[ "${ITUROOT}" ] || ITUROOT=/iTunes
[ "${MNTROOT}" ] || {
    USER=`id -u -n`
    MNTROOT=/media/${USER}
}
# The mount point for the flash drive
TRAN_DIR=${MNTROOT}/Transcend
# A directory that we know exists there
TEST_DIR="$TRAN_DIR"
# My iTunes library
ITUNES="${ITUROOT}"
# My Photos libraries
APLIBS="${PHOROOT}/Libraries"
APLIBS_DEST="$TRAN_DIR/Pictures/Libraries"
# Where I store my photos
PIC_DIR="$PICROOT"
# Picture directories to sync
PIC_SUB_DIRS="Art Dragonflies ScreenSavers Work"
# Where I store my audio
AUD_DIR="$AUDROOT"
# Audio directories to sync
AUD_SUB_DIRS="Audacity"
# Where I store my movies
MOV_DIR="$VIDROOT"
HOM_MOV_DIR="$HOME/Videos"
# Movies directories to sync
MOV_SUB_DIRS="Artists Work"
# Directories in my Home directory that I want to backup
HOME_DIRS="Box* Dropbox Horizon Documents Movies Music Pictures bin src"
########### END DEFAULT LOCATIONS ######################

## @fn usage()
## @brief Display command line usage options
## @param none
##
## Exit the program after displaying the usage message and example invocations
usage() {
    printf "Usage: $0 [-n] [-a] [-c] [-e] [-i] [-APl] [-p] [-mM] [-hH] [-u]\n"
    printf "Where:\n\t-n indicates to tell me what you would do\n"
    printf "\t-u indicates display this usage message and exit\n"
    printf "\t-a indicates rsync the Audio directory\n"
    printf "\t-c indicates check if rsync is needed before sync'ing\n"
    printf "\t-e indicates ignore rsync errors\n"
    printf "\t-i indicates rsync the iTunes library\n"
    printf "\t-A indicates rsync the Aperture libraries\n"
    printf "\t-P indicates rsync the Apple Photos libraries\n"
    printf "\t-L indicates follow symbolic links\n"
    printf "\t-l indicates rsync both Aperture and Photos libraries\n"
    printf "\t-p indicates rsync the Pictures directory\n"
    printf "\t-m indicates rsync the Movies directory\n"
    printf "\t-M indicates rsync the Home Movies directory\n"
    printf "\t-h indicates rsync the Home directory\n"
    printf "\t-H indicates rsync the entire Home directory\n\n"
    printf "When invoked with no arguments all directories will be sync'd.\n\n"
    exit 1
}

# Follow symbolic links
FLW=
# Do not ignore errors
IGN=
# Default to non-dry run
DRY=
# Exclude the specified file or directory
EXCLUDE=
# Default to no check
CHK=
# If no arguments or the only argument is -n then rsync all dirs
DO_ALL=
if [ $# -eq 0 ]
then
    DO_ALL=1
else
    if [ $# -eq 1 ]
    then
        if [ "$1" = "-n" ]
        then
            DO_ALL=1
        fi
    fi
fi
if [ "$DO_ALL" ]
then
    DO_APERT=1
    DO_PHOTO=1
    DO_ITUNES=1
    DO_PIC=1
    DO_MOV=1
    DO_HOM_MOV=1
    DO_AUD=1
    DO_ALL_HOME=1
    DO_HOME=
else
    DO_APERT=
    DO_PHOTO=
    DO_ITUNES=
    DO_PIC=
    DO_MOV=
    DO_HOM_MOV=
    DO_AUD=
    DO_ALL_HOME=
    DO_HOME=
fi
while getopts acE:eiAPlLpmMhHnu flag; do
    case $flag in
        a)
            DO_AUD=1
            ;;
        c)
            CHK=1
            ;;
        E)
            EXCLUDE="-E $OPTARG"
            ;;
        e)
            IGN="-e"
            ;;
        i)
            DO_ITUNES=1
            ;;
        A)
            DO_APERT=1
            ;;
        P)
            DO_PHOTO=1
            ;;
        L)
            FLW="-l"
            ;;
        l)
            DO_APERT=1
            DO_PHOTO=1
            ;;
        p)
            DO_PIC=1
            ;;
        M)
            DO_HOM_MOV=1
            ;;
        m)
            DO_MOV=1
            ;;
        H)
            DO_ALL_HOME=1
            ;;
        h)
            DO_HOME=1
            ;;
        n)
            DRY="-n"
            ;;
        u)
            usage
            ;;
    esac
done
shift $(( OPTIND - 1 ))
IGN="$IGN $EXCLUDE"

# Check if the flash drive is mounted in its proper location
[ -d "$TEST_DIR" ] || {
    # Sometimes we gotta wake it up
    ls "$TEST_DIR" > /dev/null 2>&1
    sleep 2
    [ -d "$TEST_DIR" ] || {
        echo "$TRAN_DIR does not seem to be mounted. Exiting."
        exit 1
    }
}

[ "$DO_APERT" ] && {
    # Update the backup of my Aperture libraries
    if [ -d "$APLIBS" ]
    then
        if [ "$CHK" ]
        then
            chk $IGN $DRY -r -a "$APLIBS" -s ".aplibrary" -t "$APLIBS_DEST"
        else
            # Equivalent of "upd -L ..."
            upd $IGN $DRY $FLW -a "$APLIBS" -s ".aplibrary" -t "$APLIBS_DEST"
        fi
    else
        echo "$APLIBS does not exist or is not a directory. Skipping."
    fi
}

[ "$DO_PHOTO" ] && {
    # Update the backup of my Apple Photos libraries
    if [ -d "$APLIBS" ]
    then
        if [ "$CHK" ]
        then
            chk $IGN $DRY -r -a "$APLIBS" -s ".photoslibrary" -t "$APLIBS_DEST"
        else
            # Equivalent of "upd -L ..."
            upd $IGN $DRY $FLW -a "$APLIBS" -s ".photoslibrary" -t "$APLIBS_DEST"
        fi
    else
        echo "$APLIBS does not exist or is not a directory. Skipping."
    fi
}

[ "$DO_ITUNES" ] && {
    # Update the backup of my iTunes library
    if [ -d "$ITUNES" ]
    then
        if [ "$CHK" ]
        then
            chk $IGN $DRY -r -a "$MEDROOT" -t "$TRAN_DIR" iTunes
        else
            # Equivalent of "upd -I ..."
            upd $IGN $DRY $FLW -a "$MEDROOT" -t "$TRAN_DIR" iTunes
        fi
    else
        echo "$ITUNES does not exist or is not a directory. Skipping."
    fi
 }

[ "$DO_PIC" ] && {
    # Sync the photo dirs
    for i in $PIC_SUB_DIRS
    do
        if [ -d "$PIC_DIR/$i" ]
        then
            if [ "$CHK" ]
            then
                chk $IGN $DRY -r -a "$PIC_DIR" -t "$TRAN_DIR/Pictures" "$i"
            else
                # Equivalent of "upd -P ..."
                upd $IGN $DRY $FLW -a "$PIC_DIR" -t "$TRAN_DIR/Pictures" "$i"
            fi
        else
            echo "$PIC_DIR/$i does not exist or is not a directory. Skipping."
        fi
    done
 }

[ "$DO_AUD" ] && {
    # Sync the audio directories
    for i in $AUD_SUB_DIRS
    do
        if [ -d "$AUD_DIR/$i" ]
        then
            if [ "$CHK" ]
            then
                chk $IGN $DRY -r -a "$AUD_DIR" -t "$TRAN_DIR/Audio" "$i"
            else
                # Equivalent of "upd -A ..."
                upd $IGN $DRY $FLW -a "$AUD_DIR" -t "$TRAN_DIR/Audio" "$i"
            fi
        else
            echo "$AUD_DIR/$i does not exist or is not a directory. Skipping."
        fi
    done
}

[ "$DO_MOV" ] && {
    # Sync the movies directories
    for i in $MOV_SUB_DIRS
    do
        if [ -d "$MOV_DIR/$i" ]
        then
            if [ "$CHK" ]
            then
                chk $IGN $DRY -r -a "$MOV_DIR" -t "$TRAN_DIR/Movies" "$i"
            else
                # Equivalent of "upd -M ..."
                upd $IGN $DRY $FLW -a "$MOV_DIR" -t "$TRAN_DIR/Movies" "$i"
            fi
        else
            echo "$MOV_DIR/$i does not exist or is not a directory. Skipping."
        fi
    done
}

[ "$DO_HOM_MOV" ] && {
    # Sync the home movies directories
    if [ -d "$HOM_MOV_DIR" ]
    then
        if [ "$CHK" ]
        then
            chk $IGN $DRY -r -a "$HOM_MOV_DIR" -t "$TRAN_DIR/Movies" .
        else
            # Equivalent of "upd -M ..."
            upd $IGN $DRY $FLW -a "$HOM_MOV_DIR" -t "$TRAN_DIR/Movies" .
        fi
    else
        echo "$HOM_MOV_DIR does not exist or is not a directory. Skipping."
    fi
}

[ "$DO_HOME" ] && {
    # Sync some of the directories in my home directory
    for dir in $HOME_DIRS
    do
        if [ -d "$HOME/$dir" ]
        then
            if [ "$CHK" ]
            then
                chk $IGN $DRY -r -a "$HOME" -t "$TRAN_DIR/Home" "$dir"
            else
                # Equivalent of "upd -H ..."
                upd $IGN $DRY $FLW -a "$HOME" -t "$TRAN_DIR/Home" "$dir"
            fi
        else
            echo "$HOME/$dir does not exist or is not a directory. Skipping."
        fi
    done
}

[ "$DO_ALL_HOME" ] && {
    # Sync my entire home directory
    if [ -d "$HOME" ]
    then
        if [ "$CHK" ]
        then
            chk $IGN $DRY -r -a "${HOME}/" -t "$TRAN_DIR/Home"
        else
            # Equivalent of "upd -H ..."
            upd $IGN $DRY $FLW -a "$HOME" -t "$TRAN_DIR/Home"
        fi
    else
        echo "$HOME does not exist or is not a directory. Skipping."
    fi
}
