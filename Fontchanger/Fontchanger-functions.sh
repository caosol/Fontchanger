invainvaild() {
  echo -e "${R}Invaild Option...${N}"
  clear
}

return_menu() {
  echo -n "${R}Return to menu? < y | n > : ${N}"
  read -r mchoice
  case $mchoice in
   y|Y) menu ;;
  n|N) clear && quit ;;
  *) invaild ;;
  esac
}

emoji_reboot_menu() {
  echo -e "${B}Emoji Applied Successfully...${N}"
  echo -e "${R}You Will Need to Reboot to Apply Changes${N}"
  echo -n "${R}Reboot? < y | n > : ${N}"
  read -r mchoice
  case $mchoice in
  y|Y) reboot ;;
  n|N) return_menu ;;
  *) invaild ;;
  esac
}

font_reboot_menu() {
  echo -e "${B}Font Applied Successfully...${N}"
  echo -e "${R}You Will Need to Reboot to Apply Changes${N}"
  echo -n "${R}Reboot? < y | n > : ${N}"
  read -r mchoice
  case $mchoice in
  y|Y) reboot ;;
  n|N) return_menu ;;
  *) invaild ;;
  esac
}

retry() {
  echo -e "${R}[!] FONT WAS NOT APPLIED [!]${N}"
  echo -e "${R} PLEASE TRY AGAIN${N}"
  sleep 3
  clear
}
#######################################################################################################
#                                               LOGGING                                               #
#######################################################################################################
# Loggers
LOGGERS="
$CACHELOC/magisk.log
$CACHELOC/magisk.log.bak
$MODPATH/${MODID}-install.log
$MODPATH/${MODID}.log
$MODPATH/${MODID}-old.log
$SDCARD/${MODID}-debug.log
/data/adb/magisk_debug.log
$MODPATH/${MODID}-verbose-old.log
$MODPATH/${MODID}-verbose.log
"

log_handler() {
  if [ $(id -u) == 0 ]; then
    echo "" >> $LOG 2>&1
    echo -e "$(date +"%m-%d-%Y %H:%M:%S") - $1" >> $LOG 2>&1
  fi
}

log_print() {
  echo "$1"
  log_handler "$1"
}

log_script_chk() {
  log_handler "$1"
  echo -e "$(date +"%m-%d-%Y %H:%M:%S") - $1" >> $LOG 2>&1
}

#Log Functions
# Saves the previous log (if available) and creates a new one
log_start() {
  if [ -f "$LOG" ]; then
    mv -f $LOG $oldLOG
  fi
  touch $LOG
  echo " " >> $LOG 2>&1
  echo "    *********************************************" >> $LOG 2>&1
  echo "    *              FontChanger                  *" >> $LOG 2>&1
  echo "    *********************************************" >> $LOG 2>&1
  echo "    *                 $VER                      *" >> $LOG 2>&1
  echo "    *              John Fawkes                  *" >> $LOG 2>&1
  echo "    *********************************************" >> $LOG 2>&1
  echo " " >> $LOG 2>&1
  log_script_chk "Log start."
}

