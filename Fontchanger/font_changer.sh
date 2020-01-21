#!/data/adb/modules/Fontchanger/bash
# Terminal Magisk Mod Template
# by veez21 @ xda-developers
# Modified by @JohnFawkes - Telegram/XDA
# Help from @Zackptg5 - Telegram/XDA
# Variables

get_file_value() {
  if [ -f "$1" ]; then
    grep $2 $1 | sed "s|.*${2}||" | sed 's|\"||g'
  fi
}

MAGISKVERCODE=$(echo $(get_file_value /data/adb/magisk/util_functions.sh "MAGISK_VER_CODE=") | sed 's|-.*||')

OLDPATH=$PATH
MODID=Fontchanger
MODPATH=/data/adb/modules/$MODID
MODPROP=$MODPATH/module.prop
SDCARD=/storage/emulated/0
FCDIR=$SDCARD/Fontchanger
TMPLOG=Fontchanger_logs.log
TMPLOGLOC=$FCDIR/logs
XZLOG=$TMPLOGLOC/Fontchanger_logs.zip
#if [ -d /cache ]; then CACHELOC=/cache; else CACHELOC=/data/cache; fi       
CFONT=$MODPATH/currentfont.txt
CEMOJI=$MODPATH/currentemoji.txt
MIRROR=/sbin/.magisk/mirror

quit() {
  PATH=$OLDPATH
  exit $?
}

get_var() { 
  sed -n 's/^name=//p' ${1}; 
}

_name=$(basename $0)
ls /data >/dev/null 2>&1 || { echo "$MODID needs to run as root!"; echo "type 'su' then '$_name'"; quit 1; }

# Load magisk stuff
if [ -f /data/adb/magisk/util_functions.sh ]; then
  . /data/adb/magisk/util_functions.sh
elif [ -f /data/magisk/util_functions.sh ]; then
  . /data/magisk/util_functions.sh
else
  echo -e "! Can't find magisk util_functions! Aborting!"; exit 1
fi

# Load Needed Functions
if [ -e /sbin/${MODID}-functions ]; then
  . /sbin/${MODID}-functions
else
  echo -e "! Can't find functions script! Aborting!"; exit 1
fi  

#=========================== Set Log Files
#mount -o remount,rw $CACHELOC 2>/dev/null
#mount -o rw,remount $CACHELOC 2>/dev/null
# > Logs should go in this file
LOG=$TMPLOGLOC/${MODID}.log
oldLOG=$TMPLOGLOC/${MODID}-old.log
# > Verbose output goes here
VERLOG=$TMPLOGLOC/${MODID}-verbose.log
oldVERLOG=$TMPLOGLOC/${MODID}-verbose-old.log

# Start Logging verbosely
mv -f $VERLOG $oldVERLOG 2>/dev/null
exec 2>$VERLOG
set -x 2>&1 >/dev/null


log_start

MODULESPATH=/data/adb/modules
setabort=0
for i in "$MODULESPATH"*; do
  if [[ $i != *Fontchanger ]] && [ ! -f $i/disable ] && [ -d $i/system/fonts ]; then
    NAME=$(get_var $i/module.prop)
    ui_print " [!] "
    ui_print " [!] Module editing fonts detected [!] "
    ui_print " [!] Module - $NAME [!] "
    ui_print " [!] "
    setabort=1
  fi
done
if [[ $setabort == 1 ]]; then
  ui_print " [!] Remove all Conflicting Font Modules before Continuing [!] "
  abort
fi

# set_busybox <busybox binary>
# alias busybox applets
set_busybox() {
  if [ -x "$1" ]; then
    for i in $(${1} --list); do
      if [ "$i" != 'echo' ]; then
        alias "$i"="${1} $i" >/dev/null 2>&1
      fi
    done
    BBox=true
    _bb=$1
  fi
}
BBox=false
# Set Busybox up
if [ "$(busybox 2>/dev/null)" ]; then
  BBox=true
elif [ -e /data/adb/magisk/busybox ]; then
  PATH=/data/adb/magisk/busybox:$PATH
	_bb=/data/adb/magisk/busybox
  BBox=true
elif [ -e $MODPATH/busybox ]; then
  PATH=$MODPATH/busybox:$PATH
  _bb=$MODPATH/busybox
  BBox=true
