#!/system/bin/sh
# Terminal Magisk Mod Template
# by veez21 @ xda-developers
# Modified by @JohnFawkes - Telegram
# Help from @Zackptg5
# Variables

OLDPATH=$PATH
MODID=Fontchanger
MODPATH=/data/adb/modules/$MODID
MODPROP=$MODPATH/module.prop
SDCARD=/storage/emulated/0
FCDIR=$SDCARD/Fontchanger
TMPLOG=FontChanger_logs.log
TMPLOGLOC=$FCDIR/FontChanger_logs
XZLOG=$FCDIR/Fontchanger_logs.tar.xz
if [ -d /cache ]; then CACHELOC=/cache; else CACHELOC=/data/cache; fi       
CFONT=$MODPATH/currentfont.txt
CEMOJI=$MODPATH/currentemoji.txt
MIRROR=/sbin/.magisk/mirror

alias curl=$MODPATH/curl
alias sleep=$MODPATH/sleep
alias xmlstarlet=$MODPATH/xmlstarlet

quit() {
  PATH=$OLDPATH
  exit $?
}

# Detect root
_name=$(basename $0)
ls /data >/dev/null 2>&1 || { echo "$MODID needs to run as root!"; echo "type 'su' then '$_name'"; quit 1; }

# Load magisk stuff
if [ -f /data/adb/magisk/util_functions.sh ]; then
  . /data/adb/magisk/util_functions.sh
elif [ -f /data/magisk/util_functions.sh ]; then
  . /data/magisk/util_functions.sh
else
  echo "! Can't find magisk util_functions! Aborting!"; exit 1
fi

# Load Needed Functions
if [ -f $MODPATH/${MODID}-functions.sh ]; then
  . $MODPATH/${MODID}-functions.sh
else
  echo "! Can't find functions script! Aborting!"; exit 1
fi

#=========================== Set Log Files
#mount -o remount,rw $CACHELOC 2>/dev/null
#mount -o rw,remount $CACHELOC 2>/dev/null
# > Logs should go in this file
LOG=$MODPATH/${MODID}.log
oldLOG=$MODPATH/${MODID}-old.log
# > Verbose output goes here
VERLOG=$MODPATH/${MODID}-verbose.log
oldVERLOG=$MODPATH/${MODID}-verbose-old.log

log_start

# Start Logging verbosely
mv -f $VERLOG $oldVERLOG 2>/dev/null
set -x 2>$VERLOG

# Set Busybox up
if [ "$(busybox 2>/dev/null)" ]; then
  BBox=true
elif [ -d /sbin/.core/busybox ]; then
  PATH=/sbin/.core/busybox:$PATH
 _bb=/sbin/.core/busybox/busybox
  BBox=true
elif [ -d /sbin/.magisk/busybox ]; then
  PATH=/sbin/.magisk/busybox:$PATH
  _bb=/sbin/.magisk/busybox/busybox
  BBox=true
elif [ -d /data/adb/magisk/busybox ]; then
  PATH=/data/adb/magisk/busybox:PATH
  _bb=/data/adb/magisk/busybox
  BBox=true
elif [ -d /data/magisk/busybox ]; then
  PATH=/data/magisk/busybox:PATH
  _bb=/data/magisk/busybox
  BBox=true
else
  BBox=false
  echo "! Busybox not detected" >> $LOG
  echo "Please install one (@osm0sis' busybox recommended)" >> $LOG
  for applet in cat chmod cp curl grep md5sum mv ping printf sed sleep sort tar tee tr unzip wget; do
    [ "$($applet)" ] || quit 1
  done
  echo "All required applets present, continuing" >> $LOG
fi

if [ -z "$(echo $PATH | grep /sbin:)" ]; then
 alias resetprop="/data/adb/magisk/magisk resetprop"
fi