collect_logs() {
  log_handler "Collecting logs and information."
  # Create temporary directory
  mkdir -pv $TMPLOGLOC >> $LOG 2>&1

# Saving the current prop values
  log_handler "RESETPROPS"
  echo "==========================================" >> $LOG 2>&1
  resetprop >> $LOG 2>&1
  log_print " Collecting Modules Installed "
  echo "==========================================" >> $LOG 2>&1
  ls /data/adb/modules >> $LOG 2>&1
  log_print " Collecting Logs for Installed Files "
  echo "==========================================" >> $LOG 2>&1
  log_handler "$(du -ah $MODPATH)" >> $LOG 2>&1
  echo "==========================================" >> $LOG 2>&1

  # Saving Magisk and module log files and device original build.prop
  for ITEM in $LOGGERS; do
    if [ -f "$ITEM" ]; then
      case "$ITEM" in
      *build.prop*)
        BPNAME="build_$(echo $ITEM | sed 's|\/build.prop||' | sed 's|.*\/||g').prop"
        ;;
      *)
        BPNAME=""
        ;;
      esac
      cp -af $ITEM ${TMPLOGLOC}/${BPNAME} >> $LOG 2>&1
    else
      case "$ITEM" in
      *$FCDIR)
          FCDIRLOCTMP=$FCDIR/Logs
        ITEMTPM=$(echo $ITEM | sed 's|$FCDIR|$FCDIRLOCTMP|')
        if [ -f "$ITEMTPM" ]; then
          cp -af $ITEMTPM $TMPLOGLOC >> $LOG 2>&1
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
  cd $FCDIR/Fontchanger_logs
