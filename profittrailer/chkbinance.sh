#!/bin/bash
#
# chkbinance - Check ProfitTrailer config files for Binance to see if any
#              changes have been made.

INST_DIR=/usr/local/lib/ProfitTrailer
TOP="${HOME}/src/trading/profit-trailer/binance/installed"

[ -d ${TOP} ] || {
    echo "$TOP does not exist or is not a directory. Exiting."
    exit 1
}

cd ${TOP}
for i in *.properties *.json trading/*
do
    diff $i ${INST_DIR}/$i > /dev/null || echo "$i differs"
done
