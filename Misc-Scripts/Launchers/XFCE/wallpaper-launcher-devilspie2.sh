#!/bin/bash

CUSTOM_FOLDER="$HOME/Linux/Live-Wallpapers"
LOCK_FILE="/tmp/live_wallpaper.pid"

# Get monitor geometry
MON_RES=$(xrandr | grep '*' | awk '{print $1}' | head -n1)
WIDTH=${MON_RES%x*}
HEIGHT=${MON_RES#*x}

# === CLEANUP ===
if [ -f "$LOCK_FILE" ]; then
    WP_PID=$(cat "$LOCK_FILE")
    echo "🧹 Closing wallpaper..."
    kill "$WP_PID" 2>/dev/null
    rm -f "$LOCK_FILE"
    xfdesktop --reload &
    exit 0
fi

# === FILE SELECTION ===
if [ -n "$1" ]; then
    WALLPAPER="$1"
else
    FILES=("$CUSTOM_FOLDER"/*)
    WALLPAPER="${FILES[RANDOM % ${#FILES[@]}]}"
fi

# === THE XFCE ICON FIX ===
# Step 1: Find the actual window ID of the XFCE Desktop
# We look for the window that handles the desktop icons
DESKTOP_WID=$(xdotool search --class "xfdesktop" | tail -n1)

if [ -z "$DESKTOP_WID" ]; then
    echo "❌ Could not find xfdesktop. Is it running?"
    exit 1
fi

echo "🎯 Found Desktop WID: $DESKTOP_WID"

# Step 2: Launch MPV and force it to draw INSIDE that window
# --wid=$DESKTOP_WID tells mpv to render directly into the xfdesktop window
# --vo=x11 is often more stable for WID embedding
mpv --wid="$DESKTOP_WID" \
    --loop=inf \
    --no-audio \
    --really-quiet \
    --no-input-default-bindings \
    --no-osc \
    --panscan=1.0 "$WALLPAPER" &

WP_PID=$!
echo $WP_PID > "$LOCK_FILE"

# Step 3: Force a redraw of the icons
# We need to tell xfdesktop to refresh so icons appear OVER the video
sleep 1
xfdesktop --reload &

echo "✅ Video injected into desktop layer."