# Log print
echo "Functions loaded." >> $LOG
if $BBox; then
  BBV=$(busybox | grep "BusyBox v" | sed 's|.*BusyBox ||' | sed 's| (.*||')
  echo "Using busybox: ${PATH} (${BBV})." >> $LOG
else
  echo "Using installed applets (not busybox)" >> $LOG
fi

# Functions
get_file_value() {
  if [ -f "$1" ]; then
    grep $2 $1 | sed "s|.*${2}||" | sed 's|\"||g'
  fi
} 

api_level_arch_detect() {
  API=$(grep_prop ro.build.version.sdk)
  ABI=$(grep_prop ro.product.cpu.abi | cut -c-3)
  ABI2=$(grep_prop ro.product.cpu.abi2 | cut -c-3)
  ABILONG=$(grep_prop ro.product.cpu.abi)
  ARCH=arm
  ARCH32=arm
  IS64BIT=false
  if [ "$ABI" = "x86" ]; then ARCH=x86; ARCH32=x86; fi;
  if [ "$ABI2" = "x86" ]; then ARCH=x86; ARCH32=x86; fi;
  if [ "$ABILONG" = "arm64-v8a" ]; then ARCH=arm64; ARCH32=arm; IS64BIT=true; fi;
  if [ "$ABILONG" = "x86_64" ]; then ARCH=x64; ARCH32=x86; IS64BIT=true; fi;
}

set_perm() {
  chown $2:$3 $1 || return 1
  chmod $4 $1 || return 1
  [ -z $5 ] && chcon 'u:object_r:system_file:s0' $1 || chcon $5 $1 || return 1
}

set_perm_recursive() {
  find $1 -type d 2>/dev/null | while read dir; do
    set_perm $dir $2 $3 $4 $6
  done
  find $1 -type f -o -type l 2>/dev/null | while read file; do
    set_perm $file $2 $3 $5 $6
  done
}

