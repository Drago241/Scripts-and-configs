#!/bin/bash

# Launch xfce4-terminal with desired options
xfce4-terminal --hide-menubar --hide-toolbar --hide-borders --maximize &

# Give it a moment to open
sleep 0.5s

# Find the window ID of the last opened xfce4-terminal window
WINDOW_ID=$(xdotool search --onlyvisible --class xfce4-terminal | tail -n1)

# Set window properties to make it a desktop background
if [ -n "$WINDOW_ID" ]; then
    # Set the window type to desktop
    xprop -id "$WINDOW_ID" -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_DESKTOP
    # Place the window below other windows
    wmctrl -i -r "$WINDOW_ID" -b add,below,skip_taskbar,skip_pager
    echo "xfce4-terminal (ID: $WINDOW_ID) set as desktop background."
else
    echo "Could not find xfce4-terminal window."
fi
