#!/system/bin/sh
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
# This script will be executed in post-fs-data mode

if [[ $PATH != *busybox:* ]]; then
  if [ -d /sbin/.magisk/busybox ]; then
    PATH=/sbin/.magisk/busybox:$PATH
  elif [ -d /sbin/.core/busybox ]; then
    PATH=/sbin/.core/busybox:$PATH
  elif which busybox > /dev/null; then
    mkdir -p -m 700 /dev/.busybox
    busybox install -s /dev/.busybox
    PATH=/dev/.busybox:$PATH
  else
    echo "(!) Install busybox binary first"
    exit 3
  fi
fi

#if [ -e $FCDIR/${MODID}_install.log ]; then
#  mv $FCDIR/${MODID}_install.log $MODPATH 2>/dev/null
#fi

#if ! mount -o remount,rw /sbin 2>/dev/null; then
#  cp -a /sbin /dev/.sbin
#  mount -o bind,rw /dev/.sbin /sbin
#fi
mkdir -p /sbin/.$MODID
[ -h /sbin/.$MODID/$MODID ] && rm -rf /sbin/.$MODID/$MODID 2>/dev/null \
  || rm -rf /sbin/.$MODID/$MODID 2>/dev/null
[ ${MAGISK_VER_CODE} -gt 18100 ] \
  && ln -s $MODPATH /sbin/.$MODID/$MODID \
  || cp -a $MODPATH /sbin/.$MODID/$MODID
#ln -fs $MODPATH /sbin/.$MODID/$MODID
ln -fs /sbin/.$MODID/$MODID/font_changer.sh /sbin/font_changer
ln -fs /sbin/.$MODID/$MODID/${MODID}-functions.sh /sbin/${MODID}-functions

# fix termux's PATH
termuxSu=/data/data/com.termux/files/usr/bin/su
if [ -f $termuxSu ] && grep -q 'PATH=.*/sbin/su' $termuxSu; then
  sed '\|PATH=|s|/sbin/su|/sbin|' $termuxSu > $termuxSu.tmp
  cat $termuxSu.tmp > $termuxSu
  rm $termuxSu.tmp
fi