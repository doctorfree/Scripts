#!/bin/bash

# ProfitTrailer install folder
PT_DIR=/usr/local/lib/ProfitTrailer
TRAD_DIR=${PT_DIR}/initialization
BACK_DIR=${PT_DIR}/backup
#STRG="emacross smacross emagain emaspread lowbb moderate pioneers yuval"
STRG="cryptognome"
LOG=ProfitTrailer.log
P="PAIRS.properties"
MKTS="BTC ETH"
MKT=
DEM=

usage() {
  echo ""
  echo "Usage: pt [-d] <strategy> <market> where <strategy> must be one of"
  echo "    $STRG"
  echo "and <market> must be ETH or BTC"
  echo ""
  echo "or"
  echo "   pt [status|start|stop|restart|restore|delete]"
  echo "or"
  echo "   pt [disp|display|list|show|monit|tail]"
  echo ""
  pt_disp
  echo ""
  exit 1
}

tailit() {
    inst=`type -p grcat`
    if [ "$inst" ]
    then
        tail -n 25 -f ${PT_DIR}/logs/${LOG} | grcat conf.profittrailer
    else
        tail -n 25 -f ${PT_DIR}/logs/${LOG}
    fi
}

chk_market() {
  match=
  for mrkt in ${MKTS}
  do
    [ "$MKT" == "$mrkt" ] && match=1
  done
  [ "$match" ] || {
    echo "Unsupported market $MKT specified. Exiting."
    usage
  }
}

# Default market is installed market, if any
get_market() {
  # Which market are we using?
  pairs="${TRAD_DIR}/$P"
  MKT=`grep ^market ${pairs} | awk -F "=" ' { print $2 } '`
  MKT=`echo $MKT | sed -e "s/ //g"`
  echo "Installed market = $MKT"
}

# Restore saved PT data
pt_restore() {
  latest=`ls -t ${BACK_DIR}/ProfitTrailerData*.backup | head -n1`
  backup=`ls -t ${BACK_DIR}/ProfitTrailerData*.backup | head -n2 | tail -n1`
  [ -s $latest ] || {
    latest=`ls -t ${BACK_DIR}/ProfitTrailerData*.backup | head -n2 | tail -n1`
    backup=`ls -t ${BACK_DIR}/ProfitTrailerData*.backup | head -n3 | tail -n1`
  }
  if [ "$DEM" ]
  then
    echo "cp $latest $PT_DIR/ProfitTrailerData.json"
    echo "cp $backup $PT_DIR/ProfitTrailerData.json.backup"
  else
    cp $latest $PT_DIR/ProfitTrailerData.json
    cp $backup $PT_DIR/ProfitTrailerData.json.backup
  fi
}

[ "$1" == "-d" ] && {
    DEM="-d"
    echo "DEMO MODE: No changes will be made"
    shift
}

[ $# -eq 0 ] && usage
[ $# -eq 1 ] && get_market
[ "$2" ] && {
    case "$2" in
        ETH|BTC)
            MKT="$2"
            ;;
        btc)
            MKT="BTC"
            ;;
        eth)
            MKT="ETH"
            ;;
        *)
            pt_disp
            pt help
            exit 1
            ;;
    esac
}

[ -d ${PT_DIR} ] || {
    echo "${PT_DIR} does not exist or is not a directory. Exiting."
    exit 1
}

cd ${PT_DIR}

case "$1" in
    help|usage)
        usage
        ;;
    cryptognome|default|emacross|smacross|emagain|emaspread|lowbb|moderate|pioneers|yuval)
        chk_market
        pm2 stop ${PT_DIR}/pm2-ProfitTrailer.json
        pt_switch ${DEM} $1 ${MKT}
        pm2 start ${PT_DIR}/pm2-ProfitTrailer.json
        ;;
    disp|display)
        pt_disp
        ;;
    list)
        pt_disp -q
        pm2 $1
        ;;
    status)
        pt_disp -q
        pm2 $1 ${PT_DIR}/pm2-ProfitTrailer.json
        ;;
    start|restart|delete)
        pt_disp -q
        pm2 $1 ${PT_DIR}/pm2-ProfitTrailer.json
        pm2 $1 ${PT_DIR}/pm2-PTMagic.json
        pm2 $1 ${PT_DIR}/pm2-PTM-Monitor.json
        ;;
    stop)
        pt_disp -q
        pm2 $1 ${PT_DIR}/pm2-PTM-Monitor.json
        pm2 $1 ${PT_DIR}/pm2-PTMagic.json
        pm2 $1 ${PT_DIR}/pm2-ProfitTrailer.json
        ;;
    restore)
        pt_restore
        ;;
    show|monit)
        pm2 $1 profit-trailer-binance
        ;;
    tail)
        tailit
        ;;
    *)
        pt_disp
        pt help
        exit 1
        ;;
esac
exit 0

