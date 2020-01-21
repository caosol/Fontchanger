if [ -d /sbin/.Fontchanger ]; then
  rm -rf /sbin/.Fontchanger
fi

if [ -e /sbin/font_changer ]; then
  rm -f /sbin/font_changer
fi

if [ -e /sbin/Fontchanger-functions ]; then
  rm -f /sbin/Fontchanger-functions
fi