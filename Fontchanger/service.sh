#!/system/bin/sh

# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future

get_file_value() {
  if [ -f "$1" ]; then
    grep $2 $1 | sed "s|.*${2}||" | sed 's|\"||g'
  fi
} 

MODID=Fontchanger
MODPATH=/data/adb/modules/$MODID

if [ -d /sbin/.$MODID/$MODID ]; then
  rm -rf /sbin/.$MODID/$MODID 2>&1
  mkdir -p /sbin/.$MODID 2>&1
else
  mkdir -p /sbin/.$MODID 2>&1
fi
#if [ ${MAGISK_VER_CODE} -gt 18100 ]; then
  ln -fs $MODPATH /sbin/.$MODID/$MODID
#else
#  cp -a $MODPATH /sbin/.$MODID/$MODID
#HMM fi
ln -fs /sbin/.$MODID/$MODID/font_changer.sh /sbin/font_changer
ln -fs /sbin/.$MODID/$MODID/${MODID}-functions.sh /sbin/${MODID}-functions

# fix termux's PATH
termuxSu=/data/data/com.termux/files/usr/bin/su
if [ -f $termuxSu ] && grep -q 'PATH=.*/sbin/su' $termuxSu; then
  sed '\|PATH=|s|/sbin/su|/sbin|' $termuxSu > $termuxSu.tmp
  cat $termuxSu.tmp > $termuxSu
  rm $termuxSu.tmp
fi

exit 0
