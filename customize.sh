mkdir -p /storage/emulated/0/Fontchanger/logs
#mkdir -p /sbin/.$MODID/logs
exec 2>/storage/emulated/0/Fontchanger/logs/Fontchanger-install-verbose.log
set -x
set -euo pipefail
trap 'exxit $?' EXIT
unzip -o "$ZIPFILE" 'module.prop' -d $MODPATH 2>&1
SKIPUNZIP=1

set_busybox() {
  if [ -x "$1" ]; then
    for i in $(${1} --list); do
      if [ "$i" != 'echo' ] || [ "$i" != 'zip' ] || [ "$1" != 'sleep' ]; then
        alias "$i"="${1} $i" >/dev/null 2>&1
      fi
    done
    _busybox=true
    _bb=$1
  fi
}
_busybox=false

if $_busybox; then
  true
elif [ -d /sbin/.magisk/modules/busybox-ndk ]; then
  BUSY=$(find /sbin/.magisk/modules/busybox-ndk/system/* -maxdepth 0 | sed 's#.*/##')
  for i in $BUSY; do
    PATH=/sbin/.magisk/modules/busybox-ndk/system/$i:$PATH
    _bb=/sbin/.magisk/modules/busybox-ndk/system/$i/busybox
    BBox=true
  done
elif [ -d /sbin/.magisk/modules/ccbins ]; then
  BIN=$(find /sbin/.magisk/modules/ccbins/system/* -maxdepth 0 | sed 's#.*/##')
  for i in $BIN; do
    PATH=/sbin/.magisk/modules/ccbins/system/$i:$PATH
    _bb=/sbin/.magisk/modules/ccbins/system/$i/busybox
    BBox=true
  done
elif [ -d /sbin/.magisk/busybox ]; then
  PATH=/sbin/.magisk/busybox:$PATH
  _bb=/sbin/.magisk/busybox/busybox
  BBox=true
fi

set_busybox $_bb
[ $? -ne 0 ] && exit $?
[ -n "$ANDROID_SOCKET_adbd" ] && alias clear='echo'
_bbname="$($_bb | head -n1 | awk '{print $1,$2}')"
if [ "$_bbname" == "" ]; then
  _bbname="BusyBox not found!"
  BBox=false
fi
ui_print " - Downloading Installer Script"
wget -O $TMPDIR/installer.sh https://github.com/johnfawkes/fontchanger-scripts/raw/master/installer.sh 2>/dev/null
. $TMPDIR/installer.sh
