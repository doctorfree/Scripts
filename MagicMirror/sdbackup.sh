#!/bin/bash

NUMBACK=`date "+%Y%m%d"`
OUT_DIR="/Volumes/Seagate_8TB/Raspberry_Pi/Backups"
OUT_FILE="Raspbian-MagicMirror-${NUMBACK}.iso"
DEVNAM="disk5"
ZIP=

[ "$1" == "-z" ] && {
    ZIP=1
    shift
}
[ "$1" ] && DEVNAM="$1"
DEVICE="/dev/r${DEVNAM}"

FOUND=`diskutil list | grep Windows_FAT_32 | awk ' { print $6 } ' | cut -c 1-5`

[ "${FOUND}" == "${DEVNAM}" ] || {
    echo "Discovered SD card on ${FOUND} does not match configured device ${DEVNAM}"
    echo "Use 'diskutil list' or Disk Utility to verify correct device node"
    echo "Exiting"
    exit 1
}

[ -d "${OUT_DIR}" ] || mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}"
if [ "${ZIP}" ]
then
    sudo dd if=${DEVICE} | zip ${OUT_FILE}.zip -
else
    sudo dd if=${DEVICE} of=${OUT_FILE}
fi
