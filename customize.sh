remove_zips() {
for i in $FCDIR/Fonts/*.zip; do
  rm -f $i
done
for i in $FCDIR/Fonts/*/*.zip; do
  rm -rf $i
done

for i in $FCDIR/Emojis/*.zip; do
  rm -f $i
done
for i in $FCDIR/Emojis/*/*.zip; do
  rm -rf $i
done
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/curl 0 0 0755
  set_perm $MODPATH/sleep 0 0 0755
  set_perm $MODPATH/zip 0 0 0755
  set_perm $MODPATH/bash 0 0 0755
  if [ -e $MODPATH/busybox ]; then
    set_perm $MODPATH/busybox 0 0 0755
  fi

  for file in $MODPATH/*.sh; do
    [ -f $file ] && set_perm $file  0  0  0700
  done

  ui_print " "
  ui_print " [-] After Installing type su then hit enter and type font_changer in terminal [-] "
  ui_print " [-] Then Choose Option 4 to Read the How-to on How to Set up your Custom Fonts [-] "
  sleep 3
  set +x
}

exxit() {
  set +euxo pipefail
  [ $1 -ne 0 ] && abort "$2"
  exit $1
} 

test_connection() {
  ui_print " [-] Testing internet connection [-] "
  $TMPDIR/busybox-$ARCH32 ping -q -c 1 -W 1 google.com >/dev/null 2>&1 && ui_print " [-] Internet Detected [-] "; CON1=true; CON2=false; CON3=false || { exxit " [-] Error, No Internet Connection [-] "; CON=false; CON2=false; CON3=false; }
}

test_connection2() {
  case "$($TMPDIR/curl-$ARCH32 -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) ui_print " [-] HTTP connectivity is up [-] "
    CON1=false
    CON2=true
    CON3=false
    ;;
  5) ui_print " [!] The web proxy won't let us through [!] "
    CON1=false
    CON2=false
    CON3=false
    ;;
  *) ui_print " [!] The network is down or very slow [!] "
    CON1=false
    CON2=false
    CON3=false
    ;;
esac
}

test_connection3() {
  $TMPDIR/busybox-$ARCH32 wget -q --tries=5 --timeout=10 http://www.google.com -O $TMPDIR/google.idx >/dev/null 2>&1
if [ ! -s $TMPDIR/google.idx ]; then
  ui_print " [!] Not Connected... [!] "
  CON1=false
  CON2=false
  CON3=false
else
  ui_print " [-] Connected..! [-] "
  CON1=false
  CON2=false
  CON3=true
fi
rm -f $TMPDIR/google.idx
}

get_var() { sed -n 's/^name=//p' ${1}; }

set_vars() {
  MODTITLE="$(grep_prop name $MODPATH/module.prop)"
  VER=$(grep_prop version $MODPATH/module.prop)
  AUTHOR=$(grep_prop author $MODPATH/module.prop)
  MAGISK_VER="$(grep_prop MAGISK_VER_CODE /data/adb/magisk/util_functions.sh)"
  FCDIR=/storage/emulated/0/Fontchanger
  MOD_VER="/data/adb/modules/Fontchanger/module.prop"
}

version_changes() {
  ui_print " "
  ui_print "  LATEST CHANGES"
  ui_print " "
  NUM=$(grep -n "Changelog" $TMPDIR/README.md | sed -re "s|([[:digit:]]):.*|\1|")
  tail -n +$NUM $TMPDIR/README.md | sed -n '/^$/q;p'
  ui_print " " 
  ui_print "If you would like to donate to me you can do so by going to https://paypal.me/BBarber61"
  ui_print " "

  ui_print "  LINKS"
  ui_print "   - Git repository: github.com/Magisk-Modules-Repo/${MODID}/"
  ui_print "   - Telegram group: https://t.me/fontchange_magisk"
  ui_print "   - Telegram profile: t.me/johnfawkes/"
  set +euo pipefail
}

SKIPUNZIP=1
mkdir -p /storage/emulated/0/Fontchanger/logs
#mkdir -p /sbin/.$MODID/logs
exec 2>/storage/emulated/0/Fontchanger/logs/Fontchanger-install-verbose.log
set -x
set -euo pipefail
trap 'exxit $?' EXIT
unzip -o "$ZIPFILE" 'module.prop' -d $MODPATH 2>&1
set_vars
if $BOOTMODE; then
  ui_print "Checking for any other font modules installed... "
  MODULESPATH=/data/adb/modules || require_new_magisk
  for i in $MODULESPATH*; do
    if [[ $i != *Fontchanger ]]; then
      if [ ! -f $i/disable ]; then
        if [ -d $i/system/fonts ]; then
          NAME=$(get_var $i/module.prop)
          ui_print " [!] "
          ui_print " [!] Module editing fonts detected [!] "
          ui_print " [!] Module - $NAME [!] "
          ui_print " [!] "
          exxit
        fi
      fi
    fi
  done
  remove_zips
  if [ -d /data/adb/modules/Fontchanger/system ] || [ -d /data/adb/modules/Fontchanger/product ]; then
    ui_print "Backing Up Installed Fonts and/or Emojis"
    if [ -d /data/adb/modules/Fontchanger/system ]; then
      cp -rf /data/adb/modules/Fontchanger/system $MODPATH 2>&1
    fi
    if [ -d /data/adb/modules/Fontchanger/product ]; then
      cp -rf /data/adb/modules/Fontchanger/product $MODPATH 2>&1
    fi
    for i in /data/adb/modules/Fontchanger/*.txt; do
      if [ -e $i ]; then
        cp -f $i $MODPATH 2>&1
      fi
    done
    for k in /data/adb/modules/Fontchanger/*.log; do
      if [ -e $k ]; then
        cp -f $k  $MODPATH 2>&1
      fi
    done
    if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
      ui_print " [-] Backup and Restore Successful [-] "
    fi
  fi
  ui_print " [-] Extracting module files [-] "
  unzip -o "$ZIPFILE" "$MODID/*" -d ${MODPATH%/*}/ 2>&1
  unzip -o "$ZIPFILE" 'README.md' -d $TMPDIR 2>&1
  unzip -oj "$ZIPFILE" "tools/*" -d $TMPDIR 2>&1
  mkdir -p /storage/emulated/0/Fontchanger/Fonts/Custom 2>&1
  mkdir -p /storage/emulated/0/Fontchanger/Fonts/User 2>&1
  mkdir -p /storage/emulated/0/Fontchanger/Fonts/avfonts 2>&1
  mkdir -p /storage/emulated/0/Fontchanger/Emojis/Custom 2>&1
  chmod 0755 $TMPDIR/curl-$ARCH32
  chmod 0755 $TMPDIR/busybox-$ARCH32
  ui_print " [-] Checking For Internet Connection... [-] "
  test_connection3
  if ! "$CON3"; then
    test_connection2
    if ! "$CON2"; then
      test_connection
    fi
  fi
  if "$CON1" || "$CON2" || "$CON3"; then
    for i in /storage/emulated/0/Fontchanger/*-list.txt; do
      if [ -e $i ]; then
        rm $i 2>&1
      fi
    done
    $TMPDIR/curl-$ARCH32 -k -o /storage/emulated/0/Fontchanger/fonts-list.txt https://john-fawkes.com/Downloads/fontlist/fonts-list.txt
    $TMPDIR/curl-$ARCH32 -k -o /storage/emulated/0/Fontchanger/user-fonts-list.txt https://john-fawkes.com/Downloads/userfontlist/user-fonts-list.txt
    $TMPDIR/curl-$ARCH32 -k -o /storage/emulated/0/Fontchanger/emojis-list.txt https://john-fawkes.com/Downloads/emojilist/emojis-list.txt
    $TMPDIR/curl-$ARCH32 -k -o /storage/emulated/0/Fontchanger/avfonts-list.txt https://john-fawkes.com/Downloads/avfontlist/avfonts-list.txt
    if [ -f /storage/emulated/0/Fontchanger/fonts-list.txt ] && [ -f /storage/emulated/0/Fontchanger/emojis-list.txt ] && [ -f /storage/emulated/0/Fontchanger/user-fonts-list.txt ] && [ -f /storage/emulated/0/Fontchanger/avfonts-list.txt ]; then
      ui_print " [-] All Lists Downloaded Successfully... [-] "
    else
      ui_print " [!] Error Downloading Lists... [!] "
    fi
  else
    exxit " [!] No Internet Detected... [!] " 
  fi
else
  exxit " [-] TWRP Install NOT Supported. Please Install Booted with Internet Connection... [-] "
fi
cp -f $TMPDIR/curl-$ARCH32 $MODPATH/curl 2>&1
cp -f $TMPDIR/sleep-$ARCH32 $MODPATH/sleep 2>&1
cp -f $TMPDIR/zip-$ARCH32 $MODPATH/zip 2>&1
cp -f $TMPDIR/bash-$ARCH32 $MODPATH/bash 2>&1
if [ -d /data/adb/modules/busybox-ndk ]; then
  ui_print "Busybox Already Installed" 2>&1
else
  cp -f $TMPDIR/busybox-$ARCH32 $MODPATH/busybox 2>&1
fi
version_changes
set_permissions