# Mktouch
mktouch() {
  mkdir -p ${1%/*} 2>/dev/null
  [ -z $2 ] && touch $1 || echo $2 > $1
  chmod 644 $1
}

# Grep prop
grep_prop() {
  local REGEX="s/^$1=//p"
  shift
  local FILES=$@
  [ -z "$FILES" ] && FILES='/system/build.prop'
  sed -n "$REGEX" $FILES 2>/dev/null | head -n 1
}

# Abort
abort() {
  echo "$1"
  exit 1
}

magisk_version() {
if grep MAGISK_VER /data/adb/magisk/util_functions.sh; then
  echo "$MAGISK_VERSION $MAGISK_VERSIONCODE" >> $LOG 2>&1
else
  echo "Magisk not installed" >> $LOG 2>&1
fi
}

# Device Info
# BRAND MODEL DEVICE API ABI ABI2 ABILONG ARCH
BRAND=$(getprop ro.product.brand)
MODEL=$(getprop ro.product.model)
DEVICE=$(getprop ro.product.device)
ROM=$(getprop ro.build.display.id)
api_level_arch_detect
# Version Number
VER=$(echo $(get_file_value $MODPROP "version=") | sed 's|-.*||')
# Version Code
REL=$(echo $(get_file_value $MODPROP "versionCode=") | sed 's|-.*||')
# Author
AUTHOR=$(echo $(get_file_value $MODPROP "author=") | sed 's|-.*||')
# Mod Name/Title
MODTITLE=$(echo $(get_file_value $MODPROP "name=") | sed 's|-.*||')
#Grab Magisk Version
MAGISK_VERSION=$(echo $(get_file_value /data/adb/magisk/util_functions.sh "MAGISK_VER=") | sed 's|-.*||')
MAGISK_VERSIONCODE=$(echo $(get_file_value /data/adb/magisk/util_functions.sh "MAGISK_VER_CODE=") | sed 's|-.*||')

# Colors
G='\e[01;32m'  # GREEN TEXT
R='\e[01;31m'  # RED TEXT
Y='\e[01;33m'  # YELLOW TEXT
B='\e[01;34m'  # BLUE TEXT
V='\e[01;35m'  # VIOLET TEXT
Bl='\e[01;30m'  # BLACK TEXT
C='\e[01;36m'  # CYAN TEXT
W='\e[01;37m'  # WHITE TEXT
BGBL='\e[1;30;47m' # Background W Text Bl
N='\e[0m'   # How to use (example): echo "${G}example${N}"
loadBar=' '   # Load UI
# Remove color codes if -nc or in ADB Shell
[ -n "$1" -a "$1" == "-nc" ] && shift && NC=true
[ "$NC" -o -n "$LOGNAME" ] && {
  G=''; R=''; Y=''; B=''; V=''; Bl=''; C=''; W=''; N=''; BGBL=''; loadBar='=';
}

# No. of characters in $MODTITLE, $VER, and $REL
character_no=$(echo "$MODTITLE $VER $REL" | wc -c)

# Divider
div="${Bl}$(printf '%*s' "${character_no}" '' | tr " " "=")${N}"

# title_div [-c] <title>
# based on $div with <title>
title_div() {
  [ "$1" == "-c" ] && local character_no=$2 && shift 2
  [ -z "$1" ] && { local message=; no=0; } || { local message="$@ "; local no=$(echo "$@" | wc -c); }
  [ $character_no -gt $no ] && local extdiv=$((character_no-no)) || { echo "Invalid!"; return; }
  echo "${W}$message${N}${Bl}$(printf '%*s' "$extdiv" '' | tr " " "=")${N}"
}

# set_file_prop <property> <value> <prop.file>
set_file_prop() {
if [ -f "$3" ]; then
  if grep -q "$1=" "$3"; then
    sed -i "s/${1}=.*/${1}=${2}/g" "$3"
  else
    echo "$1=$2" >> "$3"
  fi
else
  echo "$3 doesn't exist!"
fi
}

# https://github.com/fearside/ProgressBar
# ProgressBar <progress> <total>
ProgressBar() {
# Determine Screen Size
  if [[ "$COLUMNS" -le "57" ]]; then
    local var1=2
	  local var2=20
  else
    local var1=4
    local var2=40
  fi
# Process data
  local _progress=$(((${1}*100/${2}*100)/100))
  local _done=$(((${_progress}*${var1})/10))
  local _left=$((${var2}-$_done))
# Build progressbar string lengths
  local _done=$(printf "%${_done}s")
  local _left=$(printf "%${_left}s")

# Build progressbar strings and print the ProgressBar line
printf "\rProgress : ${BGBL}|${N}${_done// /${BGBL}$loadBar${N}}${_left// / }${BGBL}|${N} ${_progress}%%"
}

#https://github.com/fearside/SimpleProgressSpinner
# Spinner <message>
Spinner() {

# Choose which character to show.
case ${_indicator} in
  "|") _indicator="/";;
  "/") _indicator="-";;
  "-") _indicator="\\";;
  "\\") _indicator="|";;
  # Initiate spinner character
  *) _indicator="\\";;
esac

# Print simple progress spinner
printf "\r${@} [${_indicator}]"
}

# cmd & spinner <message>
e_spinner() {
  PID=$!
  h=0; anim='-\|/';
  while [ -d /proc/$PID ]; do
    h=$(((h+1)%4))
    sleep 0.02
    printf "\r${@} [${anim:$h:1}]"
  done
}                                                                       

# test_connection
# tests if there's internet connection
test_connection() {
  ui_print " [-] Testing internet connection [-] "
  ping -q -c 1 -W 1 google.com >/dev/null 2>&1 && ui_print " [-] Internet Detected [-] "  && CON=true || { abort " [-] Error, No Internet Connection [-] ";NCON=true; }
}

