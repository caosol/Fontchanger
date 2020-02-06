#!/data/adb/modules/Fontchanger/bash
#######################################################################################################
#                                              Leave Menu                                             #
#######################################################################################################
# Variables:
#  BBok - If busybox detection was ok (true/false)
#  _bb - Busybox binary directory
#  _bbname - Busybox name

# set_busybox <busybox binary>
# alias busybox applets
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
elif [ -d /data/adb/modules/busybox-ndk ]; then
  BUSY=$(find /data/adb/modules/busybox-ndk/system/* -maxdepth 0 | sed 's#.*/##')
  for i in $BUSY; do
    PATH=/data/adb/modules/busybox-ndk/system/$i:$PATH
    _bb=/data/adb/modules/busybox-ndk/system/$i/busybox
    BBox=true
  done
elif [ -d /sbin/.magisk/busybox ]; then
  PATH=/sbin/.magisk/busybox:$PATH
  _bb=/sbin/.magisk/busybox/busybox
  BBox=true
elif [ -f $MODPATH/busybox ]; then
  PATH=$MODPATH/busybox:$PATH
  _bb=$MODPATH/busybox
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


invalid() {
  echo -e "${R}Invaild Option...${N}"
  $SLEEP 3
  clear
}

return_menu() {
  SKIPUP=$((SKIPUP + 1))
  mchoice=""
  while [[ "$mchoice" != "y" && "$mchoice" != "n" ]]; do
    echo -e "${R}Return to menu? < y | n > : ${N}"
    read -r mchoice
    case $(echo -e $mchoice | tr '[:upper:]' '[:lower:]') in
    y) menu ;;
    n) clear && quit ;;
    *) invalid ;;
    esac
  done
}

emoji_reboot_menu() {
  mchoice=""
  while [[ "$mchoice" != "y" && "$mchoice" != "n" ]]; do
    echo -e "${B}Emoji Applied Successfully...${N}"
    echo -e "${R}You Will Need to Reboot to Apply Changes${N}"
    echo -e "${R}Reboot? < y | n > : ${N}"
    read -r mchoice
    case $(echo -e $mchoice | tr '[:upper:]' '[:lower:]') in
    y) reboot ;;
    n) return_menu ;;
    *) invalid ;;
    esac
  done
}

font_reboot_menu() {
  mchoice=""
  while [[ "$mchoice" != "y" && "$mchoice" != "n" ]]; do
    echo -e "${B}Font Applied Successfully...${N}"
    echo -e "${R}You Will Need to Reboot to Apply Changes${N}"
    echo -e "${R}Reboot? < y | n > : ${N}"
    read -r mchoice
    case $(echo -e $mchoice | tr '[:upper:]' '[:lower:]') in
    y) reboot ;;
    n) return_menu ;;
    *) invalid ;;
    esac
  done
}

retry() {
  echo -e "${R}[!] FONT WAS NOT APPLIED [!]${N}"
  echo -e "${R} PLEASE TRY AGAIN${N}"
  $SLEEP 3
  clear
}

is_not_empty() {
  DIR="$1"
  DIR2="$2"
  if $2; then
    "$(ls -Ap $DIR $DIR2 | grep -v "/")"
  else
    "$(ls -Ap $DIR | grep -v "/")"
  fi
}

is_not_empty_font() {
  DIR="$1"
  if [ "$( ls -Ap $DIR | grep -v "/")" ]; then
    font_reboot_menu
  else
    retry
  fi
}

lg_device() {
device=$(getprop ro.product.brand 2>/dev/null)
if [ $device = "lge" ]; then
  if [ -d $MODPATH/system/fonts ]; then
    cp -f $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/LG_Number_Roboto_Bold_New.ttf
    cp -f $MODPATH/system/fonts/Roboto-Bold.ttf $MODPATH/system/fonts/LG_Number_Roboto_Bold.ttf
    cp -f $MODPATH/system/fonts/Roboto-Light.ttf $MODPATH/system/fonts/LG_Number_Roboto_Light.ttf
    cp -f $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/LG_Number_Roboto_Regular.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/LG_Number_Roboto_Thin_New.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/LG_Number_Roboto_Thin.ttf
    cp -f $MODPATH/system/fonts/Roboto-Light.ttf $MODPATH/system/fonts/LG_SlimNumber-Light.ttf
    cp -f $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/LG_SlimNumber-Regular.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/LG_SlimNumber-Thin.ttf
  elif [ -d $MODPATH/system/product/fonts ]; then
    cp -f $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Bold_New.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Bold.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Bold.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Light.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Light.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Regular.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Regular.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Thin.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Thin_New.ttf
    cp -f $MODPATH/system/product/fonts/Roboto-Thin.ttf $MODPATH/system/product/fonts/LG_Number_Roboto_Thin.ttf
    cp -f $MODPATH/system/fonts/Roboto-Light.ttf $MODPATH/system/fonts/LG_SlimNumber-Light.ttf
    cp -f $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/LG_SlimNumber-Regular.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/LG_SlimNumber-Thin.ttf
  elif [ -d $MODPATH/product/fonts ]; then
    cp -f $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/LG_Number_Roboto_Bold_New.ttf
    cp -f $MODPATH/product/fonts/Roboto-Bold.ttf $MODPATH/product/fonts/LG_Number_Roboto_Bold.ttf
    cp -f $MODPATH/product/fonts/Roboto-Light.ttf $MODPATH/product/fonts/LG_Number_Roboto_Light.ttf
    cp -f $MODPATH/product/fonts/Roboto-Regular.ttf $MODPATH/product/fonts/LG_Number_Roboto_Regular.ttf
    cp -f $MODPATH/product/fonts/Roboto-Thin.ttf $MODPATH/product/fonts/LG_Number_Roboto_Thin_New.ttf
    cp -f $MODPATH/product/fonts/Roboto-Thin.ttf $MODPATH/product/fonts/LG_Number_Roboto_Thin.ttf
    cp -f $MODPATH/system/fonts/Roboto-Light.ttf $MODPATH/system/fonts/LG_SlimNumber-Light.ttf
    cp -f $MODPATH/system/fonts/Roboto-Regular.ttf $MODPATH/system/fonts/LG_SlimNumber-Regular.ttf
    cp -f $MODPATH/system/fonts/Roboto-Thin.ttf $MODPATH/system/fonts/LG_SlimNumber-Thin.ttf
  fi
fi
}
#######################################################################################################
#                                               LOGGING                                               #
#######################################################################################################
# Loggers
LOGGERS="
$CACHELOC/magisk.log
$CACHELOC/magisk.log.bak
/data/adb/magisk_debug.log
$TMPLOGLOC/Fontchanger-install-verbose.log
$TMPLOGLOC/Fontchanger-install.log
$TMPLOGLOC/${MODID}-service.log
$TMPLOGLOC/${MODID}.log
$TMPLOGLOC/${MODID}-old.log
$TMPLOGLOC/${MODID}-verbose.log
$TMPLOGLOC/${MODID}-verbose-old.log
"

log_handler() {
  if [ $(id -u) == 0 ]; then
    echo -e "" >>$LOG
    echo -e "$(date +"%m-%d-%Y %H:%M:%S") - $1" >>$LOG
  fi
}

log_print() {
  echo -e "$1"
  log_handler "$1"
}

log_script_chk() {
  log_handler "$1"
  echo -e "$(date +"%m-%d-%Y %H:%M:%S") - $1" >>$LOG
}

#Log Functions
# Saves the previous log (if available) and creates a new one
log_start() {
  if [ -f "$LOG" ]; then
    mv -f $LOG $oldLOG
  fi
  touch $LOG
  echo "*********************************************" >>$LOG
  echo "*              FontChanger                  *" >>$LOG
  echo "*********************************************" >>$LOG
  echo "*                 $VER                      *" >>$LOG
  echo "*              John Fawkes                  *" >>$LOG
  echo "*********************************************" >>$LOG
  log_script_chk "Log start."
}

