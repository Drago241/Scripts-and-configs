#!/usr/bin/env bash

#
# 📺 Kitty Desktop Widget (Layered Fix for Conky/Desktop)
#

# =====================================================
# CONFIGURATION (Paths & Commands)
# =====================================================
KITTY_PATH="/home/Muhammad-Abdullah/Desktop/xfce/kitty.app/bin/kitty"
RUN_COMMAND="cmatrix"

# Sizing and Positioning from Script 2
WIDTH=1500
HEIGHT=1500
CUSTOM_X=0
CUSTOM_Y=325

# Logic Settings from Script 1
DELAY=1.0 
PID_FILE="/tmp/kitty_desktop_embed.pid"
DS2_CONF="/tmp/kitty_devilspie2.lua"

VISIBILITY_MODE="single" 
CLICK_THROUGH=true
RERUN_ACTION="toggle"

# =====================================================
# INSTANCE MANAGEMENT
# =====================================================
is_running() {
    [[ -f "$PID_FILE" ]] && xprop -id "$(cat "$PID_FILE")" WM_CLASS &>/dev/null
}

close_instance() {
    echo "🧹 Cleaning up..."
    pkill -f "devilspie2.*kitty_devilspie2.lua"
    if [[ -f "$PID_FILE" ]]; then
        WIN_ID=$(cat "$PID_FILE")
        local PID=$(xprop -id "$WIN_ID" _NET_WM_PID | awk '{print $3}')
        [[ -n "$PID" ]] && kill -TERM -"$PID" 2>/dev/null
        wmctrl -ic "$WIN_ID" 2>/dev/null
        rm -f "$PID_FILE"
    fi
    rm -f "$DS2_CONF"
}

# =====================================================
# LUA GEN (Sets initial state to Desktop level)
# =====================================================
generate_ds2_config() {
    cat << EOF > "$DS2_CONF"
if (string.match(string.lower(get_window_class()), "kitty")) then
    set_window_type("_NET_WM_WINDOW_TYPE_DESKTOP");
    set_window_geometry($CUSTOM_X, $CUSTOM_Y, $WIDTH, $HEIGHT);
    undecorate_window();
    set_skip_tasklist(true);
    set_skip_pager(true);
end
EOF
}

# =====================================================
# LAUNCH FUNCTION
# =====================================================
launch_instance() {
    generate_ds2_config
    devilspie2 -d -f "$DS2_CONF" &
    
    echo "🚀 Launching Kitty..."
    # Launching kitty with specific class to match devilspie2
    "$KITTY_PATH" --class kitty sh -c "$RUN_COMMAND" > /dev/null 2>&1 &

    # Wait for window
    MAX_RETRIES=30
    for ((i=0; i<MAX_RETRIES; i++)); do
        sleep 0.5
        WIN_ID=$(xdotool search --class "kitty" | tail -n 1)
        [[ -n "$WIN_ID" ]] && break
    done

    [[ -z "$WIN_ID" ]] && { echo "❌ Could not detect window"; exit 1; }
    echo "$WIN_ID" > "$PID_FILE"

    # --- THE HEAVY FIXES (Ported from Script 1) ---
    TARGET_WS=$(wmctrl -d | grep '*' | cut -d' ' -f1)

    # 1. Force Remove Decor and Layer via Motif Hints
    xprop -id "$WIN_ID" -f _MOTIF_WM_HINTS 32c -set _MOTIF_WM_HINTS "0x2, 0x0, 0x0, 0x0, 0x0"

    # 2. Workspace Pinning
    if [[ "$VISIBILITY_MODE" == "single" ]]; then
        wmctrl -ir "$WIN_ID" -b remove,sticky
        wmctrl -ir "$WIN_ID" -t "$TARGET_WS"
    else
        wmctrl -ir "$WIN_ID" -b add,sticky
    fi

    # 3. Final Type Assertion: DESKTOP puts it behind everything
    xprop -id "$WIN_ID" -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE "_NET_WM_WINDOW_TYPE_DESKTOP"

    # 4. Force Geometry
    xdotool windowsize "$WIN_ID" $WIDTH $HEIGHT
    xdotool windowmove "$WIN_ID" $CUSTOM_X $CUSTOM_Y

    # 5. Lock to bottom
    xdotool windowlower "$WIN_ID"

    # 6. Click-through Hack
    if [[ "$CLICK_THROUGH" == true ]]; then
        xprop -id "$WIN_ID" -f _NET_WM_STRUT_PARTIAL 32c -set _NET_WM_STRUT_PARTIAL "0,0,0,0,0,0,0,0,0,0,0,0"
    fi

    # 7. Post-Launch Enforcement Loop
    (
        for i in {1..12}; do
            sleep 1
            if [[ "$VISIBILITY_MODE" == "single" ]]; then
                wmctrl -ir "$WIN_ID" -b remove,sticky
                wmctrl -ir "$WIN_ID" -t "$TARGET_WS"
            fi
            xdotool windowsize "$WIN_ID" $WIDTH $HEIGHT
            xdotool windowmove "$WIN_ID" $CUSTOM_X $CUSTOM_Y
            xdotool windowlower "$WIN_ID"
        done
    ) &

    echo "✅ Kitty locked to absolute background layer."
}

# =====================================================
# MAIN
# =====================================================
case "$RERUN_ACTION" in
    close)  close_instance ;;
    launch) launch_instance ;;
    toggle|*)
        if is_running; then close_instance; else launch_instance; fi
        ;;
esac