test_connection2() {
  case "$(curl -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) ui_print " [-] HTTP connectivity is up [-] "
    CON2=true
    ;;
  5) ui_print " [!] The web proxy won't let us through [!] "
    NCON2=true
    ;;
  *) ui_print " [!] The network is down or very slow [!] "
    NCON2=true
    ;;
esac
}

test_connection3() {
  wget -q --tries=5 --timeout=10 http://www.google.com -O $MODPATH/google.idx >/dev/null 2>&1
if [ ! -s $MODPATH/google.idx ]
then
    ui_print " [!] Not Connected... [!] "
    NCON3=true
else
    ui_print " [-] Connected..! [-] "
    CON3=true
fi
rm -f $MODPATH/google.idx
}

# Log files will be uploaded to termbin.com
# Logs included: VERLOG LOG oldVERLOG oldLOG
upload_logs() {
  $BBok && {
    test_connection3
    [ $CON3 ] || test_connection2
    [ $CON2 ] || test_connection
    if [ $CON ] || [ $CON2 ] || [ $CON3 ]; then
      echo "Uploading logs"
      [ -s $VERLOG ] && verUp=$(cat $VERLOG | nc termbin.com 9999) || verUp=none
      [ -s $oldVERLOG ] && oldverUp=$(cat $oldVERLOG | nc termbin.com 9999) || oldverUp=none
      [ -s $LOG ] && logUp=$(cat $LOG | nc termbin.com 9999) || logUp=none
      [ -s $oldLOG ] && oldlogUp=$(cat $oldLOG | nc termbin.com 9999) || oldlogUp=none
      echo -n "Link: "
      echo "$MODEL ($DEVICE) API $API\n$ROM\n$ID\n
      O_Verbose: $oldverUp
      Verbose:   $verUp
      O_Log: $oldlogUp
      Log:   $logUp" | nc termbin.com 9999
    fi
  } || echo "Busybox not found!"
  exit
}

# Print Center
# Prints text in the center of terminal
pcenter() {
  local CHAR=$(printf "$@" | sed 's|\\e[[0-9;]*m||g' | wc -m)
  local hfCOLUMN=$((COLUMNS/2))
  local hfCHAR=$((CHAR/2))
  local indent=$((hfCOLUMN-hfCHAR))
  echo "$(printf '%*s' "${indent}" '') $@"
}

reboot(){
  setprop sys.powerctl reboot
}

# Heading
mod_head() {
  echo "$div"
  echo "${W}$MODTITLE $VER${N}(${Bl}$REL${N})"
  echo "by ${W}$AUTHOR${N}"
  echo "$div"
  echo "${R}$BRAND${N},${R}$MODEL${N},${R}$ROM${N}"
  echo "$div"
  echo "${W}BUSYBOX VERSION = ${N}${R}$_bbname${N}${R}$BBV${N}"
  echo "$div"
  echo "${W}MAGISK VERSION = ${N}${R} $MAGISK_VERSION${N}" 
  echo "$div"
  echo ""
}

#=========================== Main
# > You can start your MOD here.
# > You can add functions, variables & etc.
# > Rather than editing the default vars above.