collect_logs() {
  log_handler "Collecting logs and information."
  # Create temporary directory
  mkdir -pv $TMPLOGLOC >>$LOG

  # Saving the current prop values
  log_handler "RESETPROPS"
  echo -e "==========================================" >>$LOG
  resetprop >>$LOG
  log_print " Collecting Modules Installed "
  echo -e "==========================================" >>$LOG
  ls /data/adb/modules >>$LOG
  log_print " Collecting Logs for Installed Files "
  echo -e "==========================================" >>$LOG
  log_handler "$(du -ah $MODPATH)" >>$LOG
  echo -e "==========================================" >>$LOG

  # Saving Magisk and module log files and device original build.prop
  for ITEM in $LOGGERS; do
    if [ -f "$ITEM" ]; then
      case "$ITEM" in
      *build.prop*)
        BPNAME="build_$(echo -e $ITEM | sed 's|\/build.prop||' | sed 's|.*\/||g').prop"
        ;;
      *)
        BPNAME=""
        ;;
      esac
      cp -af $ITEM ${TMPLOGLOC}/${BPNAME} >>$LOG
    else
      case "$ITEM" in
      *$FCDIR)
        FCDIRLOCTMP=$FCDIR/Logs
        ITEMTPM=$(echo -e $ITEM | sed 's|$FCDIR|$FCDIRLOCTMP|')
        if [ -f "$ITEMTPM" ]; then
          cp -af $ITEMTPM $TMPLOGLOC >>$LOG
        else
          log_handler "$ITEM not available."
        fi
        ;;
      *)
        log_handler "$ITEM not available."
        ;;
      esac
    fi
  done

  # Package the files
  cd $TMPLOGLOC || {
    echo -e "$TMPLOGLOC Doesnt Exist"
    exit 1
  }
  #  tar -zcvf Fontchanger_logs.tar.xz Fontchanger_logs >> $LOG
  $ZIP -r9v "Fontchanger_logs.zip" ./*

  # Copy package to internal storage
  cp -f $TMPLOGLOC/Fontchanger_logs.zip $FCDIR >>$LOG

  if [ -e $FCDIR/Fontchanger_logs.zip ]; then
    log_print "Fontchanger_logs.zip Created Successfully."
  else
    log_print "Archive File Not Created. Error in Script. Please contact John Fawkes"
  fi

  # Remove temporary directory
  #  rm -rf $TMPLOGLOC >> $LOG
  log_handler "Logs and information collected."
}
#######################################################################################################
#                                               HELP                                                  #
#######################################################################################################
help() {
  cat <<EOF
$MODTITLE $VER($REL)
by $AUTHOR
Copyright (C) 2019, John Fawkes @ xda-developers
License: GPLv3+

Usage: $_name
   or: $_name [options]...

Options:
  -a|--avfont [font name]     apply an avfont
  e.g., font_changer -a Font_UbuntuLight
  e.g., font_changer --font Font_UbuntuLight

  -c|--cemoji [custom emoji]  apply the custom emoji
  e.g., font_changer -c <name of custom emoji>
  e.g., font_changer --cemoji <name of custom emoji>
  
  -d|--cfont [custom font]    apply a custom font
  e.g., font_changer -d <name of custom font>
  e.g., font_changer --cfont <name of custom font>

  -e|--emoji [emoji]          apply an emoji
  e.g., font_changer -e <name of emoji>
  e.g., font_changer --emoji <name of emoji>

  -f|--font [font]            apply a font from downloadable list
  e.g., font_changer -f <name of font>
  e.g., font_changer --font <name of font>

  -h|--help                   show this message
  e.g., font_changer -h
  e.g., font_changer --help

  -m|--restoreemoji           restore just stock emoji but keep fontchanger font
  e.g., font_changer -m
  e.g., font_changer --restoreemoji

  -n|--restorefont            restore just stock font but keep fontchanger emoji
  e.g., font_changer -n
  e.g., font_changer --restorefont

  -r|--random                 apply a random font
  e.g., font_changer -r
  e.g., font_changer --random

  -s|--current                show current font
  e.g., font_changer -s
  e.g., font_changer --current
  
  -t|--randomav               apply a random avfont font
  e.g., font_changer -t
  e.g., font_changer --randomav

  -z|--delete                 delete downloaded font and emoji zips if they exist
  e.g., font_changer -z
  e.g., font_changer --delete

EOF
  exit
}

help_custom() {
  cat <<EOF
$MODTITLE $VER($REL)
by $AUTHOR
Copyright (C) 2019, John Fawkes @ xda-developers
License: GPLv3+
  Welcome to the How-to for FontChanger!
  This is the Folder Structure You Will Need to Follow
  In Order for FontChanger to Properly Detect and Apply Your Font!
  Note ------ /sdcard Equals Internal Storage

    |--Fontchanger/
            |--Fonts/
               |--Custom/
                  |--<font-folder-name>/
                         |--<font>.ttf
                         |--<font>.ttf
  
  You Need To Place Your Font Folders in /storage/emulated/0/Fontchanger/Fonts/Custom.
  The <font-folder-name> is the Name of the Font You Want to Apply.
  This Would be the Main Folder That Holds the ttf Files for That Font.
  The --<font>.ttf are the ttf Files For That Specific Font.
  You Can Have Multiple Font Folders Inside the Fontchanger/Fonts Folder.
  Inside the Folder that Has Your ttf Files Inside, You Need to Have 23 Font Files.
  The Script Will Not Pass Unless All 23 Files Exist! The Files You Need Are :
  GoogleSans-Bold.ttf 
  GoogleSans-BoldItalic.ttf 
  GoogleSans-Medium.ttf 
  GoogleSans-MediumItalic.ttf 
  GoogleSans-Regular.ttf 
  Roboto-Black.ttf 
  Roboto-BlackItalic.ttf 
  Roboto-Bold.ttf 
  Roboto-BoldItalic.ttf 
  RobotoCondensed-Bold.ttf 
  RobotoCondensed-BoldItalic.ttf 
  RobotoCondensed-Italic.ttf 
  RobotoCondensed-Light.ttf 
  RobotoCondensed-LightItalic.ttf 
  RobotoCondensed-Regular.ttf 
  Roboto-Italic.ttf 
  Roboto-Light.ttf 
  Roboto-LightItalic.ttf 
  Roboto-Medium.ttf 
  Roboto-MediumItalic.ttf 
  Roboto-Regular.ttf 
  Roboto-Thin.ttf 
  Roboto-ThinItalic.ttf
  You Can Find a Video Tutorial on How to make these Font Files on my website https://john-fawkes.com/fontchanger.HTML or if you can't access it for whatever reason you can go to https://www.youtube.com/watch?v=YLUl5X-uVZc and watch it there


  For the custom emojis you'll need to setup a directory in /storage/emulated/0/Fontchanger/Emojis/Custom
  
      |--Fontchanger/
            |--Emoji/
               |--Custom/
                |--<Emoji-folder-name>/
                        |--<font>.ttf
                        |--<font>.ttf
 
  The <emoji-folder-name> is the folder that will house your custom emoji file.
  The <font>.ttf are the emoji files. Usually named NotoColorEmoji.ttf.
EOF
  menu
}
#######################################################################################################
#                                         EMOJIS                                                      #
#######################################################################################################
apply_emoji() {
  echo -e "${B}Applying Emoji. Please Wait...${N}"
  $SLEEP 2
  emojichoice="$(grep -w $choice $MODPATH/emojilist.txt | tr -d '[' | tr -d ']' | tr -d $choice | tr -d ' ')"
  rm -f $MODPATH/product/fonts/*Emoji*.ttf
  rm -f $MODPATH/system/product/fonts/*Emoji*.ttf
  rm -f $MODPATH/system/fonts/*Emoji*.ttf
  [ -e $FCDIR/Emojis/$emojichoice.zip ] || $CURL -k -o "$FCDIR/Emojis/$emojichoice.zip" https://john-fawkes.com/Downloads/emoji/$emojichoice.zip
  mkdir -p $FCDIR/Emojis/$emojichoice
  unzip -o "$FCDIR/Emojis/$emojichoice.zip" -d $FCDIR/Emojis/$emojichoice
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Emojis/$emojichoice/NotoColorEmoji.ttf $MODPATH/product/fonts
    if [ -f $MIRROR/product/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/product/fonts/NotoColorEmoji.ttf $MODPATH/product/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/product/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/product/fonts/NotoColorEmoji.ttf $MODPATH/product/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Emojis/$emojichoice/NotoColorEmoji.ttf $MODPATH/system/product/fonts
    if [ -f $MIRROR/system/product/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/system/product/fonts/NotoColorEmoji.ttf $MODPATH/system/product/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/system/product/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/system/product/fonts/NotoColorEmoji.ttf $MODPATH/system/product/fonts/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Emojis/$emojichoice/NotoColorEmoji.ttf $MODPATH/system/fonts
    if [ -f $MIRROR/system/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/system/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  if [ -d $FCDIR/Emojis/$emojichoice ]; then
    rm -rf $FCDIR/Emojis/$emojichoice
  fi
  [ -f $CEMOJI ] || touch $CEMOJI
  truncate -s 0 $CEMOJI
  echo "CURRENT=$emojichoice" >>$CEMOJI
  if [ -e $MODPATH/product/fonts/NotoColorEmoji.ttf ] || [ -e $MODPATH/system/product/fonts/NotoColorEmoji.ttf ] || [ -e $MODPATH/system/fonts/NotoColorEmoji.ttf ]; then
    emoji_reboot_menu
  else
    echo -e "${R}[!] Emoji WAS NOT APPLIED [!]${N}"
    echo -e "${R} PLEASE TRY AGAIN${N}"
    $SLEEP 3
    clear
    emoji_menu
  fi
}

list_emoji() {
  num=1
  rm $MODPATH/emojilist.txt
  emojis=($(cat $FCDIR/emojis-list.txt | sed 's/.zip//'))
  touch $MODPATH/emojilist.txt
  for i in "${emojis[@]}"; do
    ProgressBar $num ${#emojis[@]}
    num=$((num + 1))
  done
}

emoji_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    clear
    list_emoji
    clear
    echo -e "$div"
    title_div "Emojis"
    echo -e "$div"
    echo -e " "
    num=1
    for emoji in "${emojis[@]}"; do
      echo -e "${W}[$num]${N} ${G}$emoji${N}" && echo -e " [$num] $emoji" >> $MODPATH/emojilist.txt
      num=$((num + 1))
    done
    echo -e " "
    wrong=$(cat $MODPATH/emojilist.txt | wc -l)
    echo -e "${G}[-] Please Choose an Emoji to Apply. Enter the Corresponding Number...${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    *)
      if [ $choice = "q" ]; then
        echo -e "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice = "r" ]; then
        return_menu
      elif [ $choice -le $wrong ]; then
        apply_emoji
      elif [[ -n ${choice//[0-9]/} ]]; then
        invalid
      else
        [ $choice -gt $wrong ] && invalid
      fi
      ;;
    esac
  done
}
#######################################################################################################
#                                         CUSTOM EMOJIS                                              #
#######################################################################################################
apply_custom_emoji() {
  echo -e "${B}Applying Custom Emoji Please Wait...${N}"
  $SLEEP 2
  cusemojichoice="$(grep -w $choice $MODPATH/customemojilist.txt | tr -d [ ] | tr -d $choice | tr -d ' ')"
  if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
    for i in $MODPATH/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        rm -f $i
      fi
    done
  fi
  if [ -d $MODPATH/system/product ]; then
    for i in $MODPATH/*/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        rm -f $i
      fi
    done
  fi
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Emojis/Custom/$cusemojichoice/NotoColorEmoji.ttf $MODPATH/product/fonts
    if [ -f $MIRROR/product/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/product/fonts/NotoColorEmoji.ttf $MODPATH/product/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/product/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/product/fonts/NotoColorEmoji.ttf $MODPATH/product/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Emojis/Custom/$cusemojichoice/NotoColorEmoji.ttf $MODPATH/system/product/fonts
    if [ -f $MIRROR/system/product/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/system/product/fonts/NotoColorEmoji.ttf $MODPATH/system/product/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/system/product/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/system/product/fonts/NotoColorEmoji.ttf $MODPATH/system/product/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Emojis/Custom/$cusemojichoice/NotoColorEmoji.ttf $MODPATH/system/fonts
    if [ -f $MIRROR/system/fonts/SamsungColorEmoji.ttf ]; then
      cp -f $MODPATH/system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/SamsungColorEmoji.ttf
    fi
    if [ -f $MIRROR/system/fonts/hTC_ColorEmoji.ttf ]; then
      cp -f $MODPATH/system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/hTC_ColorEmoji.ttf
    fi
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  [ -f $CEMOJI ] || touch $CEMOJI
  truncate -s 0 $CEMOJI
  echo "CURRENT=$cusemojichoice" >> $CEMOJI
  if [ -e $MODPATH/product/fonts/NotoColorEmoji.ttf ] || [ -e $MODPATH/system/product/fonts/NotoColorEmoji.ttf ] || [ -e $MODPATH/system/fonts/NotoColorEmoji.ttf ]; then
    emoji_reboot_menu
  else
    echo -e "${R}[!] Emoji WAS NOT APPLIED [!]${N}"
    echo -e "${R} PLEASE TRY AGAIN${N}"
    $SLEEP 3
    clear
    emoji_menu
  fi
}

list_custom_emoji() {
  num=1
  rm $MODPATH/customemojilist.txt
  touch $MODPATH/customemojilist.txt
  for i in $(find "$FCDIR/Emojis/Custom" | sort); do
    $SLEEP 0.1
    echo -e "[$num] $i" >> $MODPATH/customemojilist.txt && echo -e "${W}[$num]${N} ${B}$i${N}"
    num=$((num + 1))
  done
}

custom_emoji_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    for j in $FCDIR/Emojis/Custom/*; do
      if [ -d $j ]; then
        list_custom_emoji
        break
      else
        echo -e "${R}No Custom Fonts Found${N}"
        return_menu
      fi
    done
    wrong=$(cat $MODPATH/customemojilist.txt | wc -l)
    echo -e "${G}[-] Please Choose an Emoji to Apply. Enter the Corresponding Number...${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    *)
      if [ $choice = "q" ]; then
        echo -e "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice = "r" ]; then
        return_menu
      elif [ $choice -le $wrong ]; then
        apply_custom_emoji
      elif [[ -n ${choice//[0-9]/} ]]; then
        invalid
      else
        [ $choice -gt $wrong ] && invalid
      fi
      ;;
    esac
  done
}
#######################################################################################################
#                                         CUSTOM FONTS                                                #
#######################################################################################################
apply_custom_font() {
  echo -e "${B}Applying Custom Font Please Wait...${N}"
  $SLEEP 2
  choice2="$(grep -w $choice $MODPATH/customfontlist.txt | tr -d '[' | tr -d ']' | tr -d "$choice" | tr -d ' ')"
  cusfont=$(cat $MODPATH/listforcustom.txt)
  if [ -e $FCDIR/dump.txt ]; then
    truncate -s 0 $FCDIR/dump.txt
  else
    touch $FCDIR/dump.txt
  fi
  for i in "${cusfont[@]}"; do
    if [ -e $FCDIR/Fonts/Custom/$choice2/$i ]; then
      echo -e "$i found" >>$FCDIR/dump.txt && echo -e "${B}$i Found${N}"
    fi
    if [ ! -e $FCDIR/Fonts/Custom/$choice2/$i ]; then
      echo -e "$i NOT FOUND" >>$FCDIR/dump.txt && echo -e "${R}$i NOT FOUND${N}"
    fi
  done
  if grep -wq "NOT FOUND" $FCDIR/dump.txt; then
    abort "${R}Script Will Not Continue Until All ttf Files Exist!${N}"
  fi
  PASSED=true
  if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
    for i in $MODPATH/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system/product ]; then
    for i in $MODPATH/*/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system ]; then
    rm -rf $MODPATH/system
  fi
  if [ -d $MODPATH/product ]; then
    rm -rf $MODPATH/product
  fi
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Fonts/Custom/$choice2/* $MODPATH/product/fonts/
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Fonts/Custom/$choice2/* $MODPATH/system/product/fonts/
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Fonts/Custom/$choice2/* $MODPATH/system/fonts/
  fi
  for i in $MODPATH/*Emoji*.ttf; do
    if [ -e $i ]; then
      if [ -d $MIRROR/product/fonts ]; then
        mv -f $i $MODPATH/product/fonts
      fi
      if [ -d $MIRROR/system/product/fonts ]; then
        mv -f $i $MODPATH/system/product/fonts
      fi
      if [ -d $MIRROR/system/fonts ]; then
        mv -f $i $MODPATH/system/fonts
      fi
    fi
  done
  lg_device
  if [ -d $MIRROR/product/fonts ]; then
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  [ -f $CFONT ] || touch $CFONT
  truncate -s 0 $CFONT
  echo "CURRENT=$choice2" >>$CFONT
  if [ $PASSED == true ] && [ -d $MODPATH/product/fonts ] || [ -d $MODPATH/system/product/fonts ] || [ -d $MODPATH/system/fonts ]; then
    font_reboot_menu
  else
    retry
  fi
}

list_custom_fonts() {
  num=1
  rm $MODPATH/customfontlist.txt
  touch $MODPATH/customfontlist.txt
  for i in $(find "$FCDIR/Fonts/Custom/" -type d | sed 's#.*/##'); do
    $SLEEP 0.1
    echo -e "[$num] $i" >> $MODPATH/customfontlist.txt && echo -e "${W}[$num]${N} ${B}$i${N}"
    num=$((num + 1))
  done
}

