mkdir -p /storage/emulated/0/Fontchanger/logs
#mkdir -p /sbin/.$MODID/logs
exec 2>/storage/emulated/0/Fontchanger/logs/Fontchanger-install-verbose.log
set -x
set -euo pipefail
trap 'exxit $?' EXIT
unzip -o "$ZIPFILE" 'module.prop' -d $MODPATH 2>&1
SKIPUNZIP=1
WGET="/data/adb/magisk/busybox wget"
ui_print " - Downloading Installer Script"
$WGET -O $TMPDIR/installer.sh https://github.com/johnfawkes/fontchanger-scripts/raw/master/installer.sh 2>/dev/null
. $TMPDIR/installer.sh
