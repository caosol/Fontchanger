##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "*******************************"
  ui_print "          Font Changer         "
  ui_print "*******************************"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  chmod 0755 $TMPDIR/busybox-$ARCH32
  ui_print " [-] Checking For Internet Connection..."
if $BOOTMODE; then
    test_connection3
  if [ $? -eq 0 ]; then
    rm /storage/emulated/0/Fontchanger/fonts-list.txt
    mkdir -p /storage/emulated/0/Fontchanger/Fonts/Custom
    chmod 0755 $TMPDIR/curl-$ARCH32
    $TMPDIR/curl-$ARCH32 -k -o /storage/emulated/0/Fontchanger/fonts-list.txt https://john-fawkes.com/Downloads/fontlist/fonts-list.txt
    if [ -f /storage/emulated/0/Fontchanger/fonts-list.txt ]; then
      ui_print " [-] Font List Downloaded Successfully..."
    else
      ui_print " [!] Error Downloading Font List [!]..."
    fi
  else
    cancel " [!] No Internet Detected [!]..."
  fi
else
  cancel " [-] TWRP Install NOT Supported. Please Install Booted with Internet Connection... "
fi
  imageless_magisk || sed -i "s|MODPATH=/data/adb/modules|MODPATH=/sbin/.magisk/img|" $MODPATH/system/bin/font_changer
  cp -f $TMPDIR/curl-$ARCH32 $MODPATH/curl
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases


set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/system/bin/font_changer 0 2000 0755
  set_perm $MODPATH/curl 0 2000 0755
  
  ui_print " "
  ui_print " [-] After Installing type font_changer in terminal [-]"
  ui_print " [-] Then Choose Option 5 to Read the How-to on How to Set up your Fonts [-]"
  sleep 3

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code
cancel() {
  imageless_magisk || unmount_magisk_img
  abort "$1"
}

test_connection() {
  ui_print "Testing internet connection "
  $TMPDIR/busybox-$ARCH32 ping -q -c 1 -W 1 google.com >/dev/null 2>&1 && ui_print "- Internet Detected" || { cancel "Error, No Internet Connection"; false; }
}

test_connection2() {
  case "$($TMPDIR/curl-$ARCH32 -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
  [23]) echo "HTTP connectivity is up";;
  5) echo "The web proxy won't let us through" false;;
  *) cancel "The network is down or very slow";;
esac
}

test_connection3() {
  $TMPDIR/busybox-$ARCH32 wget -q --tries=5 --timeout=10 http://www.google.com -O $TMPDIR/google.idx >/dev/null 2>&1
if [ ! -s $TMPDIR/google.idx ]
then
    ui_print " [!] Not Connected..[!]"
    false
else
    ui_print " [-] Connected..!"
fi
}