custom_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    for j in $FCDIR/Fonts/Custom/*; do
      if [ -d $j ]; then
        list_custom_fonts
        break
      else
        echo -e "${R}No Custom Fonts Found${N}"
        return_menu
      fi
    done
    wrong=$(cat $MODPATH/customfontlist.txt | wc -l)
    echo -e "${G}[-] Please Choose a Font to Apply. Enter the Corresponding Number...${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    *)
      if [ $choice = "q" ]; then
        echo -e "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice = "r" ]; then
        return_menu
      elif [ $choice -le $wrong ]; then
        apply_custom_font
      elif [[ -n ${choice//[0-9]/} ]]; then
        invalid
      else
        [ $choice -gt $wrong ] && invalid
      fi
      ;;
    esac
  done
}
#######################################################################################################
#                                         DOWNLOADABLE FONTS                                          #
#######################################################################################################
apply_font() {
  choice2="$(grep -w $choice $MODPATH/fontlist.txt | tr -d '[' | tr -d ']' | tr -d "$choice" | tr -d ' ')"
  echo -e "${B}Applying Font. Please Wait...${N}"
  $SLEEP 2
  if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
    for i in $MODPATH/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system/product ]; then
    for i in $MODPATH/*/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system ]; then
    rm -rf $MODPATH/system
  fi
  if [ -d $MODPATH/product ]; then
    rm -rf $MODPATH/product
  fi
  [ -e $FCDIR/Fonts/$choice2.zip ] || $CURL -k -o "$FCDIR/Fonts/$choice2.zip" https://john-fawkes.com/Downloads/$choice2.zip
  mkdir -p $FCDIR/Fonts/$choice2
  unzip -o "$FCDIR/Fonts/$choice2.zip" -d $FCDIR/Fonts/$choice2
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Fonts/$choice2/* $MODPATH/product/fonts
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Fonts/$choice2/* $MODPATH/system/product/fonts
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Fonts/$choice2/* $MODPATH/system/fonts
  fi
  for i in $MODPATH/*Emoji*.ttf; do
    if [ -e $i ]; then
      if [ -d $MIRROR/product/fonts ]; then
        mv -f $i $MODPATH/product/fonts
      fi
      if [ -d $MIRROR/system/product/fonts ]; then
        mv -f $i $MODPATH/system/product/fonts
      fi
      if [ -d $MIRROR/system/fonts ]; then
        mv -f $i $MODPATH/system/fonts
      fi
    fi
  done
  lg_device
  if [ -d $FCDIR/Fonts/$choice2 ]; then
    rm -rf $FCDIR/Fonts/$choice2
  fi
  if [ -d $MIRROR/product/fonts ]; then
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  [ -f $CFONT ] || touch $CFONT
  truncate -s 0 $CFONT
  echo "CURRENT=$choice2" >>$CFONT
  if [ -d $MODPATH/product/fonts ]; then
    is_not_empty_font $MODPATH/product/fonts
  elif [ -d $MODPATH/system/product/fonts ]; then
    is_not_empty_font $MODPATH/system/product/fonts
  elif [ -d $MODPATH/system/fonts ]; then
    is_not_empty_font $MODPATH/system/fonts
  fi
}

list_fonts() {
  num=1
  rm $MODPATH/fontlist.txt
  fonts=($(cat $FCDIR/fonts-list.txt | sed 's/.zip//'))
  touch $MODPATH/fontlist.txt
  for i in "${fonts[@]}"; do
    ProgressBar $num ${#fonts[@]}
    num=$((num + 1))
  done
}

font_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    clear
    list_fonts
    clear
    echo -e "$div"
    title_div "Fonts"
    echo -e "$div"
    echo -e " "
    num=1
    for font in "${fonts[@]}"; do
      echo -e "${W}[$num]${N} ${G}$font${N}" && echo -e " [$num] $font" >> $MODPATH/fontlist.txt
      num=$((num + 1))
    done
    echo -e " "
    wrong=$(cat $MODPATH/fontlist.txt | wc -l)
    echo -e "${G}[-] Please Choose a Font to Apply. Enter the Corresponding Number...${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    *)
      if [ $choice = "q" ]; then
        echo -e "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice = "r" ]; then
        return_menu
      elif [ $choice -le $wrong ]; then
        apply_font
      elif [[ -n ${choice//[0-9]/} ]]; then
        invalid
      else
        [ $choice -gt $wrong ] && invalid
      fi
      ;;
    esac
  done
}
#######################################################################################################
#                                         AVFONTS DOWNLOAD FONTS                                      #
#######################################################################################################
apply_avfont() {
  choice2="$(grep -w $choice $MODPATH/avfontlist.txt | tr -d '[' | tr -d ']' | tr -d "$choice" | tr -d ' ')"
  echo -e "${B}Applying Font. Please Wait...${N}"
  $SLEEP 2
  if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
    for i in $MODPATH/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system/product ]; then
    for i in $MODPATH/*/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system ]; then
    rm -rf $MODPATH/system
  fi
  if [ -d $MODPATH/product ]; then
    rm -rf $MODPATH/product
  fi
  [ -e $FCDIR/Fonts/avfonts/$choice2.zip ] || $CURL -k -o "$FCDIR/Fonts/avfonts/$choice2.zip" https://john-fawkes.com/Downloads/avfonts/$choice2.zip
  mkdir -p $FCDIR/Fonts/avfonts/$choice2
  unzip -o "$FCDIR/Fonts/avfonts/$choice2.zip" -d $FCDIR/Fonts/avfonts/$choice2
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Fonts/avfonts/$choice2/* $MODPATH/product/fonts
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Fonts/avfonts/$choice2/* $MODPATH/system/product/fonts
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Fonts/avfonts/$choice2/* $MODPATH/system/fonts
  fi
  for i in $MODPATH/*Emoji*.ttf; do
    if [ -e $i ]; then
      if [ -d $MIRROR/product/fonts ]; then
        mv -f $i $MODPATH/product/fonts
      fi
      if [ -d $MIRROR/system/product/fonts ]; then
        mv -f $i $MODPATH/system/product/fonts
      fi
      if [ -d $MIRROR/system/fonts ]; then
        mv -f $i $MODPATH/system/fonts
      fi
    fi
  done
  lg_device
  if [ -d $FCDIR/Fonts/avfonts/$choice2 ]; then
    rm -rf $FCDIR/Fonts/avfonts/$choice2
  fi
  if [ -d $MIRROR/product/fonts ]; then
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  [ -f $CFONT ] || touch $CFONT
  truncate -s 0 $CFONT
  echo "CURRENT=AVfont-$choice2" >> $CFONT
  if [ -d $MODPATH/product/fonts ]; then
    is_not_empty_font $MODPATH/product/fonts
  elif [ -d $MODPATH/system/product/fonts ]; then
    is_not_empty_font $MODPATH/system/product/fonts
  elif [ -d $MODPATH/system/fonts ]; then
    is_not_empty_font $MODPATH/system/fonts
  fi
}

list_avfonts() {
  num=1
  rm $MODPATH/avfontlist.txt
  fonts=($(cat $FCDIR/avfonts-list.txt | sed 's/.zip//'))
  touch $MODPATH/avfontlist.txt
  for i in "${fonts[@]}"; do
    ProgressBar $num ${#fonts[@]}
    num=$((num + 1))
  done
}

avfont_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    clear
    list_avfonts
    clear
    echo -e "$div"
    title_div "avFonts"
    echo -e "$div"
    echo -e " "
    num=1
    for font in "${fonts[@]}"; do
      echo -e "${W}[$num]${N} ${G}$font${N}" && echo -e " [$num] $font" >>$MODPATH/avfontlist.txt
      num=$((num + 1))
    done
    echo -e " "
    wrong=$(cat $MODPATH/avfontlist.txt | wc -l)
    echo -e "${G}[-] Please Choose a Font to Apply. Enter the Corresponding Number...${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    *)
      if [ $choice = "q" ]; then
        echo -e "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice = "r" ]; then
        return_menu
      elif [ $choice -le $wrong ]; then
        apply_avfont
      elif [[ -n ${choice//[0-9]/} ]]; then
        invalid
      else
        [ $choice -gt $wrong ] && invalid
      fi
      ;;
    esac
  done
}
#######################################################################################################
#                                       Restore Stock Font                                            #
#######################################################################################################
default_menu() {
  choice=""
  emojichoice=""
  while [ "$choice" != "q" ] && [ "$emojichoice" != "q" ]; do
    echo -e "${G}Would You Like to Restore your Stock Font?${N}"
    echo -e " "
    echo -e "${B}[-] Select an Option...${N}"
    echo -e " "
    echo -e "${W}[Y]${N} ${G} - Yes${N}"
    echo -e " "
    echo -e "${W}[N]${N} ${G} - No${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    y)
      echo -e "${B}Restore Default Selected...${N}"
      for i in $MODPATH/system/fonts/*Emoji.ttf; do
        if [ -e "$i" ]; then
          mkdir -p $FCDIR/Emojis/Backups/system
          mv -f $i $FCDIR/Emojis/Backups/system
        fi
      done
      for i in $MODPATH/product/fonts/*Emoji.ttf; do
        if [ -e "$i" ]; then
          mkdir -p $FCDIR/Emojis/Backups/product
          mv -f $i $FCDIR/Emojis/Backups/product
        fi
      done
      for i in $MODPATH/system/product/fonts/*Emoji.ttf; do
        if [ -e "$i" ]; then
          mkdir -p $FCDIR/Emojis/Backups/system/product
          mv -f $i $FCDIR/Emojis/Backups/system/product
        fi
      done
      if [ -d $MODPATH/system ]; then
        rm -rf $MODPATH/system
      fi
      if [ -d $MODPATH/product ]; then
        rm -rf $MODPATH/product
      fi
      truncate -s 0 $CFONT
      ;;
    n)
      echo -e "${C}Keeping Modded Font...${N}"
      ;;
    q)
      echo -e "${R}[-] Quiting...${N}"
      clear
      quit
      ;;
    r)
      echo -e "${G}[-] Return to Menu Selected...${N}"
      ;;
    *)
      invaild
      $SLEEP 1.5
      ;;
    esac
    echo -e "${B}Would You like to Keep Your Emojis?${N}"
    echo -e " "
    echo -e "${B}[-] Select an Option...${N}"
    echo -e " "
    echo -e "${W}[Y]${N} ${G} - Yes${N}"
    echo -e " "
    echo -e "${W}[N]${N} ${G} - No${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r emojichoice
    case $(echo -e $emojichoice | tr '[:upper:]' '[:lower:]') in
    y)
      echo -e "${Y}Keeping Emojis${N}"
      if [ -f $FCDIR/Emojis/Backups/product/NotoColorEmoji.ttf ]; then
        mkdir -p $MODPATH/product/fonts
        mv -f $FCDIR/Emojis/Backups/product/*Emoji.ttf $MODPATH/product/fonts
      fi
      if [ -f $FCDIR/Emojis/Backups/system/product/NotoColorEmoji.ttf ]; then
        mkdir -p $MODPATH/system/product/fonts
        mv -f $FCDIR/Emojis/Backups/system/product/*Emoji.ttf $MODPATH/system/product/fonts
      fi
      if [ -f $FCDIR/Emojis/Backups/system/NotoColorEmoji.ttf ]; then
        mkdir -p $MODPATH/system/fonts
        mv -f $FCDIR/Emojis/Backups/system/*Emoji.ttf $MODPATH/system/fonts
      fi
      rm $FCDIR/Emojis/Backups
      break
      ;;
    n)
      echo -e "${R}Removing Emojis${N}"
      if [ -d $FCDIR/Emojis/Backups ]; then
        rm $FCDIR/Emojis/Backups
      fi
      for i in $MODPATH/system/fonts/*Emoji*; do
        if [ -e "$i" ]; then
          rm -f $i
        fi  
      done
      for i in $MODPATH/product/fonts/*Emoji*; do
        if [ -e "$i" ]; then
          rm -f $i
        fi
      done
      for i in $MODPATH/system/product/fonts/*Emoji*; do
        if [ -e "$i" ]; then
          rm -f $i
        fi
      done
      truncate -s 0 $CEMOJI
      break
      ;;
    q)
      echo -e "${R}[-] Quiting...${N}"
      clear
      quit
      ;;
    r)
      echo -e "${G}[-] Return to Menu Selected...${N}"
      ;;
    *)
      invaild
      $SLEEP 1.5
      ;;
    esac
  done
  return_menu
}
#######################################################################################################
#                                       User-Submitted Fonts                                          #
#######################################################################################################
apply_user_font() {
  choice2="$(grep -w $choice $MODPATH/userfontlist.txt | tr -d '[' | tr -d ']' | tr -d "$choice" | tr -d ' ')"
  echo -e "${B}Applying Font. Please Wait...${N}"
  $SLEEP 2
  if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
    for i in $MODPATH/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system/product ]; then
    for i in $MODPATH/*/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system ]; then
    rm -rf $MODPATH/system
  fi
  if [ -d $MODPATH/product ]; then
    rm -rf $MODPATH/product
  fi
  [ -e $FCDIR/Fonts/User/$choice2.zip ] || $CURL -k -o "$FCDIR/Fonts/User/$choice2.zip" https://john-fawkes.com/Downloads/User/$choice2.zip
  mkdir -p $FCDIR/Fonts/User/$choice2
  unzip -o "$FCDIR/Fonts/User/$choice2.zip" -d $FCDIR/Fonts/User/$choice2
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Fonts/User/$choice2/* $MODPATH/product/fonts
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Fonts/User/$choice2/* $MODPATH/system/product/fonts
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Fonts/User/$choice2/* $MODPATH/system/fonts
  fi
  for i in $MODPATH/*Emoji*.ttf; do
    if [ -e $i ]; then
      if [ -d $MIRROR/product/fonts ]; then
        mv -f $i $MODPATH/product/fonts
      fi
      if [ -d $MIRROR/system/product/fonts ]; then
        mv -f $i $MODPATH/system/product/fonts
      fi
      if [ -d $MIRROR/system/fonts ]; then
        mv -f $i $MODPATH/system/fonts
      fi
    fi
  done
  lg_device
  if [ -d $FCDIR/Fonts/User/$choice2 ]; then
    rm -rf $FCDIR/Fonts/User/$choice2
  fi
  if [ -d $MIRROR/product/fonts ]; then
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  [ -f $CFONT ] || touch $CFONT
  truncate -s 0 $CFONT
  echo "CURRENT=$choice2" >> $CFONT
  if [ -d $MODPATH/product/fonts ]; then
    is_not_empty_font $MODPATH/product/fonts
  elif [ -d $MODPATH/system/product/fonts ]; then
    is_not_empty_font $MODPATH/system/product/fonts
  elif [ -d $MODPATH/system/fonts ]; then
    is_not_empty_font $MODPATH/system/fonts
  fi
}

list_user_fonts() {
  num=1
  rm $MODPATH/userfontlist.txt
  fonts=($(cat $FCDIR/user-fonts-list.txt | sed 's/.zip//'))
  touch $MODPATH/userfontlist.txt
  for i in "${fonts[@]}"; do
    ProgressBar $num ${#fonts[@]}
    num=$((num + 1))
  done
}

user_font_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    clear
    list_user_fonts
    clear
    echo -e "$div"
    title_div "User-Submitted Fonts"
    echo -e " "
    num=1
    for font in "${fonts[@]}"; do
      echo -e "${W}[$num]${N} ${G}$font${N}" && echo -e " [$num] $font" >>$MODPATH/userfontlist.txt
      num=$((num + 1))
    done
    echo -e " "
    wrong=$(cat $MODPATH/userfontlist.txt | wc -l)
    echo -e "${G}[-] Please Choose a Font to Apply. Enter the Corresponding Number...${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    *)
      if [ $choice = "q" ]; then
        echo -e "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice = "r" ]; then
        return_menu
      elif [ $choice -le $wrong ]; then
        apply_user_font
      elif [[ -n ${choice//[0-9]/} ]]; then
        invalid
      else
        [ $choice -gt $wrong ] && invalid
      fi
      ;;
    esac
  done
}
#######################################################################################################
#                                        Update Emoji/Font Lists                                      #
#######################################################################################################
update_lists() {
  currVer=$(wget https://john-fawkes.com/Downloads/fontlist/fonts-list.txt --output-document - | wc -l)
  currVer2=$(wget https://john-fawkes.com/Downloads/emojilist/emojis-list.txt --output-document - | wc -l)
  currVer3=$(wget https://john-fawkes.com/Downloads/userfontlist/user-fonts-list.txt --output-document - | wc -l)
  currVer4=$(wget https://john-fawkes.com/Downloads/avfontlist/avfonts-list.txt --output-document - | wc -l)
  instVer=$(cat $FCDIR/fonts-list.txt | wc -l)
  instVer2=$(cat $FCDIR/emojis-list.txt | wc -l)
  instVer3=$(cat $FCDIR/user-fonts-list.txt | wc -l)
  instVer4=$(cat $FCDIR/avfonts-list.txt | wc -l)
  echo -e "${B}Checking For Updates...${N}"
  if [ $currVer -gt $instVer ] || [ $currVer -lt $instVer ]; then
    echo -e "${G}[-] Checking For Internet Connection... [-]${N}"
    test_connection3
    if ! "$CON3"; then
      test_connection2
      if ! "$CON2"; then
        test_connection
      fi
    fi
    if "$CON1" || "$CON2" || "$CON3"; then
      rm $FCDIR/fonts-list.txt
      mkdir -p $FCDIR/Fonts/Custom
      $CURL -k -o $FCDIR/fonts-list.txt https://john-fawkes.com/Downloads/fontlist/fonts-list.txt
      if [ $instVer != $currVer ]; then
        echo -e "${B}[-] Fonts Lists Downloaded Successfully... [-]${N}"
      else
        echo -e "${R}[!] Error Downloading Fonts Lists... [!]${N}"
      fi
    else
      abort "${R}[!] No Internet Detected... [!]${N}"
    fi
  else
    echo -e "${R}No Font List Updates Found${N}"
  fi
  if [ $currVer2 -gt $instVer2 ] || [ $currVer2 -lt $instVer2 ]; then
    echo -e "${B}[-] Checking For Internet Connection... [-]${N}"
    test_connection3
    if ! "$CON3"; then
      test_connection2
      if ! "$CON2"; then
        test_connection
      fi
    fi
    if "$CON1" || "$CON2" || "$CON3"; then
      rm $FCDIR/emojis-list.txt
      mkdir -p $FCDIR/Emojis/Custom
      $CURL -k -o $FCDIR/emojis-list.txt https://john-fawkes.com/Downloads/emojilist/emojis-list.txt
      if [ $instVer2 != $currVer2 ]; then
        echo -e "${B}[-] Emoji Lists Downloaded Successfully... [-]${N}"
      else
        echo -e "${R}[!] Error Downloading Emoji Lists... [!]${N}"
      fi
    else
      abort "${R}[!] No Internet Detected... [!]${N}"
    fi
  else
    echo -e "${R}No Emoji List Updates Found${N}"
  fi
  if [ $currVer3 -gt $instVer3 ] || [ $currVer3 -lt $instVer3 ]; then
    echo -e "${G}[-] Checking For Internet Connection... [-]${N}"
    test_connection3
    if ! "$CON3"; then
      test_connection2
      if ! "$CON2"; then
        test_connection
      fi
    fi
    if "$CON1" || "$CON2" || "$CON3"; then
      rm $FCDIR/user-fonts-list.txt
      mkdir -p $FCDIR/Fonts/User
      $CURL -k -o $FCDIR/user-fonts-list.txt https://john-fawkes.com/Downloads/userfontlist/user-fonts-list.txt
      if [ $instVer3 != $currVer3 ]; then
        echo -e "${B}[-] User Fonts Lists Downloaded Successfully... [-]${N}"
      else
        echo -e "${R}[!] Error Downloading User Fonts Lists... [!]${N}"
      fi
    else
      abort "${R}[!] No Internet Detected... [!]${N}"
    fi
  else
    echo -e "${R}No User List Updates Found${N}"
  fi
  if [ $currVer4 -gt $instVer4 ] || [ $currVer4 -lt $instVer4 ]; then
    echo -e "${G}[-] Checking For Internet Connection... [-]${N}"
    test_connection3
    if ! "$CON3"; then
      test_connection2
      if ! "$CON2"; then
        test_connection
      fi
    fi
    if "$CON1" || "$CON2" || "$CON3"; then
      rm $FCDIR/avfonts-list.txt
      mkdir -p $FCDIR/Fonts/avfonts
      $CURL -k -o $FCDIR/avfonts-list.txt https://john-fawkes.com/Downloads/avfontlist/avfonts-list.txt
      if [ $instVer4 != $currVer4 ]; then
        echo "${B}[-] avFonts Lists Downloaded Successfully... [-]${N}"
      else
        echo "${R}[!] Error Downloading User Fonts Lists... [!]${N}"
      fi
    else
      abort "${R}[!] No Internet Detected... [!]${N}"
    fi
  else
    echo "${R}No avFonts List Updates Found${N}"
  fi
}
#######################################################################################################
#                                        Delete Downloaded Zips                                       #
#######################################################################################################
font_clear_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    echo " "
    echo -e "${G}Would You Like to Delete the Downloaded Font Zips?${N}"
    echo -e " "
    echo -e "${B}[-] Select an Option...${N}"
    echo -e " "
    echo -e "${W}[Y]${N} ${G} - Yes${N}"
    echo -e " "
    echo -e "${W}[N]${N} ${G} - No${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
      y)
        echo -e "${Y}[-] Deleting Font Zips${N}"
        #            find $FCDIR/Fonts -depth -mindepth 1 -maxdepth 1 -type d ! -regex '^$FCDIR/Fonts/Custom\(/.*\)?' -type d ! -regex '^$FCDIR/Fonts/User\(/.*\)?' -type d ! -regex '^$FCDIR/Fonts/avfonts\(/.*\)?' -delete
        for i in $FCDIR/Fonts/*.zip; do
          rm -f $i
        done
        for i in $FCDIR/Fonts/*/*.zip; do
          rm -rf $i
        done
      ;;
      n)
        echo -e "${R}[-] Not Removing Fonts${N}"
      ;;
      q)
        echo -e "${R}[-] Quiting...${N}"
        clear
        quit
      ;;
      r)
        echo -e "${G}[-] Return to Menu Selected...${N}"
        return_menu
      ;;
      *)
        invaild
        $SLEEP 1.5
      ;;
    esac
  done
}