#######################################################################################################
#                                        MENU                                                         #
#######################################################################################################
menu() {
echo "$div"
pcenter "${G} ___________________    ___________________________ ${N}"
pcenter "${G} \_   _____/\_____  \   \      \__    ___/   _____/ ${N}"
pcenter "${G}  |    __)   /   |   \  /   |   \|    |  \_____  \  ${N}"
pcenter "${G}  |     \   /    |    \/    |    \    |  /        \ ${N}"
pcenter "${G}  \___  /   \_______  /\____|__  /____| /_______  / ${N}"
pcenter "${G}      \/            \/         \/               \/  ${N}"
echo " "
echo "$div"
mod_head
echo " "
pcenter "${B}Welcome to Font Changer!${N}"
echo " "
echo "${R}IF THIS IS YOUR FIRST TIME PLEASE CHOOSE OPTION 5 TO SEE HOW TO SET UP YOUR CUSTOM FONTS!${N}"
echo " "
FONT=$(get_file_value $CFONT CURRENT=)
EMOJI=$(get_file_value $CEMOJI CURRENT=)
if [ $FONT ] ; then
  echo "${Y}[=] Current Font is $FONT [=]${N}"
else
  echo "${R}[!] No Font Applied Yet [!]${N}"
fi
if [ $EMOJI ]; then
  echo "${Y}[=] Current Emoji is $EMOJI [=]${N}"
else
  echo "${R}[!] No Emoji Applied Yet [!]${N}"
fi
echo "${B}[-] Select an Option...${N}"
echo " "
sleep 1
echo -e "${W}[1]${N} ${G} - Choose From Over 200 Fonts${N}"
echo " "
echo -e "${W}[2]${N} ${G} - List Fonts in Folder (Custom)${N}"
echo " "
echo -e "${W}[3]${N} ${G} - Change to Stock Font or Emoji${N}"
echo " "
echo -e "${W}[4]${N} ${G} - Change Emojis${N}"
echo " "
echo -e "${W}[5]${N} ${G} - How to Set Up the Font Folder${N}"
echo " "
echo -e "${W}[6]${N} ${G} - Help (Options)${N}"
echo " "
echo -e "${W}[7]${N} ${G} - Update lists for Emojis and Fonts${N}"
echo " "
#echo -e "${W}[8]${N} ${G} - Take Logs${N}"
#echo " "
echo -e "${R}[Q] - Quit${N}"
echo " "
echo -n "${B}[CHOOSE] : ${N}"
echo " "
read -r choice
  case $choice in
    1) echo "${Y}[-] Font Chooser Menu Selected...${N}"
      font_menu
      ;;
    2) echo "${G}[-] Custom Font Menu Selected...${N}"
      custom_menu
      ;;
    3) echo "${B}[-] Stock Font/Emoji Menu Selected...${N}"
      default_menu
      ;;
    4) echo "${R}[-] Emoji Menu Selected...${N}"
      emoji_menu
      ;;
    5) echo "${C}[-] Custom Setup Help Selected...${N}"
      help_custom
      ;;
    6) echo "${B}[-] Option Help Selected...${N}"
      help
      ;;
    7) echo "${Y}[-] Update Lists of Emojis/Fonts Selected..."
      update_lists
      ;;