else
  BBox=false
  echo "! Busybox not detected"
	echo "Please install one (@osm0sis' busybox recommended)"
  abort
fi
set_busybox $_bb
[ $? -ne 0 ] && exit $?

if [ -z "$(echo -e $PATH | grep /sbin:)" ]; then
 alias resetprop="/data/adb/magisk/magisk resetprop"
fi

[ -n "$ANDROID_SOCKET_adbd" ] && alias clear='echo'

BBV=$(busybox | grep "BusyBox v" | sed 's|.*BusyBox ||' | sed 's| (.*||')

alias curl=$MODPATH/curl
alias sleep=$MODPATH/sleep
#alias xmlstarlet=$MODPATH/xmlstarlet
alias zip=$MODPATH/zip

# Log print
#echo -e "Functions loaded." >> $LOG
#if $BBox; then#
#  BBV=$(busybox | grep "BusyBox v" | sed 's|.*BusyBox ||' | sed 's| (.*||')
#  echo -e "Using busybox: ${PATH} (${BBV})." >> $LOG
#else
#  echo -e "Using installed applets (not busybox)" >> $LOG
#fi

# Functions
get_file_value() {
  if [ -f "$1" ]; then
    grep $2 $1 | sed "s|.*${2}||" | sed 's|\"||g'
  fi
} 

#api_level_arch_detect() {
#  API=$(grep_prop ro.build.version.sdk)
#  ABI=$(grep_prop ro.product.cpu.abi | cut -c-3)
#  ABI2=$(grep_prop ro.product.cpu.abi2 | cut -c-3)
#  ABILONG=$(grep_prop ro.product.cpu.abi)
#  ARCH=arm
#  ARCH32=arm
#  IS64BIT=false
#  if [ "$ABI" = "x86" ]; then ARCH=x86; ARCH32=x86; fi;
#  if [ "$ABI2" = "x86" ]; then ARCH=x86; ARCH32=x86; fi;
#  if [ "$ABILONG" = "arm64-v8a" ]; then ARCH=arm64; ARCH32=arm; IS64BIT=true; fi;
#  if [ "$ABILONG" = "x86_64" ]; then ARCH=x64; ARCH32=x86; IS64BIT=true; fi;
#}

#set_perm() {
#  chown $2:$3 $1 || return 1
#  chmod $4 $1 || return 1
#  CON=$5
#  [ -z $CON ] && CON=u:object_r:system_file:s0
#  chcon $CON $1 || return 1
#}

#set_perm_recursive() {
#  find $1 -type d 2>/dev/null | while read dir; do
#    set_perm $dir $2 $3 $4 $6
#  done
#  find $1 -type f -o -type l 2>/dev/null | while read file; do
#    set_perm $file $2 $3 $5 $6
#  done
#}

# Mktouch
#mktouch() {
#  mkdir -p ${1%/*} 2>/dev/null
#  [ -z $2 ] && touch $1 || echo $2 > $1
#  chmod 644 $1
#}

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
  echo -e "$1"
  exit 1
}