emoji_clear_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    echo " "
    echo -e "${G}[-] Would You Like to Delete the Downloaded Emoji Zips to Save Space?${N}"
    echo -e " "
    echo -e "${B}[-] Select an Option...${N}"
    echo -e " "
    echo -e "${W}[Y]${N} ${G} - Yes${N}"
    echo -e " "
    echo -e "${W}[N]${N} ${G} - No${N}"
    echo -e " "
    echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
      y)
        echo -e "${Y}[-] Deleting Emoji Zips${N}"
        #            find $FCDIR/Fonts -depth -mindepth 1 -maxdepth 1 -type d ! -regex '^$FCDIR/Fonts/Custom\(/.*\)?' -type d ! -regex '^$FCDIR/Fonts/User\(/.*\)?' -type d ! -regex '^$FCDIR/Fonts/avfonts\(/.*\)?' -delete
        for i in $FCDIR/Emojis/*.zip; do
          rm -f $i
        done
        for i in $FCDIR/Emojis/*/*.zip; do
          rm -rf $i
        done
      ;;
      n)
        echo -e "${R}[-] Not Removing Emojis${N}"
      ;;
      q)
        echo -e "${R}[-] Quiting...${N}"
        clear
        quit
      ;;
      r)
        echo -e "${G}[-] Return to Menu Selected...${N}"
        return_menu
      ;;
      *)
        invaild
        $SLEEP 1.5
      ;;
    esac
  done
}

