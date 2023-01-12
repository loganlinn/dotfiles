rec {
  # List of all XF86 keysyms defined in xorg.
  # https://cgit.freedesktop.org/xorg/proto/x11proto/tree/XF86keysym.h

  allXF86Keysyms = [
    "XF86XK_ModeLock" # Mode Switch Lock

    # Backlight controls.
    "XF86XK_MonBrightnessUp" # Monitor/panel brightness
    "XF86XK_MonBrightnessDown" # Monitor/panel brightness
    "XF86XK_KbdLightOnOff" # Keyboards may be lit
    "XF86XK_KbdBrightnessUp" # Keyboards may be lit
    "XF86XK_KbdBrightnessDown" # Keyboards may be lit

    # Keys found on some "Internet" keyboards.
    "XF86XK_Standby" # System into standby mode
    "XF86XK_AudioLowerVolume" # Volume control down
    "XF86XK_AudioMute" # Mute sound from the system
    "XF86XK_AudioRaiseVolume" # Volume control up
    "XF86XK_AudioPlay" # Start playing of audio >
    "XF86XK_AudioStop" # Stop playing audio
    "XF86XK_AudioPrev" # Previous track
    "XF86XK_AudioNext" # Next track
    "XF86XK_HomePage" # Display user's home page
    "XF86XK_Mail" # Invoke user's mail program
    "XF86XK_Start" # Start application
    "XF86XK_Search" # Search
    "XF86XK_AudioRecord" # Record audio application

    # These are sometimes found on PDA's (e.g. Palm, PocketPC or elsewhere)
    "XF86XK_Calculator" # Invoke calculator program
    "XF86XK_Memo" # Invoke Memo taking program
    "XF86XK_ToDoList" # Invoke To Do List program
    "XF86XK_Calendar" # Invoke Calendar program
    "XF86XK_PowerDown" # Deep sleep the system
    "XF86XK_ContrastAdjust" # Adjust screen contrast
    "XF86XK_RockerUp" # Rocker switches exist up
    "XF86XK_RockerDown" # and down
    "XF86XK_RockerEnter" # and let you press them

    # Some more "Internet" keyboard symbols
    "XF86XK_Back" # Like back on a browser
    "XF86XK_Forward" # Like forward on a browser
    "XF86XK_Stop" # Stop current operation
    "XF86XK_Refresh" # Refresh the page
    "XF86XK_PowerOff" # Power off system entirely
    "XF86XK_WakeUp" # Wake up system from sleep
    "XF86XK_Eject" # Eject device (e.g. DVD)
    "XF86XK_ScreenSaver" # Invoke screensaver
    "XF86XK_WWW" # Invoke web browser
    "XF86XK_Sleep" # Put system to sleep
    "XF86XK_Favorites" # Show favorite locations
    "XF86XK_AudioPause" # Pause audio playing
    "XF86XK_AudioMedia" # Launch media collection app
    "XF86XK_MyComputer" # Display "My Computer" window
    "XF86XK_VendorHome" # Display vendor home web site
    "XF86XK_LightBulb" # Light bulb keys exist
    "XF86XK_Shop" # Display shopping web site
    "XF86XK_History" # Show history of web surfing
    "XF86XK_OpenURL" # Open selected URL
    "XF86XK_AddFavorite" # Add URL to favorites list
    "XF86XK_HotLinks" # Show "hot" links
    "XF86XK_BrightnessAdjust" # Invoke brightness adj. UI
    "XF86XK_Finance" # Display financial site
    "XF86XK_Community" # Display user's community
    "XF86XK_AudioRewind" # "rewind" audio track
    "XF86XK_BackForward" # ???
    "XF86XK_Launch0" # Launch Application
    "XF86XK_Launch1" # Launch Application
    "XF86XK_Launch2" # Launch Application
    "XF86XK_Launch3" # Launch Application
    "XF86XK_Launch4" # Launch Application
    "XF86XK_Launch5" # Launch Application
    "XF86XK_Launch6" # Launch Application
    "XF86XK_Launch7" # Launch Application
    "XF86XK_Launch8" # Launch Application
    "XF86XK_Launch9" # Launch Application
    "XF86XK_LaunchA" # Launch Application
    "XF86XK_LaunchB" # Launch Application
    "XF86XK_LaunchC" # Launch Application
    "XF86XK_LaunchD" # Launch Application
    "XF86XK_LaunchE" # Launch Application
    "XF86XK_LaunchF" # Launch Application

    "XF86XK_ApplicationLeft" # switch to application, left
    "XF86XK_ApplicationRight"
    "XF86XK_Book" # Launch bookreader
    "XF86XK_CD" # Launch CD/DVD player
    "XF86XK_Calculater" # Launch Calculater
    "XF86XK_Clear" # Clear window, screen
    "XF86XK_Close" # Close window
    "XF86XK_Copy" # Copy selection
    "XF86XK_Cut" # Cut selection
    "XF86XK_Display" # Output switch key
    "XF86XK_DOS" # Launch DOS (emulation)
    "XF86XK_Documents" # Open documents window
    "XF86XK_Excel" # Launch spread sheet
    "XF86XK_Explorer" # Launch file explorer
    "XF86XK_Game" # Launch game
    "XF86XK_Go" # Go to URL
    "XF86XK_iTouch" # Logitch iTouch- don't use
    "XF86XK_LogOff" # Log off system
    "XF86XK_Market" # ??
    "XF86XK_Meeting" # enter meeting in calendar
    "XF86XK_MenuKB" # distingush keyboard from PB
    "XF86XK_MenuPB" # distinuish PB from keyboard
    "XF86XK_MySites" # Favourites
    "XF86XK_New" # New (folder, document...
    "XF86XK_News" # News
    "XF86XK_OfficeHome"
    "XF86XK_Open" # Open
    "XF86XK_Option" # ??
    "XF86XK_Paste" # Paste
    "XF86XK_Phone" # Launch phone; dial number
    "XF86XK_Q" # Compaq's Q - don't use
    "XF86XK_Reply" # Reply e.g., mail
    "XF86XK_Reload" # Reload web page, file, etc.
    "XF86XK_RotateWindows" # Rotate windows e.g. xrandr
    "XF86XK_RotationPB" # don't use
    "XF86XK_RotationKB" # don't use
    "XF86XK_Save" # Save (file, document, state
    "XF86XK_ScrollUp" # Scroll window/contents up
    "XF86XK_ScrollDown" # Scrool window/contentd down
    "XF86XK_ScrollClick" # Use XKB mousekeys instead
    "XF86XK_Send" # Send mail, file, object
    "XF86XK_Spell" # Spell checker
    "XF86XK_SplitScreen" # Split window or screen
    "XF86XK_Support" # Get support (??)
    "XF86XK_TaskPane" # Show tasks
    "XF86XK_Terminal" # Launch terminal emulator
    "XF86XK_Tools" # toolbox of desktop/app.
    "XF86XK_Travel" # ??
    "XF86XK_UserPB" # ??
    "XF86XK_User1KB" # ??
    "XF86XK_User2KB" # ??
    "XF86XK_Video" # Launch video player
    "XF86XK_WheelButton" # button from a mouse wheel
    "XF86XK_Word" # Launch word processor
    "XF86XK_Xfer"
    "XF86XK_ZoomIn" # zoom in view, map, etc.
    "XF86XK_ZoomOut" # zoom out view, map, etc.

    "XF86XK_Away" # mark yourself as away
    "XF86XK_Messenger" # as in instant messaging
    "XF86XK_WebCam" # Launch web camera app.
    "XF86XK_MailForward" # Forward in mail
    "XF86XK_Pictures" # Show pictures
    "XF86XK_Music" # Launch music application

    "XF86XK_Battery" # Display battery information
    "XF86XK_Bluetooth" # Enable/disable Bluetooth
    "XF86XK_WLAN" # Enable/disable WLAN
    "XF86XK_UWB" # Enable/disable UWB

    "XF86XK_AudioForward" # fast-forward audio track
    "XF86XK_AudioRepeat" # toggle repeat mode
    "XF86XK_AudioRandomPlay" # toggle shuffle mode
    "XF86XK_Subtitle" # cycle through subtitle
    "XF86XK_AudioCycleTrack" # cycle through audio tracks
    "XF86XK_CycleAngle" # cycle through angles
    "XF86XK_FrameBack" # video: go one frame back
    "XF86XK_FrameForward" # video: go one frame forward
    "XF86XK_Time" # display, or shows an entry for time seeking
    "XF86XK_Select" # Select button on joypads and remotes
    "XF86XK_View" # Show a view options/properties
    "XF86XK_TopMenu" # Go to a top-level menu in a video

    "XF86XK_Red" # Red button
    "XF86XK_Green" # Green button
    "XF86XK_Yellow" # Yellow button
    "XF86XK_Blue" # Blue button

    "XF86XK_Suspend" # Sleep to RAM
    "XF86XK_Hibernate" # Sleep to disk
    "XF86XK_TouchpadToggle" # Toggle between touchpad/trackstick
    "XF86XK_TouchpadOn" # The touchpad got switched on
    "XF86XK_TouchpadOff" # The touchpad got switched off

    "XF86XK_AudioMicMute" # Mute the Mic from the system

    "XF86XK_Keyboard" # User defined keyboard related action

    "XF86XK_WWAN" # Toggle WWAN (LTE, UMTS, etc.) radio
    "XF86XK_RFKill" # Toggle radios on/off

    "XF86XK_AudioPreset" # Select equalizer preset, e.g. theatre-mode

    # Keys for special action keys (hot keys)
    # Virtual terminals on some operating systems
    "XF86XK_Switch_VT_1"
    "XF86XK_Switch_VT_2"
    "XF86XK_Switch_VT_3"
    "XF86XK_Switch_VT_4"
    "XF86XK_Switch_VT_5"
    "XF86XK_Switch_VT_6"
    "XF86XK_Switch_VT_7"
    "XF86XK_Switch_VT_8"
    "XF86XK_Switch_VT_9"
    "XF86XK_Switch_VT_10"
    "XF86XK_Switch_VT_11"
    "XF86XK_Switch_VT_12"

    "XF86XK_Ungrab" # force ungrab
    "XF86XK_ClearGrab" # kill application with grab
    "XF86XK_Next_VMode" # next video mode available
    "XF86XK_Prev_VMode" # prev. video mode available
    "XF86XK_LogWindowTree" # print window tree to log
    "XF86XK_LogGrabInfo" # print all active grabs to log
  ];

  # A map from system to system. It's useful to detect typos.
  XF86Keysyms =
    builtins.listToAttrs
    (map (keysym: {
        name = keysym;
        value = keysym;
      })
      allKeysyms);
}