magisk_version() {
if grep MAGISK_VER /data/adb/magisk/util_functions.sh; then
  echo -e "$MAGISK_VERSION $MAGISK_VERSIONCODE" >> $LOG 2>&1
else
  echo -e "Magisk not installed" >> $LOG 2>&1
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
VER=$(get_file_value $MODPROP "version=" | sed 's|-.*||')
# Version Code
REL=$(get_file_value $MODPROP "versionCode=" | sed 's|-.*||')
# Author
AUTHOR=$(get_file_value $MODPROP "author=" | sed 's|-.*||')
# Mod Name/Title
MODTITLE=$(get_file_value $MODPROP "name=" | sed 's|-.*||')
#Grab Magisk Version
MAGISK_VERSION=$(get_file_value /data/adb/magisk/util_functions.sh "MAGISK_VER=" | sed 's|-.*||')

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
N='\e[0m'   # How to use (example): echo -e "${G}example${N}"
loadBar=' '   # Load UI
# Remove color codes if -nc or in ADB Shell
[ -n "$1" -a "$1" == "-nc" ] && shift && NC=true
[ "$NC" -o -n "$ANDROID_SOCKET_adbd" ] && {
  G=''; R=''; Y=''; B=''; V=''; Bl=''; C=''; W=''; N=''; BGBL=''; loadBar='=';
}

# No. of characters in $MODTITLE, $VER, and $REL
character_no=$(echo -e "$MODTITLE $VER $REL" | wc -c)

# Divider
div="${Bl}$(printf '%*s' "${character_no}" '' | tr " " "=")${N}"

# title_div [-c] <title>
# based on $div with <title>
title_div() {
  [ "$1" == "-c" ] && local character_no=$2 && shift 2
  [ -z "$1" ] && { local message=; no=0; } || { local message="$@ "; local no=$(echo -e "$@" | wc -c); }
  [ $character_no -gt $no ] && local extdiv=$((character_no-no)) || { echo -e "Invalid!"; return; }
  echo -e "${W}$message${N}${Bl}$(printf '%*s' "$extdiv" '' | tr " " "=")${N}"
}

# set_file_prop <property> <value> <prop.file>
set_file_prop() {
if [ -f "$3" ]; then
  if grep -q "$1=" "$3"; then
    sed -i "s/${1}=.*/${1}=${2}/g" "$3"
  else
    echo -e "$1=$2" >> "$3"
  fi
else
  echo -e "$3 doesn't exist!"
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
  ping -q -c 1 -W 1 google.com >/dev/null 2>&1 && ui_print " [-] Internet Detected [-] "; CON1=true; CON2=false; CON3=false || { abort " [-] Error, No Internet Connection [-] ";NCON=true; }
}

test_connection2() {
  case "$(curl -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) ui_print " [-] HTTP connectivity is up [-] "
    CON1=false
    CON2=true
    CON3=false
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
  if [ ! -s $MODPATH/google.idx ]; then
    ui_print " [!] Not Connected... [!] "
    NCON3=true
  else
    ui_print " [-] Connected..! [-] "
    CON1=false
    CON2=false
    CON3=true
  fi
  rm -f $MODPATH/google.idx
}

# Log files will be uploaded to termbin.com
# Logs included: VERLOG LOG oldVERLOG oldLOG
upload_logs() {
  $BBox && {
  test_connection3
  if ! "$CON3"; then
    test_connection2
    if ! "$CON2"; then
      test_connection
    fi
  fi
  if "$CON1" || "$CON2" || "$CON3"; then
      echo -e "Uploading logs"
      [ -s $VERLOG ] && verUp=$(cat $VERLOG | nc termbin.com 9999) || verUp=none
      [ -s $oldVERLOG ] && oldverUp=$(cat $oldVERLOG | nc termbin.com 9999) || oldverUp=none
      [ -s $LOG ] && logUp=$(cat $LOG | nc termbin.com 9999) || logUp=none
      [ -s $oldLOG ] && oldlogUp=$(cat $oldLOG | nc termbin.com 9999) || oldlogUp=none
      [ -s $XZLOG ] && XZLOGUp=$(cat $XZLOG | nc termbin.com 9999) || XZLOGUp=none
      echo -e "Link: "
      echo -e "$MODEL ($DEVICE) API $API\n$ROM\n$ID\n
      O_Verbose: $oldverUp
      Verbose:   $verUp
      O_Log: $oldlogUp
      Log:   $logUp
      Zip: $XZLOGUp" | nc termbin.com 9999
    fi
  } || echo -e "Busybox not found!"
  exit
}

# Print Center
# Prints text in the center of terminal
pcenter() {
  local CHAR=$(printf "$@" | sed 's|\\e[[0-9;]*m||g' | wc -m)
  local hfCOLUMN=$((COLUMNS/2))
  local hfCHAR=$((CHAR/2))
  local indent=$((hfCOLUMN-hfCHAR))
  echo -e "$(printf '%*s' "${indent}" '') $@"
}

reboot(){
  setprop sys.powerctl reboot
}

# Heading
mod_head() {
  echo -e "$div"
  echo -e "${W}$MODTITLE $VER${N}(${Bl}$REL${N})"
  echo -e "by ${W}$AUTHOR${N}"
  echo -e "$div"
  echo -e "${R}$BRAND${N},${R}$MODEL${N},${R}$ROM${N}"
  echo -e "$div"
  echo -e "${W}BUSYBOX VERSION = ${N}${R} $BBV${N}"
  echo -e "$div"
  echo -e "${W}MAGISK VERSION = ${N}${R} $MAGISK_VERSION${N}" 
  echo -e "$div"
  echo -e ""
}

#=========================== Main
# > You can start your MOD here.
# > You can add functions, variables & etc.
# > Rather than editing the default vars above.



#######################################################################################################
#                                        MENU                                                         #
#######################################################################################################
SKIPUP=0
menu() {
  choice=""
  fontchoice=""

  while [ "$choice" != "q" ]; do
    echo -e "$div"
    pcenter "${G} ___________________    ___________________________ ${N}"
    pcenter "${G} \_   _____/\_____  \   \      \__    ___/   _____/ ${N}"
    pcenter "${G}  |    __)   /   |   \  /   |   \|    |  \_____  \  ${N}"
    pcenter "${G}  |     \   /    |    \/    |    \    |  /        \ ${N}"
    pcenter "${G}  \___  /   \_______  /\____|__  /____| /_______  / ${N}"
    pcenter "${G}      \/            \/         \/               \/  ${N}"
    echo -e " "
    echo -e "$div"
    mod_head
    echo -e " "
    pcenter "${B}Welcome to Font Changer!${N}"
    echo -e " "
    if [[ $SKIPUP == 0 ]]; then
      echo -e "${G}Would You like to Update the Font List?${N}"
      echo -e " "
      echo -e "${G}Enter y or n${N}"
      echo -e " "
      echo -e "${B}[CHOOSE] : ${N}"
      echo -e " "
      read -r fontchoice
      case $(echo -e $fontchoice | tr '[:upper:]' '[:lower:]') in
        y)  
          echo -e "${Y}[!] Updating Font/Emoji/User Fonts Lists [!]${N}"
          echo -e " "
          echo -e "${Y}[!] Please Wait For the Update to Finish [!]${N}"
          update_lists
        ;;
        n)
          echo -e "${R}Skipping Font List Updating...${N}"
        ;;
      esac
    fi 
    FONT=$(get_file_value $CFONT CURRENT=)
    EMOJI=$(get_file_value $CEMOJI CURRENT=)
    if [ $FONT ]; then
      echo -e "${Y}[=] Current Font is $FONT [=]${N}"
    else
      echo -e "${R}[!] No Font Applied Yet [!]${N}"
    fi
    if [ $EMOJI ]; then
      echo -e "${Y}[=] Current Emoji is $EMOJI [=]${N}"
    else
      echo -e "${R}[!] No Emoji Applied Yet [!]${N}"
    fi
    echo -e "${B}[-] Select an Option...${N}"
    echo -e " "
    sleep 1
    echo -e "${W}[1]${N} ${G} - Fonts${N}"
    echo -e " "
    echo -e "${W}[2]${N} ${G} - Emojis${N}"
    echo -e " "
    echo -e "${W}[3]${N} ${G} - Change to Stock Font or Emoji${N}"
    echo -e " "
    echo -e "${W}[4]${N} ${G} - Help${N}"
    echo -e " "
    echo -e "${W}[5]${N} ${G} - Take Logs${N}"
    echo -e " "
    echo -e "${W}[6]${N} ${G} - Delete Downloaded Zips to Clear Space${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
      1)
        echo -e "${Y}[-] Font Chooser Menu Selected...${N}"
        choose_font_menu
        break
      ;;
      2)
        echo -e "${R}[-] Emoji Menu Selected...${N}"
        choose_emoji_menu
        break
      ;;
      3)
        echo -e "${B}[-] Stock Font/Emoji Menu Selected...${N}"
        default_menu
        break
      ;;
      4)
        echo -e "${B}[-] Option Help Selected...${N}"
        choose_help_menu
      ;;
      5)
        log_print "${G}[-] Collecting logs and creating archive...${N}"
        magisk_version
        collect_logs
        upload_logs
        quit
      ;;
      6)
        echo -e "${G}[-] Clear Downloaded Zips Selected...${N}"
        clear_menu
        break
      ;;
      q)
        echo -e "${R}[-] Quiting...${N}"
        clear
        quit
      ;;
      *)
        echo -e "${Y}[!] Item Not Available! Try Again [!]${N}"
        sleep 1.5
        clear
      ;;
    esac
  done
}


menu

quit $?