clear_menu () {
  choice=""
  choice2=""
  while [ "$choice" != "q" ]; do
    CHECK=$(du -hs $FCDIR/Fonts/* | cut -c-4)
    CHECK2=$(du -hs $FCDIR/Emojis/* | cut -c-4)
    if is_not_empty $FCDIR/Fonts/*; then
      echo -e "${B}Checking Space...${N}"
      echo -e " "
      echo -e "${B}Your Font Zips are Taking Up $CHECK Space${N}"
      echo -e " "
      echo -e "${G}[-] Would You Like to Delete the Downloaded Font Zips to Save Space?${N}"
      echo -e " "
      echo -e "${B}[-] Select an Option...${N}"
      echo -e " "
      echo -e "${W}[Y]${N} ${G} - Yes${N}"
      echo -e " "
      echo -e "${W}[N]${N} ${G} - No${N}"
      echo -e " "
      echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
      echo -e " "
      echo -e "${R}[Q] - Quit${N}"
      echo -e " "
      echo -e "${B}[CHOOSE] : ${N}"
      echo -e " "
      read -r choice
      case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
        y)
          echo -e "${G}[-] Deleting Font Zips...${N}"
          font_clear_menu
        ;;
        n)
          echo -e "${R}[-] Not Removing Font Zips${N}"
        ;;
        r)
          echo -e "${B}[-] Return to Menu Selected...${N}"
          return_menu
        ;;
        q)
          echo -e "${R}[-] Quitting...${N}"
          clear
          quit
        ;;
        *)
          invalid
        ;;
      esac
    else
      echo -e "${R}[-] No Font Zips Found${N}"
    fi
    if is_not_empty $FCDIR/Emojis/*; then
      echo -e "${B}Checking Space...${N}"
      echo -e " "
      echo -e "${B}Your Emoji Zips are Taking Up $CHECK2 Space${N}"
      echo -e " "
      echo -e "${G}[-] Would You Like to Delete the Downloaded Emoji Zips to Save Space?${N}"
      echo -e " "
      echo -e "${B}[-] Select an Option...${N}"
      echo -e " "
      echo -e "${W}[Y]${N} ${G} - Yes${N}"
      echo -e " "
      echo -e "${W}[N]${N} ${G} - No${N}"
      echo -e " "
      echo -e "${W}[R]${N} ${G} - Return to Menu${N}"
      echo -e " "
      echo -e "${R}[Q] - Quit${N}"
      echo -e " "
      echo -e "${B}[CHOOSE] : ${N}"
      echo -e " "
      read -r choice
      case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
        y)
          echo -e "${G}[-] Deleting Emoji Zips...${N}"
          emoji_clear_menu
        ;;
        n)
          echo -e "${R}[-] Not Removing Emoji Zips${N}"
        ;;
        r)
          echo -e "${B}[-] Return to Menu Selected...${N}"
          return_menu
        ;;
        q)
          echo -e "${R}[-] Quitting...${N}"
          clear
          quit
        ;;
        *)
          invalid
        ;;
      esac
    else
      echo -e "${R}[-] No Emoji Zips Found${N}"
      return_menu
    fi
  done
  return_menu
}
#######################################################################################################
#                                             Random                                                  #
#######################################################################################################
random_menu() {
  choice=""
  choice2=""
  choice3=""
  while [ "$choice" != "q" ]; do
    FRANDOM="$(((RANDOM % 228) + 1))"
    echo -e "${G}Would You Like to Choose a Random Font?${N}"
    echo -e "${G}Please Enter (y)es or (n)o...${N}"
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    y)
      echo -e "${G}Applying Random Font...${N}"
      if [ -e $MODPATH/random.txt ]; then
        truncate -s 0 $MODPATH/random.txt
      else
        touch $MODPATH/random.txt
      fi
      echo -e $FRANDOM >> $MODPATH/random.txt
      choice="$(cat $MODPATH/random.txt)"
      choice3="$(sed -n ${choice}p $FCDIR/fonts-list.txt)"
      choice2="$(echo -e $choice3 | sed 's/.zip//')"
      #    choice2="$(sed -n ${choice}p $FCDIR/fonts-list.txt | tr -d '.zip')"
      $SLEEP 2
    if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
      for i in $MODPATH/*/*/*Emoji*.ttf; do
        if [ -e $i ]; then
          mv -f $i $MODPATH
        fi
      done
    fi
    if [ -d $MODPATH/system/product ]; then
      for i in $MODPATH/*/*/*/*Emoji*.ttf; do
        if [ -e $i ]; then
          mv -f $i $MODPATH
        fi
      done
    fi
      rm -rf $MODPATH/system
      rm -rf $MODPATH/product
      [ -e $FCDIR/Fonts/$choice2.zip ] || $CURL -k -o "$FCDIR/Fonts/$choice2.zip" https://john-fawkes.com/Downloads/$choice2.zip
      mkdir -p $FCDIR/Fonts/$choice2
      unzip -o "$FCDIR/Fonts/$choice2.zip" -d $FCDIR/Fonts/$choice2
      if [ -d $MIRROR/product/fonts ]; then
        mkdir -p $MODPATH/product/fonts
        cp -f $FCDIR/Fonts/$choice2/* $MODPATH/product/fonts
      fi
      if [ -d $MIRROR/system/product/fonts ]; then
        mkdir -p $MODPATH/system/product/fonts
        cp -f $FCDIR/Fonts/$choice2/* $MODPATH/system/product/fonts
      fi
      if [ -d $MIRROR/system/fonts ]; then
        mkdir -p $MODPATH/system/fonts
        cp -f $FCDIR/Fonts/$choice2/* $MODPATH/system/fonts
      fi
      for i in $MODPATH/*Emoji*.ttf; do
        if [ -e $i ]; then
          cp -f $i $MODPATH/product/fonts
          cp -f $i $MODPATH/system/product/fonts
          mv -f $i $MODPATH/system/fonts
        fi
      done
      lg_device
      if [ -d $FCDIR/Fonts/$choice2 ]; then
        rm -rf $FCDIR/Fonts/$choice2
      fi
      if [ -d $MIRROR/product/fonts ]; then
        set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
      fi
      if [ -d $MIRROR/system/product/fonts ]; then
        set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
      fi
      if [ -d $MIRROR/system/fonts ]; then
        set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
      fi
      [ -f $CFONT ] || touch $CFONT
      truncate -s 0 $CFONT
      echo "CURRENT=$choice2" >> $CFONT
      if [ -d $MODPATH/product/fonts ]; then
        is_not_empty_font $MODPATH/product/fonts
      elif [ -d $MODPATH/system/product/fonts ]; then
        is_not_empty_font $MODPATH/system/product/fonts
      elif [ -d $MODPATH/system/fonts ]; then
        is_not_empty_font $MODPATH/system/fonts
      fi
      ;;
    n)
      return_menu
      ;;
    *)
      invaild
      $SLEEP 1.5
      ;;
    esac
  done
}

random_av() {
  choice=""
  choice2=""
  choice3=""
  FRANDOM="$(( ( RANDOM % 63 )  + 1 ))"
  echo -e "${G}Applying Random AVFont...${N}"
  if [ -e $MODPATH/random.txt ]; then
    truncate -s 0 $MODPATH/random.txt
  else
    touch $MODPATH/random.txt
  fi
  echo $FRANDOM >> $MODPATH/random.txt
  choice="$(cat $MODPATH/random.txt)"
  choice3="$(sed -n ${choice}p $FCDIR/avfonts-list.txt)" 
  choice2="$(echo $choice3 | sed 's/.zip//')"
#    choice2="$(sed -n ${choice}p $FCDIR/fonts-list.txt | tr -d '.zip')"
  $SLEEP 2
  if [ -d $MODPATH/system ] || [ -d $MODPATH/product ]; then
    for i in $MODPATH/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system/product ]; then
    for i in $MODPATH/*/*/*/*Emoji*.ttf; do
      if [ -e $i ]; then
        mv -f $i $MODPATH
      fi
    done
  fi
  if [ -d $MODPATH/system ]; then
    rm -rf $MODPATH/system
  fi
  if [ -d $MODPATH/product ]; then
    rm -rf $MODPATH/product
  fi
  [ -e $FCDIR/Fonts/avfonts/$choice2.zip ] || $CURL -k -o "$FCDIR/Fonts/avfonts/$choice2.zip" https://john-fawkes.com/Downloads/avfonts/$choice2.zip
  mkdir -p $FCDIR/Fonts/$choice2
  unzip -o "$FCDIR/Fonts/$choice2.zip" -d $FCDIR/Fonts/$choice2
  if [ -d $MIRROR/product/fonts ]; then
    mkdir -p $MODPATH/product/fonts
    cp -f $FCDIR/Fonts/$choice2/* $MODPATH/product/fonts
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    mkdir -p $MODPATH/system/product/fonts
    cp -f $FCDIR/Fonts/$choice2/* $MODPATH/system/product/fonts
  fi
  if [ -d $MIRROR/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts
    cp -f $FCDIR/Fonts/$choice2/* $MODPATH/system/fonts
  fi
  for i in $MODPATH/*Emoji*.ttf; do
    if [ -e $i ]; then
      cp -f $i $MODPATH/product/fonts
      cp -f $i $MODPATH/system/product/fonts
      mv -f $i $MODPATH/system/fonts
    fi
  done
  lg_device
  if [ -d $FCDIR/Fonts/$choice2 ]; then
    rm -rf $FCDIR/Fonts/$choice2
  fi
  if [ -d $MIRROR/product/fonts ]; then
    set_perm_recursive $MODPATH/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/product/fonts ]; then
    set_perm_recursive $MODPATH/system/product/fonts 0 0 0755 0644
  fi
  if [ -d $MIRROR/system/fonts ]; then
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
  fi
  [ -f $CFONT ] || touch $CFONT
  truncate -s 0 $CFONT
  echo "CURRENT=AVfont-$choice2" >> $CFONT
  if [ -d $MODPATH/product/fonts ]; then
    is_not_empty_font $MODPATH/product/fonts
  elif [ -d $MODPATH/system/product/fonts ]; then
    is_not_empty_font $MODPATH/system/product/fonts
  elif [ -d $MODPATH/system/fonts ]; then
    is_not_empty_font $MODPATH/system/fonts
  fi
}
#######################################################################################################
#                                               Menus                                                 #
#######################################################################################################
choose_font_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    echo -e "${G}Which Font Option Would You Like to Choose?${N}"
    echo -e " "
    echo -e "${W}[1]${N} ${G} - List of Downloadable Fonts${N}"
    echo -e " "
    echo -e "${W}[2]${N} ${G} - Random Font${N}"
    echo -e " "
    echo -e "${W}[3]${N} ${G} - AVFonts${N}"
    echo -e " "
    echo -e "${W}[4]${N} ${G} - Random AVFont${N}"
    echo -e " "
    echo -e "${W}[5]${N} ${G} - User Submitted Fonts${N}"
    echo -e " "
    echo -e "${W}[6]${N} ${G} - Custom Fonts${N}"
    echo -e " "
    echo -e "${W}[R] - Return to Main Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    1)
      echo -e "${B}[-] Downloadable Fonts Selected...${N}"
      font_menu
      break
      ;;
    2)
      echo -e "${B}[-] Random Font Selected...${N}"
      random_menu
      ;;
    3)
      echo -e "${G}[-] AVFonts Fonts Selected...${N}"
      avfont_menu
      break
      ;;
    4)
      echo -e "${Y}[-] Random AVFont Selected...${N}"
      random_av
      ;;
    5)
      echo -e "${R}[-] User Submitted Fonts Selected...${N}"
      user_font_menu
      break
      ;;
    6)
      echo -e "${Y}[-] Custom Fonts Selected...${N}"
      custom_menu
      break
      ;;
    r)
      echo -e "${B}[-] Return to Menu Selected...${N}"
      clear
      menu
      break
      ;;
    q)
      echo -e "${R}[-] Quitting...${N}"
      clear
      quit
      ;;
    *)
      invalid
      ;;
    esac
  done
}

choose_emoji_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    echo -e "${G}Which Emoji Option Would You Like to Choose?${N}"
    echo -e " "
    echo -e "${W}[1]${N} ${G} - List of Downloadable Emojis${N}"
    echo -e " "
    echo -e "${W}[2]${N} ${G} - Custom Emojis${N}"
    echo -e " "
    echo -e "${W}[R] - Return to Main Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    1)
      echo -e "${B}[-] Downloadable Emojis Selected...${N}"
      emoji_menu
      break
      ;;
    2)
      echo -e "${Y}[-] Custom Emojis Selected...${N}"
      custom_emoji_menu
      break
      ;;
    r)
      echo -e "${B}[-] Return to Menu Selected...${N}"
      clear
      menu
      break
      ;;
    q)
      echo -e "${R}[-] Quitting...${N}"
      clear
      quit
      ;;
    *)
      invalid
      ;;
    esac
  done
}

choose_help_menu() {
  choice=""
  while [ "$choice" != "q" ]; do
    echo -e "${G}Which Help Option Would You Like to Choose?${N}"
    echo -e " "
    echo -e "${W}[1]${N} ${G} - Custom Font Help${N}"
    echo -e " "
    echo -e "${W}[2]${N} ${G} - Help with Shortcuts${N}"
    echo -e " "
    echo -e "${W}[R] - Return to Main Menu${N}"
    echo -e " "
    echo -e "${R}[Q] - Quit${N}"
    echo -e " "
    echo -e "${B}[CHOOSE] : ${N}"
    echo -e " "
    read -r choice
    case $(echo -e $choice | tr '[:upper:]' '[:lower:]') in
    1)
      echo -e "${R}[-] Custom Fonts Help Selected...${N}"
      help_custom
      break
      ;;
    2)
      echo -e "${Y}[-] Shortcut Flags Help Selected...${N}"
      help
      break
      ;;
    r)
      echo -e "${B}[-] Return to Menu Selected...${N}"
      clear
      menu
      break
      ;;
    q)
      echo -e "${R}[-] Quitting...${N}"
      clear
      quit
      ;;
    *)
      invalid
      ;;
    esac
  done
}
