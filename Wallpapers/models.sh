#!/bin/bash

JDIR="/Volumes/Seagate_BPH_8TB/Pictures/Work/Wallhaven/JAV_Idol"
MDIR="/Volumes/Seagate_BPH_8TB/Pictures/Work/Wallhaven/Models"
PDIR="/Volumes/Seagate_BPH_8TB/Pictures/Work/Wallhaven/Photographers"
SDIR="/Volumes/Seagate_BPH_8TB/Pictures/Work/Wallhaven/Suicide_Girls"
TYPE="models"
ALL=
COUNT=

ListModels() {
    UTYPE=`echo $2 | tr '[:lower:]' '[:upper:]'`
    printf "\n${UTYPE} in $1:"
    for model in "$1/${models}"*
    do
        if [ "${model}" == "$1/${models}*" ]
        then
            printf "\n\tNo $2 matching \"${models}\""
        else
            name=`basename ${model}`
            printf "\n\t${name}"
            [ "$COUNT" ] && {
                cnt=`ls -1 "${model}" | wc -l`
                printf "\t\t${cnt}"
            }
        fi
    done
    printf "\n"
}

[ "$1" == "-a" ] && {
    ALL=1
    shift
}
[ "$1" == "-c" ] && {
    COUNT=1
    shift
}
[ "$1" == "-j" ] && {
    MDIR="${JDIR}"
    TYPE="jav_idols"
    shift
}
[ "$1" == "-p" ] && {
    MDIR="${PDIR}"
    TYPE="photographers"
    shift
}
[ "$1" == "-s" ] && {
    MDIR="${SDIR}"
    TYPE="suicide_girls"
    shift
}

[ $# -lt 1 ] && {
    echo "Usage: models [-ajps] model1 [model2] ..."
    echo "Exiting."
    exit 1
}

for models in $*
do
  if [ "$ALL" ]
  then
      ListModels $MDIR models
      ListModels $MDIR jav_idols
      ListModels $SDIR suicide_girls
      ListModels $PDIR photographers
  else
      ListModels $MDIR $TYPE
  fi
done
printf "\n"
exit 0