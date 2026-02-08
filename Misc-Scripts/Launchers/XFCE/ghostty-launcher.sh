#!/bin/bash

# --- CONFIGURATION ---
GHOSTTY_PATH="/home/Muhammad-Abdullah/Linux/Executibles/AppImages/Ghostty-1.2.3-x86_64.AppImage"
EXEC_CMD="fish -c 'applauncher'"
UNIQUE_TITLE="GHOSTTY_BG_FINAL"
PID_FILE="/tmp/ghostty_bg.pid"

# STYLING
FONT_SIZE=11
OPACITY=1.0

# PRESETS: "custom", "center", or "maximized"
POSITION_PRESET="center" 

# WORKSPACE BEHAVIOR: "true" (all) or "false" (current only)
VISIBLE_ON_ALL_WORKSPACES="false"

# SIZING (Used for "center" and "custom")
WIDTH=1000
HEIGHT=500

# CUSTOM POSITION (Used only if preset is "custom")
POS_X=0
POS_Y=0
# ---------------------

# 1. TOGGLE LOGIC
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null; then
        echo "Toggling Off..."
        WID_CLOSE=$(xdotool search --name "^${UNIQUE_TITLE}$" | tail -1)
        [ -n "$WID_CLOSE" ] && wmctrl -ic "$WID_CLOSE"
        kill "$OLD_PID" 2>/dev/null
        rm "$PID_FILE"
        exit 0
    fi
    rm "$PID_FILE"
fi

# 2. LAUNCH LOGIC
echo "Launching Ghostty..."

# Consolidate flags to ensure they are applied to ALL launch modes
GHOSTTY_FLAGS="--title=$UNIQUE_TITLE --window-decoration=none --font-size=$FONT_SIZE --background-opacity=$OPACITY"

if [ "$POSITION_PRESET" == "maximized" ]; then
    $GHOSTTY_PATH $GHOSTTY_FLAGS --maximized -e $EXEC_CMD &
else
    if [ "$POSITION_PRESET" == "center" ]; then
        SCREEN_W=$(xdpyinfo | awk '/dimensions:/{print $2}' | cut -d'x' -f1)
        SCREEN_H=$(xdpyinfo | awk '/dimensions:/{print $2}' | cut -d'x' -f2)
        POS_X=$(( (SCREEN_W - WIDTH) / 2 ))
        POS_Y=$(( (SCREEN_H - HEIGHT) / 2 ))
    fi
    $GHOSTTY_PATH $GHOSTTY_FLAGS -e $EXEC_CMD &
fi

NEW_PID=$!
echo $NEW_PID > "$PID_FILE"

# 3. POSITIONING & PINNING SEQUENCE
WID=""
for i in {1..30}; do
    WID=$(xdotool search --name "^${UNIQUE_TITLE}$" | tail -1)
    [ -n "$WID" ] && break
    sleep 0.1
done

if [ -n "$WID" ]; then
    # A. Set Window Type to DESKTOP (The "Pin" factor)
    xprop -id "$WID" -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_DESKTOP
    
    # B. Apply States
    wmctrl -ir "$WID" -b add,below,skip_taskbar,skip_pager
    
    # C. Workspace Logic (Crucial for non-sticky behavior)
    if [ "$VISIBLE_ON_ALL_WORKSPACES" == "true" ]; then
        wmctrl -ir "$WID" -b add,sticky
    else
        wmctrl -ir "$WID" -b remove,sticky
    fi

    # D. Sizing and Positioning
    if [ "$POSITION_PRESET" != "maximized" ]; then
        xdotool windowsize "$WID" $WIDTH $HEIGHT
        xdotool windowmove "$WID" $POS_X $POS_Y
    fi
    
    # E. Final Push to Bottom
    xdotool windowlower "$WID"
    echo "Success: Ghostty pinned to background."
else
    echo "Error: Window timed out."
    rm "$PID_FILE"
fi
