#!/bin/bash
#
## @file femzip.sh
## @brief Convenience script to unzip Femjoy photo downloads
## @author Ronald Joe Record (rr at ronrecord dot com)
## @copyright Copyright (c) 2014, Ronald Joe Record, all rights reserved.
## @date Written 8-Aug-2013
## @version 1.0.1
##
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
[ "${PICROOT}" ] || PICROOT=/u/pictures

D=$HOME/Downloads

# ___MODIFY THESE THREE SETTINGS TO MATCH THE DOWNLOADED FILE(S)___
# Set the Photographer
P="Stefan Soell"
#P="Valery Anzilov"
#P="FEMJOY Exclusive"
#P="Peter Olssen"
#P="Vaillo"
#P="Iain"
#P="Alexandr Petek"

# Set the Model
M=CARISHA
#M=CORINNA
#M=KINGA
#M=MARYLIN
#M="HAYDEN W."
#M="ANGIE C."
#M="JENNIFER M."
#M="JASMINE A."
#M="JOSEPHINE"
#M="VIC E."

# Set the extraction base directory
B="${PICROOT}/Femjoy"

# Set the extraction subdirectory
S=""

########### END CONFIGURATION SECTION ##################

## @fn usage()
## @brief Display command line usage options
## @param none
##
## Exit the program after displaying the usage message and example invocations
usage() {
    printf "Usage: femzip [-m model] [-p photographer] [-b basedir] [-o subdir] [-r]\n"
    printf "Where:\n\tmodel is the model's name\n"
    printf "\tphotographer is the photographer's name\n"
    printf "\tbasedir is the destination base directory for unzipped files\n"
    printf "\tsubdir is the destination subdirectory for unzipped files\n"
    printf "\t-d indicates tell me what you would do without doing anything\n"
    printf "\t-r indicates removal of the zip file after extraction\n"
    printf "\t-u displays this usage message\n"
    printf "Current defaults are:\n\tPhotographer = $P\n"
    printf "\tModel = $M\n"
    printf "\tSubdir = $S\n"
    exit 1
}

ECHO=
R=
while getopts b:m:o:p:dru flag; do
    case $flag in
        b)
            B="$OPTARG";
            ;;
        d)
            ECHO=1;
            ;;
        m)
            M="$OPTARG";
            ;;
        o)
            S="$OPTARG";
            ;;
        p)
            P="$OPTARG";
            ;;
        r)
            R=1;
            ;;
        u)
            usage;
            ;;
        ?)
            usage;
            ;;
    esac
done
#shift $(( OPTIND - 1 ));

[ "$S" ] || {
    FIRST=`echo $M | awk '{ print $1 }'`
    LAST=`echo $M | awk '{ print $2 }'`
    MLOW=`echo $FIRST | tr '[:upper:]' '[:lower:]'`
    FIRST="$(tr '[:lower:]' '[:upper:]' <<< ${MLOW:0:1})${MLOW:1}"
    [ "$LAST" ] && LAST=`echo $LAST | sed -e "s/\.//g"`
    if [ "$LAST" ]
    then
        S="${FIRST}_${LAST}"
    else
        S="${FIRST}"
    fi
}

O="$B/$S"
[ -d "$O" ] || {
    if [ "$ECHO" ]
    then
        printf "mkdir $O\n"
    else
        mkdir "$O"
    fi
}
cd "$D"
for i in "$M"_"$P"_*.zip
do
    [ -f "$i" ] || {
        printf "$i is not a regular file. Skipping.\n"
        continue
    }
    T=`echo "$i" | sed -e "s/${M}_${P}_//" -e "s/_large.zip//"`
    N=`echo "$T" | sed -e "s/ /_/g"`
    [ -d "$O/$N" ] && {
        printf "$O/$N already exists. Skipping $i"
        continue
    }
    if [ "$ECHO" ]
    then
        printf "mkdir $O/$N\n"
    else
        mkdir "$O/$N"
    fi
    if [ "$ECHO" ]
    then
        printf "unzip -d $O/$N $i\n"
     else
        unzip -d "$O/$N" "$i"
     fi
    [ "$R" ] && {
        if [ "$ECHO" ]
        then
            printf "rm -f $i\n"
        else
            rm -f "$i"
        fi
    }
done