#  tar -zcvf Fontchanger_logs.tar.xz Fontchanger_logs >> $LOG 2>&1
  zip -9v "Fontchanger_logs.zip" ./*

  # Copy package to internal storage
  cp -f $FCDIR/Fontchanger_logs/Fontchanger_logs.zip $SDCARD >> $LOG 2>&1

  if [ -e $SDCARD/Fontchanger_logs.zip ]; then
    log_print "Fontchanger_logs.zip Created Successfully."
  else
    log_print "Archive File Not Created. Error in Script. Please contact John Fawks"
  fi

  # Remove temporary directory
#  rm -rf $TMPLOGLOC >> $LOG 2>&1
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
  -a|--font [font name]         apply the font
    e.g., font_changer -a Font_UbuntuLight
    e.g., font_changer --font Font_UbuntuLight

  -d|--cfont [custom font]      apply the custom font
  e.g., font_changer -d <name of custom font>
  e.g., font_changer --cfont <name of custom font>
  
  -h|--help                     show this message
  e.g., font_changer -h
  e.g., font_changer --help

  -l|--listc                    list custom fonts
  e.g., font_changer -l
  e.g., font_changer --listc

  -m|--list                     list fonts <basically skips main menu>
  e.g., font_changer -m
  e.g., font_changer --list

  -s|--current                  show current font
  e.g., font_changer -s
  e.g., font_changer --current

EOF
exit
}

help_custom() {
  cat <<EOF
$MODTITLE $VER($REL)
by $AUTHOR
Copyright (C) 2019, John Fawkes @ xda-developers
License: GPLv3+
  Welcome to the How-to for FontChanger!${N}
  This is the Folder Structure You Will Need to Follow${N}
  In Order for FontChanger to Properly Detect and Apply Your Font!${N}
  Note ------ /sdcard Equals Internal Storage  ${N}


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
exit
}
#######################################################################################################
#                                         EMOJIS                                                      #
#######################################################################################################
apply_emoji() {
  echo -e "${B}Applying Emoji. Please Wait...${N}"
  sleep 2
  choice2="$(grep -w $choice $MODPATH/emojilist.txt | tr -d '[ ]' | tr -d $choice | tr -d ' ')"
  rm -f $MODPATH/system/fonts/*Emoji*.ttf >/dev/null 2>&1  
  if [ ! -d $MODPATH/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
  fi
  [ -e $FCDIR/Emojis/$choice2.zip ] || curl -k -o "$FCDIR/Emojis/$choice2.zip" https://john-fawkes.com/Downloads/emoji/$choice2.zip
  mkdir -p $FCDIR/Emojis/$choice2 >/dev/null 2>&1
  unzip -o "$FCDIR/Emojis/$choice2.zip" 'system/*' -d $FCDIR/Emojis/$choice2 >&2
  mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
  cp -rf $FCDIR/Emojis/$choice2/* $MODPATH
  if [ -f $MIRROR/system/fonts/SamsungColorEmoji.ttf ]; then
    cp -f $MODPATH/system/fonts/*Emoji*.ttf $MODPATH/system/fonts/SamsungColorEmoji.ttf
  fi
  if [ -f $MIRROR/system/fonts/hTC_ColorEmoji.ttf ]; then
    cp -f $MODPATH/system/fonts/*Emoji*.ttf $MODPATH/system/fonts/hTC_ColorEmoji.ttf
  fi
  set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644 >/dev/null 2>&1
  [ -f $CEMOJI ] || touch $CEMOJI
  truncate -s 0 $CEMOJI
  echo -n "CURRENT=$choice2" >> $CEMOJI
  if [ -d $MODPATH/system/fonts ] && [ -e $MODPATH/system/fonts/*Emoji*.ttf ]; then
    font_reboot_menu
  else
    echo -e "${R}[!] Emoji WAS NOT APPLIED [!]${N}"
    echo -e "${R} PLEASE TRY AGAIN${N}"
    sleep 3
    clear
    emoji_menu
  fi
}

list_emoji() {
  num=1
  rm $MODPATH/emojilist.txt >/dev/null 2>&1
  emojis=($(cat $FCDIR/emojis-list.txt | sed 's/.zip//'))
  touch $MODPATH/emojilist.txt >/dev/null 2>&1
  for i in ${emojis[@]}; do
    ProgressBar $num ${#emojis[@]}
    num=$((num + 1))
  done
}

emoji_menu() {
  clear
  list_emoji
  clear
  echo "$div"
  title_div "Emojis"
  echo "$div"
  echo ""
  num=1
  for emoji in ${emojis[@]}; do
    echo -e "${W}[$num]${N} ${G}$emoji${N}" && echo " [$num] $emoji" >> $MODPATH/emojilist.txt
    num=$((num + 1))
  done
  echo ""
  wrong=$(cat $MODPATH/emojilist.txt | wc -l)
  echo -e "${G}Please Choose an emoji to Apply. Enter the Corresponding Number...${N}"
  read -r choice
  case $choice in
  $choice)
    if [ $choice == "q" ]; then
      echo "${R}Quiting...${N}"
      clear
      quit
    elif [ $choice -gt $wrong ]; then
      echo "${Y}[!] Item Not Available! Try Again... [!]${N}"
      sleep 1.5
      clear
    else
      apply_emoji
    fi
  ;;
  esac
}
#######################################################################################################
#                                         CUSTOM EMOJIS                                              #
#######################################################################################################
apply_custom_emoji() {
  echo -e "${B}Applying Emoji. Please Wait...${N}"
  sleep 2
  choice2="$(grep -w $choice $MODPATH/customemojilist.txt | tr -d '[ ]' | tr -d $choice | tr -d ' ')"
  rm -f $MODPATH/system/fonts/*Emoji*.ttf >/dev/null 2>&1
  if [ ! -d $MODPATH/system/fonts ]; then
    mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
  fi
  cp -f $FCDIR/Emojis/Custom/$choice2/* $MODPATH/system/fonts
  if [ -f $MIRROR/system/fonts/SamsungColorEmoji.ttf ]; then
    cp -f $MODPATH/system/fonts/*Emoji*.ttf $MODPATH/system/fonts/SamsungColorEmoji.ttf
  fi
  if [ -f $MIRROR/system/fonts/hTC_ColorEmoji.ttf ]; then
    cp -f $MODPATH/system/fonts/*Emoji*.ttf $MODPATH/system/fonts/hTC_ColorEmoji.ttf
  fi
  set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644 >/dev/null 2>&1
  [ -f $CEMOJI ] || touch $CEMOJI
  truncate -s 0 $CEMOJI
  echo -n "CURRENT=$choice2" >> $CEMOJI
  if [ -d $MODPATH/system/fonts ] && [ -f $MODPATH/system/fonts/*Emoji*.ttf ]; then
    font_reboot_menu
  else
    echo -e "${R}[!] Emoji WAS NOT APPLIED [!]${N}"
    echo -e "${R} PLEASE TRY AGAIN${N}"
    sleep 3
    clear
    emoji_menu
  fi
}

list_custom_emoji() {
  num=1
  rm $MODPATH/customemojilist.txt >/dev/null 2>&1
  touch $MODPATH/customemojilist.txt >/dev/null 2>&1
  for i in $(ls "$FCDIR/Emojis/Custom" | sort); do
    sleep 0.1
    echo -e "[$num] $i" >> $MODPATH/customemojilist.txt && echo "${W}[$num]${N} ${B}$i${N}"
    num=$((num + 1))
  done
}


custom_emoji_menu() {
  if [ $(ls -A $FCDIR/Emojis/Custom) ]; then
    list_custom_emoji
    wrong=$(cat $MODPATH/customemojilist.txt | wc -l)
    echo -e "${G}Please Choose an Emoji to Apply. Enter the Corresponding Number...${N}"
    read -r choice
    case $choice in
    $choice)
      if [ $choice == "q" ]; then
        echo "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice -gt $wrong ]; then
        echo "${Y}[!] Item Not Available! Try Again... [!]${N}"
        sleep 1.5
        clear
      else
        apply_custom_emoji
      fi
    ;;
    esac
  else
    echo "${R}No Custom Fonts Found${N}"
    return_menu
  fi
}
#######################################################################################################
#                                         CUSTOM FONTS                                                #
#######################################################################################################
apply_custom_font() {
  echo "${B}Applying Custom Font...${N}"
  choice2="$(grep -w $choice $MODPATH/customfontlist.txt | tr -d '[ ]' | tr -d $choice | tr -d ' ')"
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
    retry
  fi
}

list_custom_fonts() {
  num=1
  rm $MODPATH/customfontlist.txt >/dev/null 2>&1
  touch $MODPATH/customfontlist.txt >/dev/null 2>&1
  for i in $(ls "$FCDIR/Fonts/Custom" | sort); do
    sleep 0.1
    echo -e "[$num] $i" >> $MODPATH/customfontlist.txt && echo "${W}[$num]${N} ${B}$i${N}"
    num=$((num + 1))
  done
}

custom_menu() {
  if [ $(ls -A "$FCDIR/Fonts/Custom") ]; then
    list_custom_fonts
    wrong=$(cat $MODPATH/customfontlist.txt | wc -l)
    echo -e "${G}Please Choose a Font to Apply. Enter the Corresponding Number...${N}"
    read -r choice
    case $choice in
    $choice)
      if [ $choice == "q" ]; then
        echo "${R}Quiting...${N}"
        clear
        quit
      elif [ $choice -gt $wrong ]; then
        echo "${Y}[!] Item Not Available! Try Again... [!]${N}"
        sleep 1.5
        clear
      else
        apply_custom_font
      fi
    ;;
    esac
  else
    echo "${R}No Custom Fonts Found${N}"
    return_menu
  fi
}
#######################################################################################################
#                                         DOWNLOADABLE FONTS                                          #
#######################################################################################################
apply_font() {
  choice2="$(grep -w $choice $MODPATH/fontlist.txt | tr -d '[ ]' | tr -d $choice | tr -d ' ')"
  echo -e "${B}Applying Font. Please Wait...${N}"
  sleep 2
  for i in $MODPATH/system/fonts/*Emoji*.ttf; do
    if [ -e "$i" ]; then
      mv -f $i $MODPATH
    fi
  done
  rm -rf $MODPATH/system/fonts >/dev/null 2>&1
  mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
  [ -e $FCDIR/Fonts/$choice2.zip ] || curl -k -o "$FCDIR/Fonts/$choice2.zip" https://john-fawkes.com/Downloads/$choice2.zip
  mkdir -p $FCDIR/Fonts/$choice2 >/dev/null 2>&1
  unzip -o "$FCDIR/Fonts/$choice2.zip" 'system/*' -d $FCDIR/Fonts/$choice2 >&2
  mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
  cp -rf $FCDIR/Fonts/$choice2/system/fonts $MODPATH/system
  for i in $MODPATH/*Emoji*.ttf; do
    if [ -e "$i" ]; then
      mv -f $i $MODPATH/system/fonts
    fi
  done
  set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644 >/dev/null 2>&1
  [ -f $CFONT ] || touch $CFONT
  truncate -s 0 $CFONT
  echo -n "CURRENT=$choice2" >>$CFONT
  if [ -f "$FCDIR/Fonts/$choice2.zip" ] && [ -d $MODPATH/system/fonts ]; then
    font_reboot_menu
  else
    retry
  fi
}

list_fonts() {
  num=1
  rm $MODPATH/fontlist.txt >/dev/null 2>&1
  fonts=($(cat $FCDIR/fonts-list.txt | sed 's/.zip//'))
  touch $MODPATH/fontlist.txt >/dev/null 2>&1
  for i in ${fonts[@]}; do
    ProgressBar $num ${#fonts[@]}
    num=$((num + 1))
  done
}

font_menu() {
  clear
  list_fonts
  clear
  echo "$div"
  title_div "Fonts"
  echo "$div"
  echo ""
  num=1
  for font in ${fonts[@]}; do
    echo -e "${W}[$num]${N} ${G}$font${N}" && echo " [$num] $font" >>$MODPATH/fontlist.txt
  num=$((num + 1))
  done
  echo ""
  wrong=$(cat $MODPATH/fontlist.txt | wc -l)
  echo -e "${G}Please Choose a Font to Apply. Enter the Corresponding Number...${N}"
  read -r choice
  case $choice in
  $choice)
    if [ $choice == "q" ]; then
      echo "${R}Quiting...${N}"
      clear
      quit
    elif [ $choice -gt $wrong ]; then
      echo "${Y}[!] Item Not Available! Try Again... [!]${N}"
      sleep 1.5
      clear
    else
      apply_font
    fi
  ;;
  esac
}
#######################################################################################################
#                                       Restore Stock Font                                            #
#######################################################################################################
default_menu() {
  echo -e "${G}Would You Like to Restore your Default Font?${N}"
  echo -e "${G}Please Enter (y)es or (n)o...${N}"
  read -r choice
  case $choice in
  y|yes)
    echo -e "${B}Restore Default Selected...${N}"
    for i in $MODPATH/system/fonts/*Emoji*.ttf; do
      if [ -e "$i" ]; then
        echo -e "${B}Would You like to Keep Your Emojis?${N}"
        echo -e "${B}Please Enter (y)es or (n)o...${N}"
        read -r emojichoice
        case $emojichoice in
        y|yes)
          echo -e "${Y}Backing up Emojis${N}"
          mkdir -p $FCDIR/Emojis/Backups >/dev/null 2>&1
          mv -f $i $FCDIR/Emojis/Backups >/dev/null 2>&1
        ;;
        n|no)
          echo -e "${R}Removing Emojis${N}"
          truncate -s 0 $CEMOJI
        ;;
        esac
      fi
    done
    rm -rf $MODPATH/system >/dev/null 2>&1
    for i in $FCDIR/Emojis/Backups/*Emoji*.ttf; do
      if [ -e "$i" ]; then
        mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
        mv -f $i $MODPATH/system/fonts >/dev/null 2>&1
      fi
    done
    rm $FCDIR/Emojis/Backups  >/dev/null 2>&1
    truncate -s 0 $CFONT
  ;;
  n|no)
    echo -e "${C}Keeping Modded Font...${N}"
  ;;
  *)  
    invaild
    sleep 1.5
  ;;
  esac
  return_menu
}
#######################################################################################################
#                                       User-Submitted Fonts                                          #
#######################################################################################################
apply_user_font() {
  choice2="$(grep -w $choice $MODPATH/userfontlist.txt | tr -d '[ ]' | tr -d $choice | tr -d ' ')"
  echo -e "${B}Applying Font. Please Wait...${N}"
  sleep 2
  for i in $MODPATH/system/fonts/*Emoji*.ttf; do
    if [ -e "$i" ]; then
      mv -f $i $MODPATH
    fi
  done
  rm -rf $MODPATH/system/fonts >/dev/null 2>&1
  mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
  [ -e $FCDIR/Fonts/User/$choice2.zip ] || curl -k -o "$FCDIR/Fonts/User/$choice2.zip" https://john-fawkes.com/Downloads/User/$choice2.zip
  mkdir -p $FCDIR/Fonts/User/$choice2 >/dev/null 2>&1
  unzip -o "$FCDIR/Fonts/User/$choice2.zip" 'system/*' -d $FCDIR/Fonts/$choice2 >&2
  mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
  cp -rf $FCDIR/Fonts/User/$choice2/system/fonts $MODPATH/system
  for i in $MODPATH/*Emoji*.ttf; do
    if [ -e "$i" ]; then
      mv -f $i $MODPATH/system/fonts
    fi
  done
  set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644 >/dev/null 2>&1
  [ -f $CFONT ] || touch $CFONT
  truncate -s 0 $CFONT
  echo -n "CURRENT=$choice2" >>$CFONT
  if [ -f "$FCDIR/Fonts/User/$choice2.zip" ] && [ -d $MODPATH/system/fonts ]; then
    font_reboot_menu
  else
    retry
  fi
}

list_user_fonts() {
  num=1
  rm $MODPATH/userfontlist.txt >/dev/null 2>&1
  fonts=($(cat $FCDIR/user-fonts-list.txt | sed 's/.zip//'))
  touch $MODPATH/userfontlist.txt >/dev/null 2>&1
  for i in ${fonts[@]}; do
    ProgressBar $num ${#fonts[@]}
    num=$((num + 1))
  done
}

user_font_menu() {
  clear
  list_fonts
  clear
  echo "$div"
  title_div "User-Submitted Fonts"
  echo ""
  num=1
  for font in ${fonts[@]}; do
    echo -e "${W}[$num]${N} ${G}$font${N}" && echo " [$num] $font" >>$MODPATH/userfontlist.txt
    num=$((num + 1))
  done
  echo ""
  wrong=$(cat $MODPATH/userfontlist.txt | wc -l)
  echo -e "${G}Please Choose a Font to Apply. Enter the Corresponding Number...${N}"
  read -r choice
  case $choice in
  $choice)
    if [ $choice == "q" ]; then
      echo "${R}Quiting...${N}"
      clear
      quit
    elif [ $choice -gt $wrong ]; then
      echo "${Y}[!] Item Not Available! Try Again... [!]${N}"
      sleep 1.5
      clear
    else
      apply_user_font
    fi
  ;;
  esac
}
#######################################################################################################
#                                        Update Emoji/Font Lists                                      #
#######################################################################################################
update_lists() {
  currVer=$(wget https://john-fawkes.com/Downloads/fontlist/fonts-list.txt --output-document - | wc -l)
  currVer2=$(wget https://john-fawkes.com/Downloads/emojilist/emojis-list.txt --output-document - | wc -l)
  currVer3=$(wget https://john-fawkes.com/Downloads/userfontlist/user-fonts-list.txt --output-document - | wc -l)
  instVer=$(cat $FCDIR/fonts-list.txt | wc -l)
  instVer2=$(cat $FCDIR/emojis-list.txt | wc -l)
  instVer3=$(cat $FCDIR/user-fonts-list.txt | wc -l)
  echo -e "${B}Checking For Updates...${N}"
  if [ $currVer -gt $instVer ] || [ $currVer -lt $instVer ]; then
    echo " [-] Checking For Internet Connection... [-] "
    test_connection3
    if ! "$CON3"; then
      test_connection2
      if ! "$CON2"; then
        test_connection
      fi
    fi
    if "$CON1" || "$CON2" || "$CON3"; then
      rm $FCDIR/fonts-list.txt >/dev/null 2>&1
      mkdir -p $FCDIR/Fonts/Custom >/dev/null 2>&1
      curl -k -o $FCDIR/fonts-list.txt https://john-fawkes.com/Downloads/fontlist/fonts-list.txt
      if [ $instVer != $currVer ]; then
        echo " [-] Fonts Lists Downloaded Successfully... [-] "
      else
        echo " [!] Error Downloading Fonts Lists... [!] "
      fi
    else
      abort " [!] No Internet Detected... [!] "
    fi
  else
    echo "${R}No Font List Updates Found${N}"
  fi
  if [ $currVer2 -gt $instVer2 ] || [ $currVer2 -lt $instVer2 ]; then
    echo " [-] Checking For Internet Connection... [-] "
    test_connection3
    if ! "$CON3"; then
      test_connection2
      if ! "$CON2"; then
        test_connection
      fi
    fi
    if "$CON1" || "$CON2" || "$CON3"; then
      rm $FCDIR/emojis-list.txt >/dev/null 2>&1
      mkdir -p $FCDIR/Emojis/Custom >/dev/null 2>&1
      curl -k -o $FCDIR/emojis-list.txt https://john-fawkes.com/Downloads/emojilist/emojis-list.txt
      if [ $instVer2 != $currVer2 ]; then
        echo " [-] Emoji Lists Downloaded Successfully... [-] "
      else
        echo " [!] Error Downloading Emoji Lists... [!] "
      fi
    else
      abort " [!] No Internet Detected... [!] "
    fi
  else
    echo "${R}No Emoji List Updates Found${N}"
  fi
  if [ $currVer3 -gt $instVer3 ] || [ $currVer3 -lt $instVer3 ]; then
    echo " [-] Checking For Internet Connection... [-] "
    test_connection3
    if ! "$CON3"; then
      test_connection2
      if ! "$CON2"; then
        test_connection
      fi
    fi
    if "$CON1" || "$CON2" || "$CON3"; then
      rm $FCDIR/user-fonts-list.txt >/dev/null 2>&1
      mkdir -p $FCDIR/Fonts/User >/dev/null 2>&1
      curl -k -o $FCDIR/user-fonts-list.txt https://john-fawkes.com/Downloads/userfontlist/user-fonts-list.txt
      if [ $instVer3 != $currVer3 ]; then
        echo " [-] User Fonts Lists Downloaded Successfully... [-] "
      else
        echo " [!] Error Downloading User Fonts Lists... [!] "
      fi
    else
      abort " [!] No Internet Detected... [!] "
    fi
  else
    echo "${R}No User List Updates Found${N}"
  fi
}
#######################################################################################################
#                                        Delete Downloaded Zips                                       #
#######################################################################################################
clear_menu() {
  CHECK=$(du -hs $FCDIR/Fonts | cut -c-4)
  CHECK2=$(du -hs $FCDIR/Emojis | cut -c-4)
  echo -e "${G}Would You Like to Delete the Downloaded Font Zips to Save Space?${N}"
  echo -e "${G}Please Enter (y)es or (n)o...${N}"
  read -r choice
  case $choice in
  y|yes)
    echo -e "${B}Checking Space...${N}"
    sleep 3
    echo "${G}$CHECK${N}"
    echo "${B}Your Font Zips are Taking Up $CHECK Space${N}"
    echo "${B}Would You Like to Delete the Font Zips to Save Space?${N}"
    read -r choice2
    case $choice2 in
    y|yes)
      echo -e "${Y}Deleting Font Zips${N}"
      rm -rf $FCDIR/Fonts/* >/dev/null 2>&1
    ;;
    n|no)
      echo -e "${R}Not Removing Fonts${N}"
    ;;
    esac
  ;;
  n|no)
    echo -e "${C}Not Removing Fonts${N}"
  ;;
  *)
    invaild
    sleep 1.5
  ;;
  esac
  echo -e "${G}Would You Like to Delete the Downloaded Emoji Zips to Save Space?${N}"
  echo -e "${G}Please Enter (y)es or (n)o...${N}"
  read -r choice3
  case $choice3 in
  y|yes)
    echo -e "${B}Checking Space...${N}"
    sleep 3
    echo "${G}$CHECK2${N}"
    echo "${B}Your Emoji Zips are Taking Up $CHECK2 Space${N}"
    echo "${B}Would You Like to Delete the Emoji Zips to Save Space?${N}"
    read -r choice4
    case $choice4 in
    y|yes)
      echo -e "${Y}Deleting Emoji Zips${N}"
      rm -rf $FCDIR/Emojis/* >/dev/null 2>&1
    ;;
    n|no)
      echo -e "${R}Not Removing Emojis${N}"
    ;;
    esac
  ;;
  n|no)
    echo -e "${C}Not Removing Emojis${N}"
  ;;
  *)
    invaild
    sleep 1.5
  ;;
  esac
  return_menu
}
#######################################################################################################
#                                             Random                                                  #
#######################################################################################################
random_menu() {
  FRANDOM="$(( ( RANDOM % 228 )  + 1 ))"
  echo -e "${G}Would You Like to Choose a Random Font?${N}"
  echo -e "${G}Please Enter (y)es or (n)o...${N}"
  read -r choice
  case $choice in
  y|yes)
    echo "${G}Random Font selected...${N}"
    echo "${G}Applying Random Font...${N}"
    if [ -e $MODPATH/random.txt ]; then
      truncate -s 0 $MODPATH/random.txt
    else
      touch $MODPATH/random.txt
    fi
    echo $FRANDOM >> $MODPATH/random.txt
    choice="$(cat $MODPATH/random.txt)"
    choice3="$(sed -n ${choice}p $FCDIR/fonts-list.txt)" 
    choice2="$(echo $choice3 | sed 's/.zip//')"
#    choice2="$(sed -n ${choice}p $FCDIR/fonts-list.txt | tr -d '.zip')"
    sleep 2
    for i in $MODPATH/system/fonts/*Emoji*.ttf; do
      if [ -e "$i" ]; then
      mv -f $i $MODPATH
      fi
    done
    rm -rf $MODPATH/system/fonts >/dev/null 2>&1
    mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
    [ -e $FCDIR/Fonts/$choice2.zip ] || curl -k -o "$FCDIR/Fonts/$choice2.zip" https://john-fawkes.com/Downloads/$choice2.zip
    mkdir -p $FCDIR/Fonts/$choice2 >/dev/null 2>&1
    unzip -o "$FCDIR/Fonts/$choice2.zip" 'system/*' -d $FCDIR/Fonts/$choice2 >&2
    mkdir -p $MODPATH/system/fonts >/dev/null 2>&1
    cp -rf $FCDIR/Fonts/$choice2/system/fonts $MODPATH/system
    for i in $MODPATH/*Emoji*.ttf; do
      if [ -e "$i" ]; then
        mv -f $i $MODPATH/system/fonts
      fi
    done
    set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644 >/dev/null 2>&1
    [ -f $CFONT ] || touch $CFONT
    truncate -s 0 $CFONT
    echo -n "CURRENT=$choice2" >>$CFONT
    if [ -f "$FCDIR/Fonts/$choice2.zip" ] && [ -d $MODPATH/system/fonts ]; then
      font_reboot_menu
    else
      retry
    fi
  ;;
  n|no)
    return_menu
  ;;
  *)
    invaild
    sleep 1.5
  ;;
  esac
}