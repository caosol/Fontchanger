<h1 align="center">Font Changer</h1>

<div align="center">
  <!-- Version -->
    <img src="https://img.shields.io/badge/Version-v2.0-blue.svg?longCache=true&style=popout-square"
      alt="Version" />
  <!-- Last Updated -->
    <img src="https://img.shields.io/badge/Updated-August 16, 2019-green.svg?longCache=true&style=flat-square"
      alt="_time_stamp_" />
</div>

<div align="center">
  <strong>Font Changer allows the user to download over 200 fonts and apply them. If the user doesn't like any of the fonts or the font they want isn't in the list, then they can put the ttf files in a custom folder in internal storage! After installing and rebooting, open a terminal emulator and type su hit enter then type font_changer and choose option 1 to download one of the fonts provided.
</div>

<div align="center">
  <h3>
    <a href="https://github.com/johnfawkes/fontchanger">
      Source Code
    </a>
  </h3>
</div>

## Using The Custom Option
* Watch the video tutorial at <a href="https://john-fawkes.com/fontchanger.html">Fontchanger Custom Tutorial</a> or <a href="https://www.youtube.com/watch?v=YLUl5X-uVZc">Fontchanger Youtube link</a> to learn how to setup the fonts! This is a 43 minute long video and is very simple to follow but is the only way unfortunately to do the custom option. Hopefully one day I can create an app to make the process a little easier. 

## Support
- Please open an issue on my github page <a href="https://github.com/Magisk-Modules-Repo/fontchanger"> Github </a> or if your on Telegram please join <a href="https://t.me/fontchange_magisk"> Telegram </a> Telegram i will see and fix the issue faster as I am always on Telegram.

## Compatibility
- Magisk 18.0 +
- All devices
- All Android versions
- Roboto font as default font (until further notice)

## Credits
- Font Files from <a href="https://forum.xda-developers.com/android/themes/fonts-flashable-zips-t3219827">@giaton @xdadevelopers</a>
- For making Midnight Core <a href="https://forum.xda-developers.com/member.php?u=8918441">@oldmid @xdadevelopers</a>
- For making and allowing me to use his busybox <a href="https://forum.xda-developers.com/member.php?u=4544860">@osm0sis</a>
- For some code and the update feature <a href="https://t.me/vr25xda/">@vr25</a>

## Donators
- <a href="t.me/botom8">@botom8 Telegram</a>

## Changelog
##v2.1 - 8.16.2019
* Fix a few install typos
* Fix issue where people couldnt install due to internet check. Now if the first internet check passes it skips the other 2 checks.

##v2.0 - 8.16.2019
* Add update font/emoji lists. Use -u or --upgrade to use or choose the option in main menu. The lists are used to show you which fonts/emojis are available.
* Cleanup help. Split help between custom help and option help.
* Now if the zip already exists in Fontchanger folder it wont redownload.(if short zip errors youll need to delete the zip from the Fontchanger/Emojis or Fontchanger/Fonts folder and then choose that font/emoji again)
* Add custom emoji option. The directory setup is the same as custom font except you only need one file named NotoColorEmoji.ttf
* Fix change back to stock font
* Add a way to go back to stock emoji
* If going back to stock font and you have an emoji as well you can keep the emoji.
* Fix logging code. no more cant start errors when running font_changer
* Fix -c shortcut flag
* Hardlink /sbin instead of softlinking (now any changes to files in /sbin/.Fontchanger or /data/adb/modules/Fontchanger will be applied to the link
* code cleanup/typo fixes

##v1.9 - 8.14.2019
* Cleanup some unneeded code
* Fix the find errors
* Fix a couple typos

### v1.8 - 7.12.2019 - 8.13.2019
* Revamp entire install process. starting with v1.9 youll no longer have to reboot to updat because everything is symlinked to /sbin (thanks @vr25 for this idea and code)
* Rework custom option (actually works now if you follow the video tutorial on <a href="https://john-fawkes.com/fontchanger.html">Fontchanger Custom Tutorial</a> or <a href="https://www.youtube.com/watch?v=YLUl5X-uVZc">Fontchanger Youtube link</a>)
* Now fonts with only one file can be applied.
* add ttc support
* revamped help menu. choose from main menu or use font_changer -h or font_changer -help
* new shortcuts options. 
Options:
    -a|—font [font name]        apply the font
    -d|—cfont [custom font]     apply the custom font
    -h|—help                    help
    -l|—listc                   list custom fonts
    -m|—list                    list fonts <basically skips main menu>
    -s|—current                 show current font
    -u|—update                  Update the font list and emoji list
* New colors to make certain things stand out more such as your current font
* bug fixes for things like choosing y on reboot no longer shows back to main menu.
* fix custom fonts (hopefully)
* start emoji support
* Better logging support. now it will put everything i need to fix bugs into a tar.xz in the Fontchanger folder in internal storage. please send me this tar.xz if you encounter any bugs ( This feature will be finished in v2.0)
* added GNU sleep command compiled from source code. no more sleep invaild errors.
* added progress bar. now list loads faster. (will be applied to custom list in later update)
* Update feature. now you can use -u flag or —update to update the font list and emoji list. This is what the module uses to show the list of fonts and emojis on my website and pulls the font files from this list.

### v1.7 - 6.14.2019
* Fix custom Fonts applying for devices that dont use Roboto as default font
* No longer requires Roboto as default font

### v1.6 - 6.14.2019
* Add new connection checker
* fix shebang for whatever reason

### v1.5 - 6.14.2019
* Add osm0sis busybox to use ping durning install

### v1.4 - 6.14.2019
* Add curl during install for users that dont have curl on their devices

### v1.3 - 6.14.2019
* Fix issue with curl choosing multiple fonts. Everything below 100 will work now. 
* Fix ttf typo in help
* Other bug fixes/typos

### v1.2 - 6.14.2019
* Fix typo with fonts. fonts will be found now. sorry about that

### v1.1 - 6.11.2019
* Fix Duplicate fonts being applied by removing old font files when applying a new font
* Fix custom fonts showing in a list correctly
* Rename custom font files to roboto since roboto is 99% of the time the default font

### v1 - 6.04.2019
* Initial Version
