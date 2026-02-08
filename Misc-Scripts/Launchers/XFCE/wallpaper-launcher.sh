#!/bin/bash
# XFCE-compatible Live Wallpaper (Video/Image)
# Multi-workspace, random/custom folder
# Toggle wallpaper on/off with each run
# Supports passing a specific file as the first argument

CUSTOM_FOLDER="$HOME/Linux/Live-Wallpapers"
WIDTH=""
HEIGHT=""
LOCK_FILE="$HOME/.live_wallpaper.lock"

# Get monitor geometry
MON_RES=$(xrandr | grep '*' | awk '{print $1}' | head -n1)
MON_WIDTH=${MON_RES%x*}
MON_HEIGHT=${MON_RES#*x}
[ -z "$WIDTH" ] && WIDTH=$MON_WIDTH
[ -z "$HEIGHT" ] && HEIGHT=$MON_HEIGHT

# === Check if a wallpaper is already running ===
if [ -f "$LOCK_FILE" ]; then
    OLD_PID=$(cat "$LOCK_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "🛑 Closing running wallpaper (PID $OLD_PID)..."
        kill "$OLD_PID"
        rm -f "$LOCK_FILE"
        exit 0  # Stop here, don't launch a new wallpaper automatically
    else
        # PID in lock file not running
        rm -f "$LOCK_FILE"
    fi
fi

# === Determine which file to launch ===
if [ -n "$1" ]; then
    WALLPAPER="$1"
    [ ! -f "$WALLPAPER" ] && { echo "❌ File not found: $WALLPAPER"; exit 1; }
else
    FILES=("$CUSTOM_FOLDER"/*)
    [ ${#FILES[@]} -eq 0 ] && { echo "❌ No wallpapers found in $CUSTOM_FOLDER"; exit 1; }
    WALLPAPER="${FILES[RANDOM % ${#FILES[@]}]}"
fi

EXT="${WALLPAPER##*.}"

# Launch wallpaper
if [[ "$EXT" =~ ^(mp4|mkv|webm|gif)$ ]]; then
    echo "🚀 Launching video wallpaper: $WALLPAPER"
    mpv --loop=inf --no-audio --really-quiet --no-input-default-bindings \
        --no-osc --no-border --force-window=yes --geometry=${WIDTH}x${HEIGHT}+0+0 \
        --panscan=1.0 "$WALLPAPER" &
    WP_PID=$!
    echo $WP_PID > "$LOCK_FILE"

    sleep 0.5
    WIN_ID=$(xdotool search --onlyvisible --classname mpv | tail -n1)
    if [ -n "$WIN_ID" ]; then
        xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DESKTOP"
        xprop -id "$WIN_ID" -f _NET_WM_STATE 32a -set _NET_WM_STATE "_NET_WM_STATE_BELOW"
        xprop -id "$WIN_ID" -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS "2, 0, 0, 0, 0"
    fi
else
    echo "🖼 Launching image wallpaper: $WALLPAPER"
    feh --bg-scale "$WALLPAPER" &
    WP_PID=$!
    echo $WP_PID > "$LOCK_FILE"
fi
