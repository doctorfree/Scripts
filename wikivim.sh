#!/bin/bash
#
## @file wikivim.sh
## @brief Used with "It's All Text" Firefox Add-On to edit Wikipedia with Vim
## @remark On OS X use AppleScript and iTerm 2, on other OS use shell and xterm
## @author Ronald Joe Record (rr at ronrecord dot com)
## @copyright Copyright (c) 2016, Ronald Joe Record, all rights reserved.
## @date Written 04-Jul-2015
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
# Why doesn't this work:
#               activate mySession
#               set mySessionName to name of mySession
#               if useCurrent then
#                   repeat with thisSession in sessions of myTerminal
#                       set thisName to name of thisSession
#                       if thisName is not equal to mySessionName then
#                           terminate thisSession
#                       end if
#                   end repeat
#               end if

: ${VISUAL='vi'}
arg="\\\"${1+"$@"}\\\""
app="iTerm 2"

if [ `uname -s` != "Darwin" ]
then
    exec /usr/X11/bin/xterm -fg cyan -bg black -bw 2 -bd cyan \
                            -fn lucidasanstypewriter-18 -e $VISUAL ${1+"$@"}
else
    osascript &>/dev/null <<EOF
        if application "$app" is running then
            set useCurrent to false
        else
            set useCurrent to true
        end if
        set cmd to "$VISUAL ${arg}"
        tell application "$app"
            activate
            if (count of terminals) = 0 then
                set myTerminal to (make new terminal)
            else
                set myTerminal to current terminal
            end if
            tell myTerminal
                if useCurrent then
                    if (count of sessions) = 0 then
                        set cmdSess to (make new session at the end of sessions)
                    else
                        set cmdSess to first session
                    end if
                else
                    set cmdSess to (make new session at the end of sessions)
                end if
                activate cmdSess
                tell cmdSess
                    exec command cmd
                end tell
            end tell
        end tell
EOF
fi
