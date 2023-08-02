{ pkgs, ... }: {
  imports = [
    ./autorandr.nix
    ./betterlockscreen.nix
  ];

  home.packages = with pkgs; [
    arandr
    xdotool # command-line X11 automation tool
    xdo # Perform actions on windows
    wmctrl
    xscreensaver
    xautolock # ac
    (pkgs.callPackage ../pkgs/x-window-focus-close.nix {})
  ] ++ (with pkgs.xorg; [
    # https://www.x.org/releases/current/doc/man/man1/index.xhtml
    # -----------------------------------------------------------
    # x11perf # X11 server performance test program
    # xauth # X authority file utility
    # xbacklight # adjust backlight brightness using RandR extension
    xcalc # scientific calculator for X
    xclock # analog / digital clock for X
    # xcmsdb # Device Color Characterization utility
    xconsole # monitor system console messages
    # xcursorgen # create an X cursor file from a collection
    # xdm # X Display Manager with support for XDMCP, host chooser
    xdpyinfo # display information utility for X
    # xdriinfo # query configuration information of DRI drivers
    xev # print contents of X events
    # xeyes # a follow the mouse X demo
    xfd # display all the characters in an X font
    xfontsel # point and click selection of X11 font names
    # xfs # X font server
    xfsinfo # X font server information utility
    # xgamma # Alter a monitor's gamma correction through the X server
    # xgc # X graphics demo
    # xhost # server access control program
    xinit # X Window System initializer
    xinput # utility to configure and test X input devices
    xkbcomp # compile XKB keyboard description
    xkbevd # XKB event daemon
    xkbprint # print an XKB keyboard description
    xkill # kill a client by its X resource
    # xload # system load average display for X
    # xlsatoms # list interned atoms defined on server
    xlsclients # list client applications running
    xlsfonts # server font list displayer for X
    xmag # magnify parts of the screen
    xmessage # display a message or query in a window (X-based /bin/echo)
    xmodmap # utility for modifying keymaps
    xmore # plain text display program for the X Window System
    xprop # property displayer for X
    xrandr # primitive command line interface to RandR extension
    xrdb # X server resource database utility
    # xrefresh # refresh all or part of an X screen
    xset # user preference utility for X
    # xsetroot # root window parameter setting
    xsm # X Session Manager
    # xstdcmap # X standard colormap utility
    # xvinfo # Print out X-Video extension adaptor information
    # xwd # dump an image of an X window
    xwininfo # window information utility for X
    # xwud # image displayer for X
  ]);
}