#    8) log_print " Collecting logs and creating archive "
#      magisk_version
#      collect_logs
#      upload_logs
#      quit
#      ;;
    q|Q) echo "${R}[-] Quiting...${N}"
      clear
      quit
      ;;
    *) echo "${Y}[!] Item Not Available! Try Again [!]${N}"
      sleep 1.5
      clear
      ;;
  esac
}
#######################################################################################################
#                                        SHORTCUTS                                                    #
#######################################################################################################
apply_font_shortcut() {
echo -e "${B}Applying Font. Please Wait...${N}"
sleep 2
choice2="$(grep -w $i $MODPATH/fontlist.txt | tr -d '[ ]' | tr -d '[0-9]' | tr -d ' ')"
if [ -f "$MODPATH/system/fonts/*Emoji*.ttf" ]; then
  for i in $MODPATH/system/fonts/*Emoji*.ttf; do
    mv -f $i $MODPATH
  done
fi
rm -rf $MODPATH/system/fonts > /dev/null 2>&1
mkdir -p $FCDIR/Fonts/$choice2
[ -e $FCDIR/Fonts/$choice2.zip ] || curl -k -o "$FCDIR/Fonts/$choice2.zip" https://john-fawkes.com/Downloads/$choice2.zip
unzip -o "$FCDIR/Fonts/$choice2.zip" 'system/*' -d $FCDIR/Fonts/$choice2 >&2 
mkdir -p $MODPATH/system/fonts
if [ -f "$MODPATH/*Emoji*.ttf" ]; then
  for i in $MODPATH/*Emoji*.ttf; do
    mv -f $i $MODPATH/system/fonts
  done
fi
cp -rf $FCDIR/Fonts/$choice2/system/fonts/ $MODPATH/system/fonts
set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644 > /dev/null 2>&1
truncate -s 0 $CFONT
echo -n "CURRENT=$choice2" >> $CFONT
rm -r $FCDIR/Fonts/$choice2
if [ -d "$FCDIR/Fonts/$choice2.zip" ] && [ -d $MODPATH/system/fonts ]; then
  font_reboot_menu
else
  echo -e "${R}[!] FONT WAS NOT APPLIED [!]${N}"
  echo -e "${R} PLEASE TRY AGAIN${N}"
  exit
fi
}

apply_custom_font_shortcut() {
choice2="$(grep -w $i $MODPATH/customfontlist.txt | tr -d '[ ]' | tr -d '[0-9]' | tr -d ' ')"
cusfont=$(cat $MODPATH/listforcustom.txt)
if [ -e $FCDIR/dump.txt ]; then
  truncate -s 0 $FCDIR/dump.txt
else
  touch $FCDIR/dump.txt
fi
for i in ${cusfont[@]} ; do
  if [ -e $FCDIR/Fonts/Custom/$choice2/$i ]; then
    echo "$i found" >> $FCDIR/dump.txt && echo "${B}$i Found${N}"
  fi
  if [ ! -e $FCDIR/Fonts/Custom/$choice2/$i ]; then
    echo "$i NOT FOUND" >> $FCDIR/dump.txt && echo "${R}$i NOT FOUND${N}"
  fi
done
if grep -wq "$i NOT FOUND" $FCDIR/dump.txt; then
  abort "${R}Script Will Not Continue Until All ttf Files Exist!${N}"
fi
PASSED=true
  for i in $MODPATH/system/fonts/*Emoji*.ttf; do
    if [ -e $i ]; then
      mv -f $i $MODPATH
    fi
  done
rm -rf $MODPATH/system/fonts >/dev/null 2>&1
mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
  for i in $MODPATH/*Emoji*.ttf; do
    if [ -e $i ]; then
      mv -f $i $MODPATH/system/fonts
    fi
  done
cp -f $FCDIR/Fonts/Custom/$choice2/* $MODPATH/system/fonts/
set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644 >/dev/null 2>&1
[ -f $CFONT ] || touch $CFONT
truncate -s 0 $CFONT
echo -n "CURRENT=$choice2" >> $CFONT
if [ $PASSED == true ] && [ -d $MODPATH/system/fonts ]; then
  font_reboot_menu
else
  echo -e "${R}[!] FONT WAS NOT APPLIED [!]${N}"
  echo -e "${R} PLEASE TRY AGAIN${N}"
  exit
fi
}

case "$1" in
  -a|--font) shift
    for i in "$@"; do
      apply_font_shortcut $i
	    echo "$div"
	  done
	  exit;;
  -c|--cemoji) shift
    for i in "$@"; do
      apply_custom_emoji $i
      echo "$div"
    done
    exit;;
  -d|--cfont) shift
    for i in "$@"; do
      apply_custom_font_shortcut $i
      echo "$div"
    done
    exit;;
  -e|--emoji) shift
    for i in "$@"; do
      apply_emoji $i
      echo "$div"
    done
    exit;;
  -h|--help) shift
    help;;
  -l|--listc) shift
    custom_font_menu
    exit;;
  -m|--list) shift
    font_menu;;
  -s|--current) shift
    FONT=$(get_file_value $CFONT CURRENT=)
    if [ $FONT ]; then
      echo "${Y}[=] Current Font is $FONT [=]${N}"
    else
      echo "${R}[!] No Font Applied Yet [!]${N}"
    fi
	    echo "$div"
	  exit;;
  -u|--update) shift
    update_lists;;
esac

menu

quit $?
