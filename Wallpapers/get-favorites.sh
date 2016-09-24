#!/bin/bash
#
## @file get-favorites.sh
## @brief Download favorites from Wallhaven
## @author Ronald Joe Record (rr at ronrecord dot com)
## @copyright Copyright (c) 2016, Ronald Joe Record, all rights reserved.
## @date Written 17-Sep-2016
## @version 1.0.1
##

[ -r ./utils ] && . ./utils
[ "$WHDIR" ] || WHDIR="/Volumes/My_Book_Studio/Pictures/Work/Wallhaven"

DDIR="${WHDIR}/Favorites"

[ "$numdown" ] || numdown=480
[ "$categories" ] || categories=111
[ "$filters" ] || filters=111
[ "$page" ] || page=1

wh -l ${DDIR} \
   -n $numdown \
   -s $page \
   -t favorites \
   -c $categories \
   -f $filters \
   -p 0
