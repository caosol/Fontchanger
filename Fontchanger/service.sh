#!/data/adb/modules/Fontchanger/bash
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
[ -f $PWD/${0##*/} ] && MODPATH=$PWD || MODPATH=${0%/*}

get_file_value() {
  if [ -f "$1" ]; then
    grep $2 $1 | sed "s|.*${2}||" | sed 's|\"||g'
  fi
} 

MODID=Fontchanger
MAGISK_VER_CODE="$(echo $(get_file_value /data/adb/magisk/util_functions.sh MAGISK_VER_CODE) | sed 's|-.*||')"
FCDIR=/storage/emulated/0/Fontchanger
TMPLOGLOC=$FCDIR/logs

# log
mkdir -p /sbin/.$MODID/$MODID
mkdir -p $TMPLOGLOC
touch $TMPLOGLOC/${MODID}-service.log
exec 2>$TMPLOGLOC/${MODID}-service.log
set -x 2>&1 >/dev/null
#if ! mount -o remount,rw /sbin 2>/dev/null; then
#  cp -a /sbin /dev/.sbin
#  mount -o bind,rw /dev/.sbin /sbin
#fi

ln -fs /sbin/.$MODID/$MODID/font_changer.sh /sbin/font_changer
ln -fs /sbin/.$MODID/$MODID/${MODID}-functions.sh /sbin/${MODID}-functions

# fix termux's PATH
termuxSu=/data/data/com.termux/files/usr/bin/su
if [ -f $termuxSu ] && grep -q 'PATH=.*/sbin/su' $termuxSu; then
  sed '\|PATH=|s|/sbin/su|/sbin|' $termuxSu > $termuxSu.tmp
  cat $termuxSu.tmp > $termuxSu
  rm $termuxSu.tmp
fi

set +x
exit